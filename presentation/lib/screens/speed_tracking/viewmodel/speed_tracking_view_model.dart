import 'dart:async';

import 'package:domain/model/camera_point.dart';
import 'package:domain/model/lat_lng.dart';
import 'package:domain/model/tracking_segment.dart';
import 'package:domain/repositories/highway_repository.dart';
import 'package:domain/services/notification_service.dart';
import 'package:domain/services/overlay_service.dart';
import 'package:domain/services/tracking_service.dart';

import '../../../utils/state_viewmodel.dart';
import 'speed_tracking/speed_tracking_action.dart';
import 'speed_tracking/speed_tracking_event.dart';
import 'speed_tracking/speed_tracking_state.dart';

final class SpeedTrackingViewModel extends StateViewModel<SpeedTrackingState, SpeedTrackingAction, SpeedTrackingEvent> {
  SpeedTrackingViewModel({
    required TrackingService trackingService,
    required HighwayRepository highwayRepository,
    required NotificationService notificationService,
    required OverlayService overlayService,
  }) : _trackingService = trackingService,
       _highwayRepository = highwayRepository,
       _notificationService = notificationService,
       _overlayService = overlayService,
       super(initialState: const SpeedTrackingState());
  final TrackingService _trackingService;
  final HighwayRepository _highwayRepository;
  final NotificationService _notificationService;
  final OverlayService _overlayService;

  // Camera detection settings
  static const double _cameraDetectionRadiusKm = 0.5; // 500 meters
  static const double _cameraWarningDistanceKm = 2.0; // 2 km advance warning

  // Subscribe to location and speed updates
  StreamSubscription? _speedSubscription;
  StreamSubscription? _segmentSubscription;
  Timer? _locationCheckTimer;

  @override
  Future<void> init() async {
    try {
      // Initialize notification service
      await _notificationService.initialize();

      // Subscribe to speed updates
      _speedSubscription = _trackingService.getSpeedStream().listen(_handleSpeedUpdate);

      // Subscribe to segment updates
      _segmentSubscription = _trackingService.getTrackingSegmentStream().listen(_handleSegmentUpdate);

      // Start location timer to check for cameras
      _startLocationCheckTimer();

      // Update location
      final location = await _trackingService.getCurrentLocation();

      // Set initial speed
      final speed = await _trackingService.getCurrentSpeed();

      // Check if any segment is active already
      final activeSegment = _trackingService.getCurrentSegment();

      updateState(
        state.copyWith(
          currentSpeed: speed,
          currentLocation: location,
          activeSegment: activeSegment,
          isAutoTrackingEnabled: true,
          isLoading: false,
        ),
      );

      // Check overlay permission on Android
      // if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && _overlayService != null) {
      //   final isPermissionGranted = await _overlayService.isPermissionGranted();
      //   if (isPermissionGranted) {
      //     await _overlayService.showOverlay();
      //     updateState(state.copyWith(isOverlayActive: true));
      //   }
      // }
    } catch (e) {
      submitEvent(SpeedTrackingEvent.showError('Failed to initialize: $e'));
      updateState(state.copyWith(error: 'Failed to initialize tracking', isLoading: false));
    }
  }

  @override
  Future<void> submitAction(SpeedTrackingAction action) async {
    switch (action) {
      case StartTracking():
        // No longer needed with automatic tracking
        submitEvent(
          const SpeedTrackingEvent.showError(
            'Automatic tracking is active. The app will detect segments automatically.',
          ),
        );
        break;
      case StopTracking():
        // Still useful to manually stop tracking if needed
        await _stopTracking();
        break;
      case RequestLocationPermission():
        await _requestLocationPermission();
        break;
      case ToggleOverlay():
        await _toggleOverlay();
        break;
      case ToggleNotifications():
        await _toggleNotifications();
        break;
      case ToggleAutoTracking():
        await _toggleAutoTracking();
        break;
    }
  }

  // Private methods

  Future<void> _toggleAutoTracking() async {
    final newValue = !state.isAutoTrackingEnabled;

    // Set the auto tracking mode in the service
    (_trackingService as dynamic).setAutoTracking(newValue);

    // Update state
    updateState(state.copyWith(isAutoTrackingEnabled: newValue));

    // Show confirmation to user
    final message =
        newValue
            ? 'Automatic tracking enabled. The app will detect segments automatically.'
            : 'Automatic tracking disabled. You need to manually start tracking.';

    submitEvent(SpeedTrackingEvent.showError(message));
  }

