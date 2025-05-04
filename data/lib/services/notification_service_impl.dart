import 'package:domain/model/tracking_segment.dart';
import 'package:domain/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Various notification IDs
  static const int _speedAlertId = 1;
  static const int _cameraApproachingId = 2;
  static const int _segmentTrackingStartId = 3;
  static const int _segmentTrackingEndId = 4;
  static const int _infoNotificationId = 5;

  @override
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  @override
  Future<bool> requestPermissions() async {
    // iOS permissions
    final bool? iosResult = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Android permissions (for Android 13+)
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? androidResult = await androidPlugin?.requestNotificationsPermission();

    return iosResult ?? androidResult ?? false;
  }

  @override
  Future<void> showSpeedAlert({
    required double currentSpeed,
    required double speedLimit,
    required String segmentName,
  }) async {
    await _showNotification(
      id: _speedAlertId,
      title: '⚠️ Speed Alert',
      body:
          'Current speed: ${currentSpeed.toStringAsFixed(1)} km/h\nSpeed limit: ${speedLimit.toStringAsFixed(0)} km/h',
      priority: Priority.high,
    );
  }

  @override
  Future<void> showCameraApproachingAlert({
    required String cameraName,
    required double distanceKm,
  }) async {
    await _showNotification(
      id: _cameraApproachingId,
      title: '📸 Camera Approaching',
      body: '$cameraName in ${distanceKm.toStringAsFixed(1)} km',
      priority: Priority.max,
    );
  }

  @override
  Future<void> showSegmentTrackingStarted({
    required TrackingSegment segment,
  }) async {
    await _showNotification(
      id: _segmentTrackingStartId,
      title: '🚗 Segment Tracking Started',
      body:
          '${segment.startCamera.name} → ${segment.endCamera.name}\nSpeed limit: ${segment.speedLimit.toStringAsFixed(0)} km/h',
      priority: Priority.low,
    );
  }

  @override
  Future<void> showSegmentTrackingEnded({
    required TrackingSegment segment,
    required double averageSpeed,
    required bool isOverSpeedLimit,
  }) async {
    final icon = isOverSpeedLimit ? '⚠️' : '✅';
    final status = isOverSpeedLimit ? 'Over limit' : 'Within limit';

    await _showNotification(
      id: _segmentTrackingEndId,
      title: '$icon Segment Completed: $status',
      body: 'Average speed: ${averageSpeed.toStringAsFixed(1)} km/h\n'
          'Limit: ${segment.speedLimit.toStringAsFixed(0)} km/h',
      priority: isOverSpeedLimit ? Priority.high : Priority.defaultPriority,
    );
  }

  @override
  Future<void> showInfoNotification({
    required String title,
    required String body,
  }) async {
    await _showNotification(
      id: _infoNotificationId,
      title: title,
      body: body,
      priority: Priority.low,
    );
  }

  // Private helper method
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required Priority priority,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'speed_monitor_channel',
      'Speed Monitor',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
    );
  }
}
