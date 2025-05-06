import '../model/tracking_segment.dart';

/// Service to handle notifications for the app
abstract class NotificationService {
  /// Initialize the notification service
  Future<void> initialize();

  /// Request notification permissions
  Future<bool> requestPermissions();

  /// Show a speed alert notification
  Future<void> showSpeedAlert({
    required double currentSpeed,
    required double speedLimit,
    required String segmentName,
  });

  /// Show a camera approaching notification
  Future<void> showCameraApproachingAlert({
    required String cameraName,
    required double distanceKm,
  });

  

  /// Show a segment tracking started notification
  Future<void> showSegmentTrackingStarted({
    required TrackingSegment segment,
  });

  /// Show a segment tracking ended notification
  Future<void> showSegmentTrackingEnded({
    required TrackingSegment segment,
    required double averageSpeed,
    required bool isOverSpeedLimit,
  });

  /// Show a general information notification
  Future<void> showInfoNotification({
    required String title,
    required String body,
  });
}
