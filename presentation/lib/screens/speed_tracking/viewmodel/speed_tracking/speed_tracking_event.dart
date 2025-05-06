import 'package:domain/model/tracking_segment.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'speed_tracking_event.freezed.dart';

@freezed
sealed class SpeedTrackingEvent with _$SpeedTrackingEvent {
  const factory SpeedTrackingEvent.showError(String message) = ShowError;
  const factory SpeedTrackingEvent.showInfo(String message) = ShowInfo;
  const factory SpeedTrackingEvent.showSpeedWarning(double currentSpeed, double speedLimit) = ShowSpeedWarning;
  const factory SpeedTrackingEvent.showCameraApproaching(String cameraName, double distanceKm) = ShowCameraApproaching;
  const factory SpeedTrackingEvent.showHighway(String highwayName) = ShowHighway;
  const factory SpeedTrackingEvent.showPermissionRequired() = ShowPermissionRequired;
  const factory SpeedTrackingEvent.showSegmentStarted(TrackingSegment segment) = ShowSegmentStarted;
  const factory SpeedTrackingEvent.showSegmentEnded() = ShowSegmentEnded;
}
