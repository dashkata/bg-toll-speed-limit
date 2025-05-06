import 'package:hive/hive.dart';

import 'camera_point_cache.dart';

@HiveType(typeId: 21)
class HighwayCache extends HiveObject {
  HighwayCache({
    required this.id,
    required this.name,
    required this.code,
    required this.speedLimit,
    required this.cameraPoints,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String code;
  @HiveField(3)
  final double speedLimit;
  @HiveField(4)
  final List<CameraPointCache> cameraPoints;
}
