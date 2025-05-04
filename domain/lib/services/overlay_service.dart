import '../model/tracking_segment.dart';

/// Service to handle the overlay window functionality
abstract class OverlayService {
  /// Check if overlay permission is granted
  Future<bool> isPermissionGranted();

  /// Request overlay permission
  Future<bool> requestPermission();

  /// Show the overlay window
  Future<void> showOverlay();

  /// Close the overlay window
  Future<void> closeOverlay();

  /// Share data with the overlay
  Future<void> shareData({
    required double currentSpeed,
    required TrackingSegment? activeSegment,
  });

  /// Listen for data sent from the overlay
  Stream<Map<String, dynamic>> getOverlayDataStream();
}
