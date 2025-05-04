import 'package:domain/model/tracking_segment.dart';
import 'package:flutter/material.dart';

import '../viewmodel/speed_tracking/speed_tracking_action.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    required this.activeSegment,
    required this.submitAction,
    required this.isAutoTrackingEnabled,
    super.key,
  });
  final TrackingSegment? activeSegment;
  final void Function(SpeedTrackingAction) submitAction;
  final bool isAutoTrackingEnabled;

  @override
  Widget build(BuildContext context) {
    // If auto-tracking is enabled, we should show a different message
    if (isAutoTrackingEnabled) {
      return Column(
        children: [
          if (activeSegment == null)
            Text(
              'Automatic tracking enabled. Waiting for segment detection...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic),
            )
          else
            ElevatedButton.icon(
              onPressed: () => submitAction(const SpeedTrackingAction.stopTracking()),
              icon: const Icon(Icons.stop),
              label: const Text('Stop Tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          const SizedBox(height: 8),
        ],
      );
    }

    // Manual tracking buttons (when auto-tracking is disabled)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (activeSegment == null)
          ElevatedButton.icon(
            onPressed: () => submitAction(const SpeedTrackingAction.startTracking()),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Tracking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: () => submitAction(const SpeedTrackingAction.stopTracking()),
            icon: const Icon(Icons.stop),
            label: const Text('Stop Tracking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
      ],
    );
  }
}
