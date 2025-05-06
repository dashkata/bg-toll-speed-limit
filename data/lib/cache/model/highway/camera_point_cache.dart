import 'package:hive/hive.dart';

part 'camera_point_cache.g.dart';

@HiveType(typeId: 22)
class CameraPointCache extends HiveObject {
  CameraPointCache({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.kilometerMark,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double latitude;
  @HiveField(3)
  final double longitude;
  @HiveField(4)
  final int kilometerMark;
}
