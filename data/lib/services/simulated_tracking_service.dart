import 'dart:async';
import 'dart:math';

import 'package:domain/model/camera_point.dart';
import 'package:domain/model/lat_lng.dart';
import 'package:domain/model/tracking_segment.dart';
import 'package:domain/repositories/highway_repository.dart';
import 'package:domain/services/tracking_service.dart';

import '../utils/location_simulator.dart';

/// A tracking service implementation that uses simulated location data for testing
class SimulatedTrackingService implements TrackingService {
  SimulatedTrackingService({required this.highwayRepository, this.simulatedSpeedKmh = 110.0}) {
    _init();
  }

  final HighwayRepository highwayRepository;
  final double simulatedSpeedKmh;

  // Stream controllers
  final _speedStreamController = StreamController<double>.broadcast();
  final _segmentStreamController = StreamController<TrackingSegment?>.broadcast();

  // Tracking state
  TrackingSegment? _currentSegment;
  DateTime? _segmentStartTime;
  CameraPoint? _lastDetectedCamera;

  // The location simulator
  late LocationSimulator _simulator;

  // Keep track of the current position locally
  LatLng _currentPosition = const LatLng(latitude: 0, longitude: 0);

  // Detection settings
  static const double _cameraDetectionRadiusMeters = 300.0;
  bool _isAutoTrackingEnabled = true;

  // Identify this as a simulation service
  @override
  bool get isSimulation => true;

  // Initialize simulator with sample data
  Future<void> _init() async {
    final cameraPoints = await highwayRepository.getCameraPoints();

    if (cameraPoints.isEmpty) {
      throw Exception('No camera points available for simulation');
    }

    print('Starting simulation with ${cameraPoints.length} camera points');

    // Create simulator with camera points
    _simulator = LocationSimulator(cameraPoints: cameraPoints, speedKmh: simulatedSpeedKmh);

    // Subscribe to location updates
    _simulator.locationStream.listen(_onLocationUpdate);

    // Start simulation
    _simulator.start();
    print('Simulation started at speed: $simulatedSpeedKmh km/h');
  }

  // Process location updates
  Future<void> _onLocationUpdate(LatLng location) async {
    // Store the current position
    _currentPosition = location;

    // Calculate current speed (randomly fluctuate around simulated speed)
    final random = Random();
    final speedVariation = (random.nextDouble() * 10) - 5; // +/- 5 km/h
    final currentSpeed = simulatedSpeedKmh + speedVariation;

    // Emit speed update
    _speedStreamController.add(currentSpeed);

    // If tracking a segment, update average speed
    if (_currentSegment != null && _segmentStartTime != null) {
      final now = DateTime.now();
      final travelTimeHours = now.difference(_segmentStartTime!).inSeconds / 3600;

      // Only update average speed if we have a reasonable time delta
      // This prevents extreme values at the start of tracking
      if (travelTimeHours > 0.001) {
        // Minimum 3.6 seconds (0.001 hours)
        // Calculate a realistic average speed using the segment distance and time
        // Limit it to a reasonable range based on the current speed
        final avgSpeed = _currentSegment!.distanceKm / travelTimeHours;
        final clampedAvgSpeed = _clampSpeed(avgSpeed, currentSpeed * 0.7, currentSpeed * 1.3);

        _currentSegment = _currentSegment!.copyWith(currentAverageSpeed: clampedAvgSpeed);
        _segmentStreamController.add(_currentSegment);
      }
    }

    // Check for camera points if auto-tracking is enabled
    if (_isAutoTrackingEnabled) {
      await _checkForCameraPoints(location);
    }
  }

  // Clamp speed to reasonable values
  double _clampSpeed(double calculatedSpeed, double min, double max) {
    if (calculatedSpeed.isNaN || calculatedSpeed.isInfinite) {
      return simulatedSpeedKmh; // Fallback to simulated speed if calculation is invalid
    }
    return calculatedSpeed.clamp(min, max);
  }

  // Check if we're near any camera points
  Future<void> _checkForCameraPoints(LatLng location) async {
    try {
      // Get all camera points
      final cameraPoints = await highwayRepository.getCameraPoints();

      // Check proximity to each camera
      for (final camera in cameraPoints) {
        final distance = _calculateDistance(location.latitude, location.longitude, camera.latitude, camera.longitude);

        // Convert to meters
        final distanceMeters = distance * 1000;

        // Additional logging to monitor approach to cameras
        if (distanceMeters <= 1000) {
          // Log when we're within 1km of a camera
          print('Approaching camera: ${camera.name} (${distanceMeters.toStringAsFixed(0)}m away)');
        }

        // If we're near a camera point
        if (distanceMeters <= _cameraDetectionRadiusMeters) {
          print('🚨 CAMERA DETECTED: ${camera.name} at ${distanceMeters.toStringAsFixed(0)}m distance');
          await _handleCameraPointDetection(camera);
          break; // Only handle one camera at a time
        }
      }
    } catch (e) {
      print('Error checking for camera points: $e');
    }
  }

