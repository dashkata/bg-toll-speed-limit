import 'package:domain/model/camera_point.dart';
import 'package:domain/model/highway.dart';

import '../../../cache/model/highway/camera_point_cache.dart';
import '../../../cache/model/highway/highway_cache.dart';

extension CacheMapper on HighwayCache {
  Highway toDomain() => Highway(
    id: id,
    name: name,
    code: code,
    speedLimit: speedLimit,
    cameraPoints: cameraPoints.map((e) => e.toDomain()).toList(),
  );
}

extension CameraPointCacheMapper on CameraPointCache {
  CameraPoint toDomain() {
    return CameraPoint(id: id, name: name, latitude: latitude, longitude: longitude, kilometerMark: kilometerMark);
  }
}