  Future<void> _stopTracking() async {
    if (state.activeSegment == null) return;

    updateState(state.copyWith(isLoading: true));

    try {
      final segment = state.activeSegment;
      if (segment == null) {
        submitEvent(const SpeedTrackingEvent.showError('No active segment'));
        return;
      }

      final averageSpeed = await _trackingService.endSegmentTracking(segment);

      final isOverLimit = averageSpeed > segment.speedLimit;

      await _notificationService.showSegmentTrackingEnded(
        segment: segment,
        averageSpeed: averageSpeed,
        isOverSpeedLimit: isOverLimit,
      );

      updateState(state.copyWith(activeSegment: null));
    } catch (e) {
      submitEvent(SpeedTrackingEvent.showError('Failed to stop tracking: $e'));
    } finally {
      updateState(state.copyWith(isLoading: false));
    }
  }

  Future<void> _requestLocationPermission() async {}

  Future<void> _toggleOverlay() async {
    if (state.isOverlayActive) {
      await _overlayService.closeOverlay();
      updateState(state.copyWith(isOverlayActive: false));
    } else {
      final isPermissionGranted = await _overlayService.isPermissionGranted();

      if (!isPermissionGranted) {
        final granted = await _overlayService.requestPermission();

        if (!granted) {
          submitEvent(const SpeedTrackingEvent.showPermissionRequired());
          return;
        }
      }

      await _overlayService.showOverlay();
      updateState(state.copyWith(isOverlayActive: true));
    }
  }

  Future<void> _toggleNotifications() async {
    final currentValue = state.isNotificationEnabled;

    if (!currentValue) {
      final granted = await _notificationService.requestPermissions();

      if (!granted) {
        submitEvent(const SpeedTrackingEvent.showPermissionRequired());
        return;
      }
    }

    updateState(state.copyWith(isNotificationEnabled: !currentValue));
  }

  void _handleSpeedUpdate(double speed) {
    updateState(state.copyWith(currentSpeed: speed));

    // Update overlay if active
    if (state.isOverlayActive) {
      _overlayService.shareData(currentSpeed: speed, activeSegment: state.activeSegment);
    }

    // Check for speed warnings
    if (state.activeSegment != null && state.isNotificationEnabled) {
      final speedLimit = state.activeSegment!.speedLimit;

      if (speed > speedLimit + 5) {
        // 5 km/h buffer
        submitEvent(SpeedTrackingEvent.showSpeedWarning(speed, speedLimit));

        _notificationService.showSpeedAlert(
          currentSpeed: speed,
          speedLimit: speedLimit,
          segmentName: '${state.activeSegment!.startCamera.name} → ${state.activeSegment!.endCamera.name}',
        );
      }
    }
  }

  void _handleSegmentUpdate(TrackingSegment? segment) {
    final previousSegment = state.activeSegment;
    updateState(state.copyWith(activeSegment: segment));

    // Update overlay if active
    if (state.isOverlayActive) {
      _overlayService.shareData(currentSpeed: state.currentSpeed, activeSegment: segment);
    }

    // If a new segment started, show a notification
    if (segment != null && (previousSegment == null || previousSegment.id != segment.id)) {
      _notificationService.showSegmentTrackingStarted(segment: segment);
      submitEvent(
        SpeedTrackingEvent.showError('Entered segment: ${segment.startCamera.name} → ${segment.endCamera.name}'),
      );
    }

    // If segment ended, show a notification
    if (segment == null && previousSegment != null) {
      submitEvent(const SpeedTrackingEvent.showError('Exited segment'));
    }
  }

  void _startLocationCheckTimer() {
    // Check location every 10 seconds to see if we're near cameras
    _locationCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final location = await _trackingService.getCurrentLocation();
        updateState(state.copyWith(currentLocation: location));

        // Check for nearby cameras
        final allCameras = await _highwayRepository.getCameraPoints();

        for (final camera in allCameras) {
          final distance = await _calculateDistanceToCameraKm(camera, location.latitude, location.longitude);

          // If we're approaching a camera, show warning
          if (distance <= _cameraWarningDistanceKm) {
            submitEvent(SpeedTrackingEvent.showCameraApproaching(camera.name, distance));

            if (state.isNotificationEnabled) {
              _notificationService.showCameraApproachingAlert(cameraName: camera.name, distanceKm: distance);
            }

            break; // Only show one camera warning at a time
          }
        }
      } catch (e) {
        // Ignore location check errors
      }
    });
  }

  Future<double> _calculateDistanceToCameraKm(CameraPoint camera, double latitude, double longitude) async {
    // Use a simple approach for now - in a real implementation you would likely
    // have a more sophisticated distance calculation in the repository
    try {
      // Simple Haversine formula could be used here
      // For demonstration, we're using a placeholder
      return 1.0; // Simulate a 1km distance for demo
    } catch (e) {
      return double.infinity;
    }
  }

  @override
  void dispose() {
    _speedSubscription?.cancel();
    _segmentSubscription?.cancel();
    _locationCheckTimer?.cancel();
    super.dispose();
  }
}
