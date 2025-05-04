import 'dart:async';
import 'dart:math';

import 'package:domain/model/camera_point.dart';
import 'package:domain/model/lat_lng.dart';

/// A utility class to simulate GPS movement for testing
class LocationSimulator {
  LocationSimulator({
    required this.cameraPoints,
    this.speedKmh = 100.0,
    this.updateIntervalMs = 500, // Reduced from 1000ms to 500ms for more frequent updates
  });

  /// The camera points to move between
  final List<CameraPoint> cameraPoints;

  /// The simulated speed in km/h
  final double speedKmh;

  /// How often to update the position in milliseconds
  final int updateIntervalMs;

  /// Stream controller for the simulated locations
  final _locationController = StreamController<LatLng>.broadcast();

  /// Access the stream of simulated locations
  Stream<LatLng> get locationStream => _locationController.stream;

  /// Current position in the simulation
  LatLng _currentPosition = const LatLng(latitude: 0, longitude: 0);

  /// Timer for position updates
  Timer? _timer;

  /// Current target camera index
  int _targetCameraIndex = 1; // Start with the second camera as target

  /// Start the simulation
  void start() {
    if (cameraPoints.isEmpty) {
      throw Exception('Cannot start simulation with empty camera points');
    }

    // Start at the first camera
    _currentPosition = LatLng(latitude: cameraPoints[0].latitude, longitude: cameraPoints[0].longitude);

    // Emit initial position
    _locationController.add(_currentPosition);

    // Start moving
    _timer = Timer.periodic(Duration(milliseconds: updateIntervalMs), _updatePosition);
  }

  /// Stop the simulation
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Update position based on current target and speed
  void _updatePosition(Timer timer) {
    // Get target camera
    final target = cameraPoints[_targetCameraIndex];
    final targetPosition = LatLng(latitude: target.latitude, longitude: target.longitude);

    // Calculate distance to target
    final distance = _calculateDistance(
      _currentPosition.latitude,
      _currentPosition.longitude,
      targetPosition.latitude,
      targetPosition.longitude,
    );

    // If we're very close to the target, move to the next camera
    if (distance < 0.05) {
      // 50 meters threshold
      print('Reached camera: ${target.name}');

      // Move to next camera or loop back to first
      _targetCameraIndex = (_targetCameraIndex + 1) % cameraPoints.length;

      // Short delay at the camera (reduced from 2 seconds to 0.5 seconds)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_timer != null && _timer!.isActive) {
          _updatePosition(_timer!);
        }
      });

      return;
    }

    // Calculate how far to move in this update
    // speed (km/h) / 3600 * updateIntervalMs / 1000 = distance in km per update
    final updateDistanceKm = speedKmh / 3600 * (updateIntervalMs / 1000);

    // Calculate new position
    final newPosition = _calculateNewPosition(_currentPosition, targetPosition, updateDistanceKm);

    // Update current position
    _currentPosition = newPosition;

    // Emit new position
    _locationController.add(_currentPosition);
  }

  /// Calculate new position based on movement direction and distance
  LatLng _calculateNewPosition(LatLng current, LatLng target, double distanceKm) {
    // Calculate bearing
    final bearing = _calculateBearing(current.latitude, current.longitude, target.latitude, target.longitude);

    // Earth radius in km
    const earthRadius = 6371.0;

    // Convert to radians
    final lat1 = _toRadians(current.latitude);
    final lon1 = _toRadians(current.longitude);
    final angularDistance = distanceKm / earthRadius;
    final trueBearing = _toRadians(bearing);

    // Calculate new position
    final lat2 = asin(sin(lat1) * cos(angularDistance) + cos(lat1) * sin(angularDistance) * cos(trueBearing));

    final lon2 =
        lon1 + atan2(sin(trueBearing) * sin(angularDistance) * cos(lat1), cos(angularDistance) - sin(lat1) * sin(lat2));

    // Convert back to degrees
    return LatLng(latitude: _toDegrees(lat2), longitude: _toDegrees(lon2));
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0; // Earth radius in km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) + cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in km
  }

  /// Calculate bearing between two points
  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _toRadians(lon2 - lon1);

    lat1 = _toRadians(lat1);
    lat2 = _toRadians(lat2);

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    var bearing = atan2(y, x);
    bearing = _toDegrees(bearing);
    bearing = (bearing + 360) % 360; // Normalize to 0-360

    return bearing;
  }

  /// Convert degrees to radians
  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Convert radians to degrees
  double _toDegrees(double radians) {
    return radians * 180 / pi;
  }

  /// Clean up resources
  void dispose() {
    stop();
    _locationController.close();
  }
}
