import 'package:domain/services/tracking_service.dart';
import 'package:flutter/material.dart';

import '../../app/di/locator.dart';
import '../../utils/viewmodel_builder.dart';
import '../../utils/viewmodel_event_handler.dart';
import 'viewmodel/speed_tracking/speed_tracking_event.dart';
import 'viewmodel/speed_tracking_view_model.dart';
import 'widgets/simulation_controls.dart';
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
            onEvent: (event) => _handleViewModelEvent(context, event),
            child: Column(
              children: [
                // Show simulation controls if in simulation mode
                if (viewModel.isSimulation)
                  SimulationControls(
                    trackingService: locator<TrackingService>(),
                    isAutoTrackingEnabled: viewModel.state.isAutoTrackingEnabled,
                  ),
                Expanded(child: SpeedTrackingBody(submitAction: viewModel.submitAction)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleViewModelEvent(BuildContext context, SpeedTrackingEvent event) {
    event.when(
      showError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
      },
      showInfo: (message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.blue));
      },
      showSpeedWarning: (currentSpeed, speedLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Warning: Speed $currentSpeed km/h exceeds limit of $speedLimit km/h'),
            backgroundColor: Colors.orange,
          ),
        );
      },
      showCameraApproaching: (cameraName, distanceKm) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera approaching: $cameraName (${distanceKm.toStringAsFixed(1)} km away)'),
            backgroundColor: Colors.blue,
          ),
        );
      },
      showPermissionRequired: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission required to use this feature'), backgroundColor: Colors.red),
        );
      },
      showSegmentStarted: (segment) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Segment started: ${segment.startCamera.name} → ${segment.endCamera.name}'),
            backgroundColor: Colors.green,
          ),
        );
      },
      showSegmentEnded: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Segment tracking ended'), backgroundColor: Colors.blue));
      },
    );
  }
}
