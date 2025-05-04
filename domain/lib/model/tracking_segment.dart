import 'camera_point.dart';

/// Represents a segment between two cameras where speed is tracked
class TrackingSegment {
  const TrackingSegment({
    required this.id,
    required this.startCamera,
    required this.endCamera,
    required this.distanceKm,
    required this.speedLimit,
    this.entryTime,
    this.currentAverageSpeed,
  });
  final String id;
  final CameraPoint startCamera;
  final CameraPoint endCamera;
  final double distanceKm;
  final double speedLimit;
  final DateTime? entryTime;
  final double? currentAverageSpeed;

  /// Creates a copy of this segment with updated tracking data
  TrackingSegment copyWith({
    DateTime? entryTime,
    double? currentAverageSpeed,
  }) {
    return TrackingSegment(
      id: id,
      startCamera: startCamera,
      endCamera: endCamera,
      distanceKm: distanceKm,
      speedLimit: speedLimit,
      entryTime: entryTime ?? this.entryTime,
      currentAverageSpeed: currentAverageSpeed ?? this.currentAverageSpeed,
    );
  }
}
