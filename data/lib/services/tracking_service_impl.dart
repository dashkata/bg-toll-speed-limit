import 'dart:async';
import 'dart:developer';

import 'package:domain/model/camera_point.dart';
import 'package:domain/model/lat_lng.dart';
import 'package:domain/model/tracking_segment.dart';
import 'package:domain/repositories/highway_repository.dart';
import 'package:domain/services/tracking_service.dart';
import 'package:geolocator/geolocator.dart';

class TrackingServiceImpl implements TrackingService {
  TrackingServiceImpl({required this.highwayRepository}) {
    // Start location monitoring when service is created
    _startLocationMonitoring();
  }

  final HighwayRepository highwayRepository;

  // Private fields
  final _speedStreamController = StreamController<double>.broadcast();
  final _segmentStreamController = StreamController<TrackingSegment?>.broadcast();

  // Tracking state
  TrackingSegment? _currentSegment;
  DateTime? _segmentStartTime;
  StreamSubscription<Position>? _positionSubscription;
  CameraPoint? _lastDetectedCamera;

  // Constants for detection
  static const double _cameraDetectionRadiusMeters = 150.0;
  static const double _minimumSpeedThresholdKmh = 20.0; // Only track when moving
  bool _isAutoTrackingEnabled = true;

  @override
  Future<double> getCurrentSpeed() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // Speed in m/s, convert to km/h
      return (position.speed >= 0 ? position.speed : 0) * 3.6;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<LatLng> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return LatLng(latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      log('Error getting current location: $e');
      return const LatLng(latitude: 0.0, longitude: 0.0);
    }
  }

  @override
  Future<bool> isNearCameraPoint(CameraPoint point, double radiusMeters) async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        point.latitude,
        point.longitude,
      );

      return distanceInMeters <= radiusMeters;
    } catch (e) {
      log('Error checking if near camera point: $e');
      return false;
    }
  }

  @override
  Future<void> startSegmentTracking(TrackingSegment segment) async {
    _currentSegment = segment.copyWith(entryTime: DateTime.now(), currentAverageSpeed: 0.0);
    _segmentStartTime = DateTime.now();
    _segmentStreamController.add(_currentSegment);
    log('Started tracking segment: ${segment.id}');
  }

  @override
  Future<double> endSegmentTracking(TrackingSegment segment) async {
    if (_currentSegment == null || _segmentStartTime == null) {
      return 0.0;
    }

    final endTime = DateTime.now();
    final travelTimeHours = endTime.difference(_segmentStartTime!).inSeconds / 3600;

    // Calculate average speed based on segment distance and time
    final averageSpeed = travelTimeHours > 0 ? segment.distanceKm / travelTimeHours : 0.0;

    _currentSegment = null;
    _segmentStartTime = null;
    _lastDetectedCamera = null;
    _segmentStreamController.add(null);
    log('Ended tracking segment: ${segment.id}, average speed: $averageSpeed km/h');

    return averageSpeed;
  }

  @override
  TrackingSegment? getCurrentSegment() {
    return _currentSegment;
  }

  @override
  Stream<double> getSpeedStream() {
    return _speedStreamController.stream;
  }

  @override
  Stream<TrackingSegment?> getTrackingSegmentStream() {
    return _segmentStreamController.stream;
  }

  // Private methods
  void _onPositionUpdate(Position position) {
    // Update current speed
    final speed = (position.speed >= 0 ? position.speed : 0) * 3.6;
    _speedStreamController.add(speed);

    // If currently tracking a segment, update average speed
    if (_currentSegment != null && _segmentStartTime != null) {
      final now = DateTime.now();
      final travelTimeHours = now.difference(_segmentStartTime!).inSeconds / 3600;

      if (travelTimeHours > 0) {
        final avgSpeed = _currentSegment!.distanceKm / travelTimeHours;
        _currentSegment = _currentSegment!.copyWith(currentAverageSpeed: avgSpeed);
        _segmentStreamController.add(_currentSegment);
      }
    }

    // Only perform auto-detection if we're actually moving and auto-tracking is enabled
    if (_isAutoTrackingEnabled && speed >= _minimumSpeedThresholdKmh) {
      _checkForCameraPoints(position);
    }
  }

  Future<void> _checkForCameraPoints(Position position) async {
    try {
      // Get all camera points
      final cameraPoints = await highwayRepository.getCameraPoints();

      // Check if we're near any camera points
      for (final camera in cameraPoints) {
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          camera.latitude,
          camera.longitude,
        );

        // If we're near a camera point
        if (distance <= _cameraDetectionRadiusMeters) {
          await _handleCameraPointDetection(camera);
          break; // Only handle one camera at a time
        }
      }
    } catch (e) {
      log('Error checking for camera points: $e');
    }
  }

  Future<void> _handleCameraPointDetection(CameraPoint detectedCamera) async {
    try {
      // If we already detected this camera recently, ignore
      if (_lastDetectedCamera?.id == detectedCamera.id) {
        return;
      }

      // Get segments that include this camera
      final segments = await highwayRepository.findSegmentsForCameraPoint(detectedCamera.id);

      // Case 1: We're not currently tracking a segment
      if (_currentSegment == null) {
        // Find segments where this camera is the start point
        final startingSegments = segments.where((segment) => segment.startCamera.id == detectedCamera.id).toList();

        if (startingSegments.isNotEmpty) {
          // Take first available segment (could implement logic to select the most likely one)
          await startSegmentTracking(startingSegments.first);
          _lastDetectedCamera = detectedCamera;
          log('Auto-detected start camera: ${detectedCamera.name}');
        }
      }
      // Case 2: We are already tracking a segment
      else if (_currentSegment != null) {
        // Check if this camera is the end point of our current segment
        if (_currentSegment!.endCamera.id == detectedCamera.id) {
          await endSegmentTracking(_currentSegment!);
          log('Auto-detected end camera: ${detectedCamera.name}');

          // Immediately check if this is also the start of a new segment
          final nextSegments = segments.where((segment) => segment.startCamera.id == detectedCamera.id).toList();

          if (nextSegments.isNotEmpty) {
            await startSegmentTracking(nextSegments.first);
            log('Auto-started next segment from camera: ${detectedCamera.name}');
          }
        }
      }
    } catch (e) {
      log('Error handling camera point detection: $e');
    }
  }

  Future<void> _startLocationMonitoring() async {
    // Check for location permissions
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    // Start position tracking
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen(_onPositionUpdate);

    log('Started location monitoring for automatic segment detection');
  }

  // Enable/disable automatic tracking
  void setAutoTracking(bool enabled) {
    _isAutoTrackingEnabled = enabled;
    log('Auto tracking set to: $enabled');
  }

  // Dispose resources
  void dispose() {
    _speedStreamController.close();
    _segmentStreamController.close();
    _positionSubscription?.cancel();
  }
}
