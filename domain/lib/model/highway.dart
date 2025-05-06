import 'camera_point.dart';

class Highway {
  const Highway({
    required this.id,
    required this.name,
    required this.code,
    required this.speedLimit,
    required this.cameraPoints,
  });
  final String id;
  final String name;
  final String code;
  final double speedLimit;
  final List<CameraPoint> cameraPoints;
}
