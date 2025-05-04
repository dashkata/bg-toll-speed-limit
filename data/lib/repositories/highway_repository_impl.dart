import 'dart:convert';

import 'package:domain/model/camera_point.dart';
import 'package:domain/model/highway.dart';
import 'package:domain/model/lat_lng.dart';
import 'package:domain/model/tracking_segment.dart';
import 'package:domain/repositories/highway_repository.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class HighwayRepositoryImpl implements HighwayRepository {
  List<Highway>? _cachedHighways;
  List<CameraPoint>? _cachedCameraPoints;
  List<TrackingSegment>? _cachedTrackingSegments;

  @override
  Future<List<Highway>> getHighways() async {
    if (_cachedHighways != null) {
      return _cachedHighways!;
    }

    try {
      // Load from assets - in a real app this might come from a database or API
      final String jsonData = await rootBundle.loadString('assets/data/highways.json');
      final List<dynamic> jsonList = json.decode(jsonData);

      _cachedHighways =
          jsonList
              .map(
                (json) => Highway(
                  id: json['id'],
                  name: json['name'],
                  code: json['code'],
                  speedLimit: json['speedLimit'].toDouble(),
                ),
              )
              .toList();

      return _cachedHighways!;
    } catch (e) {
      // Return placeholder data for development
      return [
        const Highway(id: '1', name: 'Trakia Highway', code: 'A1', speedLimit: 130.0),
        const Highway(id: '2', name: 'Hemus Highway', code: 'A2', speedLimit: 130.0),
      ];
    }
  }

  @override
  Future<List<CameraPoint>> getCameraPoints() async {
    if (_cachedCameraPoints != null) {
      return _cachedCameraPoints!;
    }

    try {
      final highways = await getHighways();
      final String jsonData = await rootBundle.loadString('assets/data/camera_points.json');
      final List<dynamic> jsonList = json.decode(jsonData);

      _cachedCameraPoints =
          jsonList.map((json) {
            final highway = highways.firstWhere((h) => h.id == json['highwayId']);
            return CameraPoint(
              id: json['id'],
              name: json['name'],
              latitude: json['latitude'],
              longitude: json['longitude'],
              highway: highway,
              kilometerMark: json['kilometerMark'],
            );
          }).toList();

      return _cachedCameraPoints!;
    } catch (e) {
      // Return placeholder data for development
      final highways = await getHighways();
      return [
        CameraPoint(
          id: '1',
          name: 'Camera 1',
          latitude: 42.6977,
          longitude: 23.3219,
          highway: highways[0],
          kilometerMark: 10,
        ),
        CameraPoint(
          id: '2',
          name: 'Camera 2',
          latitude: 42.7000,
          longitude: 23.4000,
          highway: highways[0],
          kilometerMark: 40,
        ),
      ];
    }
  }

  @override
  Future<List<CameraPoint>> getCameraPointsForHighway(String highwayId) async {
    final allCameraPoints = await getCameraPoints();
    return allCameraPoints.where((point) => point.highway.id == highwayId).toList();
  }

  @override
  Future<List<TrackingSegment>> getTrackingSegments() async {
    // Check if we have cached segments
    if (_cachedTrackingSegments != null) {
      return _cachedTrackingSegments!;
    }

    try {
      // First try to load from JSON file
      final allCameraPoints = await getCameraPoints();
      final String jsonData = await rootBundle.loadString('assets/data/segments.json');
      final List<dynamic> jsonList = json.decode(jsonData);

      _cachedTrackingSegments =
          jsonList.map((json) {
            final startCamera = allCameraPoints.firstWhere((c) => c.id == json['startCameraId']);
            final endCamera = allCameraPoints.firstWhere((c) => c.id == json['endCameraId']);

            return TrackingSegment(
              id: json['id'],
              startCamera: startCamera,
              endCamera: endCamera,
              distanceKm: json['distanceKm'],
              speedLimit: json['speedLimit'] ?? endCamera.highway.speedLimit,
            );
          }).toList();

      return _cachedTrackingSegments!;
    } catch (e) {
      // If loading from JSON fails, dynamically generate segments
      return _generateTrackingSegments();
    }
  }

  /// Dynamically generate tracking segments from camera points
  Future<List<TrackingSegment>> _generateTrackingSegments() async {
    // Get all camera points
    final allCameraPoints = await getCameraPoints();

    // Get all highways
    final allHighways = await getHighways();

    // List to store generated segments
    final List<TrackingSegment> generatedSegments = [];

    // Process each highway
    for (final highway in allHighways) {
      // Get all cameras on this highway, sorted by kilometer mark
      final highwayCameras =
          allCameraPoints.where((camera) => camera.highway.id == highway.id).toList()
            ..sort((a, b) => a.kilometerMark.compareTo(b.kilometerMark));

      // If we have at least 2 cameras, we can create segments
      if (highwayCameras.length >= 2) {
        // For each pair of adjacent cameras, create a segment
        for (int i = 0; i < highwayCameras.length - 1; i++) {
          final startCamera = highwayCameras[i];
          final endCamera = highwayCameras[i + 1];

          // Calculate distance between cameras (km)
          final distanceKm = _calculateDistanceBetweenCameras(startCamera, endCamera);

          // Create segment
          final segment = TrackingSegment(
            id: '${highway.id}_${startCamera.id}_${endCamera.id}',
            startCamera: startCamera,
            endCamera: endCamera,
            distanceKm: distanceKm,
            speedLimit: highway.speedLimit,
          );

          generatedSegments.add(segment);
        }
      }
    }

    // Cache the generated segments
    _cachedTrackingSegments = generatedSegments;

    return generatedSegments;
  }

  /// Calculate distance between two camera points in kilometers
  double _calculateDistanceBetweenCameras(CameraPoint camera1, CameraPoint camera2) {
    if (camera1.highway.id == camera2.highway.id) {
      // If on same highway and we have kilometer marks, use them
      return (camera2.kilometerMark - camera1.kilometerMark).abs().toDouble();
    } else {
      // Otherwise calculate using coordinates
      return Geolocator.distanceBetween(camera1.latitude, camera1.longitude, camera2.latitude, camera2.longitude) /
          1000; // Convert meters to kilometers
    }
  }

  @override
  Future<List<TrackingSegment>> getTrackingSegmentsForHighway(String highwayId) async {
    final allSegments = await getTrackingSegments();
    return allSegments.where((segment) => segment.startCamera.highway.id == highwayId).toList();
  }

  @override
  Future<CameraPoint?> findNearestCameraPoint(LatLng location, double radiusKm) async {
    final allCameraPoints = await getCameraPoints();

    double closestDistance = double.infinity;
    CameraPoint? closestPoint;

    for (final point in allCameraPoints) {
      final distance =
          Geolocator.distanceBetween(location.latitude, location.longitude, point.latitude, point.longitude) /
          1000; // Convert to km

      if (distance < closestDistance && distance <= radiusKm) {
        closestDistance = distance;
        closestPoint = point;
      }
    }

    return closestPoint;
  }

  @override
  Future<List<TrackingSegment>> findSegmentsForCameraPoint(String cameraPointId) async {
    final allSegments = await getTrackingSegments();
    return allSegments
        .where((segment) => segment.startCamera.id == cameraPointId || segment.endCamera.id == cameraPointId)
        .toList();
  }
}