  // Handle camera point detection
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
          // Take first available segment
          await startSegmentTracking(startingSegments.first);
          _lastDetectedCamera = detectedCamera;
          print('🟢 Auto-detected start camera: ${detectedCamera.name}');
        }
      }
      // Case 2: We are already tracking a segment
      else if (_currentSegment != null) {
        // Check if this camera is the end point of our current segment
        if (_currentSegment!.endCamera.id == detectedCamera.id) {
          final averageSpeed = await endSegmentTracking(_currentSegment!);
          print(
            '🔴 Auto-detected end camera: ${detectedCamera.name}. Average speed: ${averageSpeed.toStringAsFixed(1)} km/h',
          );

          // Immediately check if this is also the start of a new segment
          final nextSegments = segments.where((segment) => segment.startCamera.id == detectedCamera.id).toList();

          if (nextSegments.isNotEmpty) {
            await startSegmentTracking(nextSegments.first);
            print('🟢 Auto-started next segment from camera: ${detectedCamera.name}');
          }
        }
      }

      _lastDetectedCamera = detectedCamera;
    } catch (e) {
      print('Error handling camera point detection: $e');
    }
  }

  // Calculate distance between two points (in km)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0; // Earth radius in km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) + cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in km
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  // TrackingService implementation

  @override
  Future<double> getCurrentSpeed() async {
    // Return a simulated speed
    final random = Random();
    final speedVariation = (random.nextDouble() * 10) - 5; // +/- 5 km/h
    return simulatedSpeedKmh + speedVariation;
  }

  @override
  Future<LatLng> getCurrentLocation() async {
    // Return our locally tracked current position
    return _currentPosition;
  }

  @override
  Future<bool> isNearCameraPoint(CameraPoint point, double radiusMeters) async {
    // Use our locally tracked current position
    final distanceMeters =
        _calculateDistance(_currentPosition.latitude, _currentPosition.longitude, point.latitude, point.longitude) *
        1000; // Convert km to meters

    return distanceMeters <= radiusMeters;
  }

  @override
  Future<void> startSegmentTracking(TrackingSegment segment) async {
    _currentSegment = segment.copyWith(entryTime: DateTime.now(), currentAverageSpeed: simulatedSpeedKmh);
    _segmentStartTime = DateTime.now();
    _segmentStreamController.add(_currentSegment);
    print('📊 Started tracking segment: ${segment.id} (${segment.startCamera.name} → ${segment.endCamera.name})');
  }

  @override
  Future<double> endSegmentTracking(TrackingSegment segment) async {
    if (_currentSegment == null || _segmentStartTime == null) {
      return 0.0;
    }

    final endTime = DateTime.now();
    final travelTimeHours = endTime.difference(_segmentStartTime!).inSeconds / 3600;

    // Calculate a reasonable average speed
    double averageSpeed;
    if (travelTimeHours <= 0.001) {
      // If time is too small, use the simulated speed
      averageSpeed = simulatedSpeedKmh;
    } else {
      // Otherwise calculate based on distance and time, but keep it reasonable
      final calculatedSpeed = segment.distanceKm / travelTimeHours;
      averageSpeed = _clampSpeed(calculatedSpeed, simulatedSpeedKmh * 0.8, simulatedSpeedKmh * 1.2);
    }

    print('📊 Ended tracking segment: ${segment.id}, average speed: ${averageSpeed.toStringAsFixed(1)} km/h');
    print('📊 Segment details: ${segment.distanceKm}km, time: ${(travelTimeHours * 60).toStringAsFixed(1)} minutes');

    _currentSegment = null;
    _segmentStartTime = null;
    _segmentStreamController.add(null);

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

  // Enable/disable automatic tracking
  @override
  void setAutoTracking(bool enabled) {
    _isAutoTrackingEnabled = enabled;
    print('Auto tracking set to: $enabled');
  }

  // Clean up
  void dispose() {
    _simulator.dispose();
    _speedStreamController.close();
    _segmentStreamController.close();
  }
}
