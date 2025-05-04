import 'package:flutter/material.dart';

class NotificationToggle extends StatelessWidget {
  const NotificationToggle({required this.isNotificationsEnabled, required this.toggleNotifications, super.key});

  final bool isNotificationsEnabled;
  final VoidCallback toggleNotifications;

  @override
  Widget build(BuildContext context) {
    final isEnabled = isNotificationsEnabled;

    return IconButton(
      onPressed: toggleNotifications,
      icon: Icon(
        isEnabled ? Icons.notifications_active : Icons.notifications_off,
        color: isEnabled ? Colors.green : Colors.grey,
      ),
      tooltip: isEnabled ? 'Disable Notifications' : 'Enable Notifications',
    );
  }
}

class OverlayToggle extends StatelessWidget {
  const OverlayToggle({required this.isOverlayActive, required this.toggleOverlay, super.key});

  final bool isOverlayActive;
  final VoidCallback toggleOverlay;

  @override
  Widget build(BuildContext context) {
    final isEnabled = isOverlayActive;

    return IconButton(
      onPressed: toggleOverlay,
      icon: Icon(
        isEnabled ? Icons.picture_in_picture : Icons.picture_in_picture_alt,
        color: isEnabled ? Colors.green : Colors.grey,
      ),
      tooltip: isEnabled ? 'Disable Overlay' : 'Enable Overlay',
    );
  }
}

class AutoTrackingToggle extends StatelessWidget {
  const AutoTrackingToggle({required this.isAutoTrackingEnabled, required this.toggleAutoTracking, super.key});

  final bool isAutoTrackingEnabled;
  final VoidCallback toggleAutoTracking;

  @override
  Widget build(BuildContext context) {
    final isEnabled = isAutoTrackingEnabled;

    return IconButton(
      onPressed: toggleAutoTracking,
      icon: Icon(isEnabled ? Icons.auto_mode : Icons.auto_mode_outlined, color: isEnabled ? Colors.green : Colors.grey),
      tooltip: isEnabled ? 'Disable Auto-Tracking' : 'Enable Auto-Tracking',
    );
  }
}
