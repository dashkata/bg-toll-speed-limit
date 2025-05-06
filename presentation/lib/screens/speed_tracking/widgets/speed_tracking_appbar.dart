import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/speed_tracking/speed_tracking_action.dart';
import '../viewmodel/speed_tracking_view_model.dart';
import 'toolbar_actions.dart';

class SpeedTrackingAppbar extends StatelessWidget implements PreferredSizeWidget {
  const SpeedTrackingAppbar({required this.submitAction, super.key});
  final void Function(SpeedTrackingAction) submitAction;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Speed Monitor'),
      actions: [
        Selector<SpeedTrackingViewModel, bool>(
          selector: (context, viewModel) => viewModel.state.isNotificationEnabled,
          builder:
              (context, isNotificationsEnabled, child) => NotificationToggle(
                isNotificationsEnabled: isNotificationsEnabled,
                toggleNotifications: () => submitAction(const SpeedTrackingAction.toggleNotifications()),
              ),
        ),
        if (!Platform.isIOS)
          Selector<SpeedTrackingViewModel, bool>(
            selector: (context, viewModel) => viewModel.state.isOverlayActive,
            builder:
                (context, isOverlayActive, child) => OverlayToggle(
                  isOverlayActive: isOverlayActive,
                  toggleOverlay: () => submitAction(const SpeedTrackingAction.toggleOverlay()),
                ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
