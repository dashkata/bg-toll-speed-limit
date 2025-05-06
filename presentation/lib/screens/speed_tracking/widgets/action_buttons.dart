import 'package:domain/model/tracking_segment.dart';
import 'package:flutter/material.dart';

import '../viewmodel/speed_tracking/speed_tracking_action.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    required this.activeSegment,
    required this.submitAction,
    super.key,
  });
  final TrackingSegment? activeSegment;
  final void Function(SpeedTrackingAction) submitAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (activeSegment == null)
          Text(
            'Automatic tracking enabled. Waiting for segment detection...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
      ],
    );
  }
}
