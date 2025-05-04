import '../model/camera_point.dart';
import '../model/lat_lng.dart';
import '../model/tracking_segment.dart';

/// Service that handles speed tracking functionality
abstract class TrackingService {
  /// Get the current speed in km/h
  Future<double> getCurrentSpeed();

  /// Get the current location as {latitude, longitude}
  Future<LatLng> getCurrentLocation();

  /// Check if the user has entered a camera point's detection area
  Future<bool> isNearCameraPoint(CameraPoint point, double radiusMeters);

  /// Start tracking a segment
  Future<void> startSegmentTracking(TrackingSegment segment);

  /// End tracking a segment and get the average speed
  Future<double> endSegmentTracking(TrackingSegment segment);

  /// Get the current active segment being tracked
  TrackingSegment? getCurrentSegment();

  /// Get a stream of speed updates
  Stream<double> getSpeedStream();

  /// Get a stream of tracking segment updates
  Stream<TrackingSegment?> getTrackingSegmentStream();
}
