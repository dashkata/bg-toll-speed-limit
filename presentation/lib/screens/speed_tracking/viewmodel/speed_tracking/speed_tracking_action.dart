import 'package:freezed_annotation/freezed_annotation.dart';

part 'speed_tracking_action.freezed.dart';

@freezed
sealed class SpeedTrackingAction with _$SpeedTrackingAction {
  // Permissions and UI actions
  const factory SpeedTrackingAction.toggleOverlay() = ToggleOverlay;
  const factory SpeedTrackingAction.toggleNotifications() = ToggleNotifications;
}
