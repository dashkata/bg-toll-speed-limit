import 'package:freezed_annotation/freezed_annotation.dart';

part 'speed_tracking_action.freezed.dart';

@freezed
sealed class SpeedTrackingAction with _$SpeedTrackingAction {
  // Initial actions
  const factory SpeedTrackingAction.startTracking() = StartTracking;
  const factory SpeedTrackingAction.stopTracking() = StopTracking;

  // Permissions and UI actions
  const factory SpeedTrackingAction.requestLocationPermission() = RequestLocationPermission;
  const factory SpeedTrackingAction.toggleOverlay() = ToggleOverlay;
  const factory SpeedTrackingAction.toggleNotifications() = ToggleNotifications;
  const factory SpeedTrackingAction.toggleAutoTracking() = ToggleAutoTracking;
}
