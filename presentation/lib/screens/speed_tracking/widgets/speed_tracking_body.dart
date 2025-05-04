import 'package:domain/model/highway.dart';
import 'package:domain/model/lat_lng.dart';
import 'package:domain/model/tracking_segment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/speed_tracking/speed_tracking_action.dart';
import '../viewmodel/speed_tracking/speed_tracking_state.dart';
import '../viewmodel/speed_tracking_view_model.dart';
import 'action_buttons.dart';
import 'active_segment_card.dart';
import 'current_speed_card.dart';
import 'highway_info_card.dart';
import 'location_card.dart';

class SpeedTrackingBody extends StatelessWidget {
  const SpeedTrackingBody({required this.submitAction, super.key});
  final Function(SpeedTrackingAction) submitAction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Selector<SpeedTrackingViewModel, SpeedTrackingState>(
                      selector: (context, viewModel) => viewModel.state,
                      builder:
                          (context, state, child) =>
                              CurrentSpeedCard(currentSpeed: state.currentSpeed, speedColor: _getSpeedColor(state)),
                    ),
                    const SizedBox(height: 16),
                    Selector<SpeedTrackingViewModel, (TrackingSegment?, Highway?)>(
                      selector: (context, viewModel) => (viewModel.state.activeSegment, viewModel.state.currentHighway),
                      builder: (context, data, child) {
                        final (activeSegment, currentHighway) = data;
                        return HighwayInfoCard(activeSegment: activeSegment, currentHighway: currentHighway);
                      },
                    ),
                    const SizedBox(height: 16),
                    Selector<SpeedTrackingViewModel, TrackingSegment?>(
                      selector: (context, viewModel) => viewModel.state.activeSegment,
                      builder: (context, segment, child) => ActiveSegmentCard(segment: segment),
                    ),
                    const SizedBox(height: 16),
                    Selector<SpeedTrackingViewModel, LatLng>(
                      selector: (context, viewModel) => viewModel.state.currentLocation,
                      builder: (context, location, child) => LocationCard(location: location),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Selector<SpeedTrackingViewModel, (TrackingSegment?, bool)>(
              selector: (context, viewModel) => (viewModel.state.activeSegment, viewModel.state.isAutoTrackingEnabled),
              builder: (context, data, child) {
                final (activeSegment, isAutoTrackingEnabled) = data;
                return ActionButtons(
                  activeSegment: activeSegment,
                  isAutoTrackingEnabled: isAutoTrackingEnabled,
                  submitAction: submitAction,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getSpeedColor(SpeedTrackingState state) {
    final speed = state.currentSpeed;
    final segment = state.activeSegment;
    final speedLimit = segment?.speedLimit ?? 130.0;

    if (speed > speedLimit + 10) {
      return Colors.red;
    } else if (speed > speedLimit) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
