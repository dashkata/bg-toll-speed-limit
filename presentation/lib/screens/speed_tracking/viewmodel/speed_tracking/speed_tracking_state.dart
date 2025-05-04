import 'package:domain/model/lat_lng.dart';
import 'package:domain/model/tracking_segment.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'speed_tracking_state.freezed.dart';

@freezed
class SpeedTrackingState with _$SpeedTrackingState {
  const factory SpeedTrackingState({
    @Default(0.0) double currentSpeed,
    @Default(LatLng(latitude: 0.0, longitude: 0.0)) LatLng currentLocation,
    TrackingSegment? activeSegment,
    @Default(false) bool isLoading,
    @Default(false) bool isOverlayActive,
    @Default(false) bool isNotificationEnabled,
    @Default(true) bool isAutoTrackingEnabled,
    @Default('') String error,
  }) = _SpeedTrackingState;
}
