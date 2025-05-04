import 'package:domain/model/tracking_segment.dart';
import 'package:flutter/material.dart';

import '../../app/di/locator.dart';
import '../../utils/viewmodel_builder.dart';
import '../../utils/viewmodel_event_handler.dart';
import 'viewmodel/speed_tracking/speed_tracking_event.dart';
import 'viewmodel/speed_tracking_view_model.dart';
import 'widgets/speed_tracking_appbar.dart';
import 'widgets/speed_tracking_body.dart';

class SpeedTrackingScreen extends StatelessWidget {
  const SpeedTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SpeedTrackingViewModel>(
      viewModelBuilder: locator,
      builder: (context, viewModel) {
        return Scaffold(
          appBar: SpeedTrackingAppbar(submitAction: viewModel.submitAction),
          body: ViewModelEventHandler<SpeedTrackingEvent>(
            viewModel: viewModel,
            onEvent: (event) {
              event.when(
                showError: (message) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
                },
                showPermissionRequired: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Permission Required'),
                          content: const Text(
                            'This app requires permissions to function correctly. Please grant the necessary permissions in settings.',
                          ),
                          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
                        ),
                  );
                },
                showSpeedWarning: (speed, limit) {},
                showCameraApproaching: (name, distance) {},
                showInfo: (String message) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                },
                showSegmentStarted: (TrackingSegment segment) {},
                showSegmentEnded: () {},
              );
            },
            child: SpeedTrackingBody(submitAction: viewModel.submitAction),
          ),
        );
      },
    );
  }
}
