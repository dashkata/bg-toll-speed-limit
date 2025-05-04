import '../model/camera_point.dart';
import '../model/highway.dart';
import '../model/lat_lng.dart';
import '../model/tracking_segment.dart';

/// Repository for accessing highway and camera point data
abstract class HighwayRepository {
  /// Get all highways
  Future<List<Highway>> getHighways();

  /// Get all camera points
  Future<List<CameraPoint>> getCameraPoints();

  /// Get camera points for a specific highway
  Future<List<CameraPoint>> getCameraPointsForHighway(String highwayId);

  /// Get all tracking segments
  Future<List<TrackingSegment>> getTrackingSegments();

  /// Get tracking segments for a specific highway
  Future<List<TrackingSegment>> getTrackingSegmentsForHighway(String highwayId);

  /// Find nearest camera point based on location
  Future<CameraPoint?> findNearestCameraPoint(LatLng location, double radiusKm);

  /// Find a tracking segment that contains the given camera point as start or end
  Future<List<TrackingSegment>> findSegmentsForCameraPoint(
      String cameraPointId);
}
