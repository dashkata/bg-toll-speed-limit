import 'highway.dart';

/// Represents a camera point on a highway
class CameraPoint {
  const CameraPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.highway,
    required this.kilometerMark,
  });
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final Highway highway;
  final int kilometerMark;
}
