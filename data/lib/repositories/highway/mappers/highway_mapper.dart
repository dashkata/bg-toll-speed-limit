import 'package:domain/model/camera_point.dart';
import 'package:domain/model/highway.dart';

import '../../../cache/model/highway/camera_point_cache.dart';
import '../../../cache/model/highway/highway_cache.dart';
import '../../../source/model/camera_point_response.dart';
import '../../../source/model/highway_response.dart';

extension HighwayResponseMapper on HighwayResponse {
  Highway toDomain() => Highway(
        id: id,
        name: name,
        code: code,
        speedLimit: speedLimit,
        cameraPoints: cameraPoints.map((e) => e.toDomain()).toList(),
      );

  HighwayCache toCache() => HighwayCache(
        id: id,
        name: name,
        code: code,
        speedLimit: speedLimit,
        cameraPoints: cameraPoints.map((e) => e.toCache()).toList(),
      );
}

extension CameraPointResponseMapper on CameraPointResponse {
  CameraPoint toDomain() => CameraPoint(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        kilometerMark: kilometerMark,
      );

  CameraPointCache toCache() => CameraPointCache(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        kilometerMark: kilometerMark,
      );
}
