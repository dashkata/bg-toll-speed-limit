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
      final String jsonData =
          await rootBundle.loadString('assets/data/highways.json');
      final List<dynamic> jsonList = json.decode(jsonData);

      _cachedHighways = jsonList
          .map((json) => Highway(
                id: json['id'],
                name: json['name'],
                code: json['code'],
                speedLimit: json['speedLimit'].toDouble(),
              ))
          .toList();

      return _cachedHighways!;
    } catch (e) {
      // Return placeholder data for development
      return [
        const Highway(
          id: '1',
          name: 'Trakia Highway',
          code: 'A1',
          speedLimit: 130.0,
        ),
        const Highway(
          id: '2',
          name: 'Hemus Highway',
          code: 'A2',
          speedLimit: 130.0,
        ),
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
      final String jsonData =
          await rootBundle.loadString('assets/data/camera_points.json');
      final List<dynamic> jsonList = json.decode(jsonData);

      _cachedCameraPoints = jsonList.map((json) {
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
    return allCameraPoints
        .where((point) => point.highway.id == highwayId)
        .toList();
  }

  @override
  Future<List<TrackingSegment>> getTrackingSegments() async {
    if (_cachedTrackingSegments != null) {
      return _cachedTrackingSegments!;
    }

    try {
      final allCameraPoints = await getCameraPoints();
      final String jsonData =
          await rootBundle.loadString('assets/data/segments.json');
      final List<dynamic> jsonList = json.decode(jsonData);

      _cachedTrackingSegments = jsonList.map((json) {
        final startCamera =
            allCameraPoints.firstWhere((c) => c.id == json['startCameraId']);
        final endCamera =
            allCameraPoints.firstWhere((c) => c.id == json['endCameraId']);

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
      // Return placeholder data for development
      final allCameraPoints = await getCameraPoints();
      if (allCameraPoints.length < 2) {
        return [];
      }

      return [
        TrackingSegment(
          id: '1',
          startCamera: allCameraPoints[0],
          endCamera: allCameraPoints[1],
          distanceKm: 30.0,
          speedLimit: allCameraPoints[0].highway.speedLimit,
        ),
      ];
    }
  }

  @override
  Future<List<TrackingSegment>> getTrackingSegmentsForHighway(
      String highwayId) async {
    final allSegments = await getTrackingSegments();
    return allSegments
        .where((segment) => segment.startCamera.highway.id == highwayId)
        .toList();
  }

  @override
  Future<CameraPoint?> findNearestCameraPoint(
      LatLng location, double radiusKm) async {
    final allCameraPoints = await getCameraPoints();

    double closestDistance = double.infinity;
    CameraPoint? closestPoint;

    for (final point in allCameraPoints) {
      final distance = Geolocator.distanceBetween(
            location.latitude,
            location.longitude,
            point.latitude,
            point.longitude,
          ) /
          1000; // Convert to km

      if (distance < closestDistance && distance <= radiusKm) {
        closestDistance = distance;
        closestPoint = point;
      }
    }

    return closestPoint;
  }

  @override
  Future<List<TrackingSegment>> findSegmentsForCameraPoint(
      String cameraPointId) async {
    final allSegments = await getTrackingSegments();
    return allSegments
        .where((segment) =>
            segment.startCamera.id == cameraPointId ||
            segment.endCamera.id == cameraPointId)
        .toList();
  }
}
