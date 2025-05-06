import 'dart:async';

import 'package:domain/model/camera_point.dart';
import 'package:domain/model/highway.dart';
import 'package:domain/model/lat_lng.dart';
import 'package:domain/model/tracking_segment.dart';
import 'package:domain/repositories/highway_repository.dart';
import 'package:domain/services/location_service.dart';
import 'package:domain/services/notification_service.dart';
import 'package:domain/services/overlay_service.dart';
import 'package:domain/services/tracking_service.dart';

import '../../../utils/extensions.dart';
import '../../../utils/state_viewmodel.dart';
import 'speed_tracking/speed_tracking_action.dart';
import 'speed_tracking/speed_tracking_event.dart';
import 'speed_tracking/speed_tracking_state.dart';

final class SpeedTrackingViewModel extends StateViewModel<SpeedTrackingState, SpeedTrackingAction, SpeedTrackingEvent> {
  SpeedTrackingViewModel({
    required TrackingService trackingService,
    required NotificationService notificationService,
    required OverlayService overlayService,
    required LocationService locationService,
  }) : _trackingService = trackingService,
       _notificationService = notificationService,
       _overlayService = overlayService,
       _locationService = locationService,
       super(initialState: const SpeedTrackingState());
  final TrackingService _trackingService;
  final NotificationService _notificationService;
  final OverlayService _overlayService;
  final LocationService _locationService;

  // Camera detection settings

  // Subscribe to location and speed updates
  // StreamSubscription? _speedSubscription;
  // StreamSubscription? _locationSubscription;
  StreamSubscription? _segmentSubscription;
  Timer? _locationCheckTimer;
  Timer? _highwayCheckTimer;

  @override
  Future<void> init() async {
    try {
      await _trackingService.init();
      _locationService
          .getPositionStream()
          .listen(
            (position) => _handleLocationUpdate(LatLng(latitude: position.latitude, longitude: position.longitude)),
          )
          .disposeWith(this);
      // Initialize notification service
      // await _notificationService.initialize();

      // // Subscribe to speed updates
      _locationService.getSpeedStream().listen((position) => _handleSpeedUpdate(position.speed)).disposeWith(this);
      _startLocationCheckTimer();
      _setupHighwayTimer();
      // // Subscribe to segment updates
      // _segmentSubscription = _trackingService.getTrackingSegmentStream().listen(_handleSegmentUpdate);

      // // Start location timer to check for cameras
      // _startLocationCheckTimer();

      // // Update location
      // final location = await _trackingService.getCurrentLocation();

      // // Set initial speed
      // final speed = await _trackingService.getCurrentSpeed();

      // // Check if any segment is active already
      // final activeSegment = _trackingService.getCurrentSegment();

      // updateState(
      //   state.copyWith(
      //     currentSpeed: speed,
      //     currentLocation: location,
      //     activeSegment: activeSegment,
      //     isAutoTrackingEnabled: true,
      //     isLoading: false,
      //   ),
      // );

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

  // TODO implement a function that checks if the user is on a highway until it finds one

  Highway? get currentHighway => _trackingService.currentHighway;

  @override
  Future<void> submitAction(SpeedTrackingAction action) async =>
      action.when(toggleOverlay: _toggleOverlay, toggleNotifications: _toggleNotifications);

  // Private methods

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
    // if (state.isOverlayActive) {
    //   _overlayService.shareData(currentSpeed: speed, activeSegment: state.activeSegment);
    // }

    // Check for speed warnings
    final segment = state.activeSegment;
    if (segment != null && state.isNotificationEnabled) {
      final speedLimit = segment.speedLimit;

      if (speed > speedLimit + 10) {
        submitEvent(SpeedTrackingEvent.showSpeedWarning(speed, speedLimit));

        _notificationService.showSpeedAlert(
          currentSpeed: speed,
          speedLimit: speedLimit,
          segmentName: '${segment.startCamera.name} → ${segment.endCamera.name}',
        );
      }
    }
  }

  void _handleLocationUpdate(LatLng location) {
    updateState(state.copyWith(currentLocation: location));
  }

  // void _handleSegmentUpdate(TrackingSegment? segment) {
  //   final previousSegment = state.activeSegment;
  //   updateState(state.copyWith(activeSegment: segment));

  //   // Update overlay if active
  //   if (state.isOverlayActive) {
  //     _overlayService.shareData(currentSpeed: state.currentSpeed, activeSegment: segment);
  //   }

  //   // If a new segment started, show a notification
  //   if (segment != null && (previousSegment == null || previousSegment.id != segment.id)) {
  //     _notificationService.showSegmentTrackingStarted(segment: segment);
  //     submitEvent(
  //       SpeedTrackingEvent.showError('Entered segment: ${segment.startCamera.name} → ${segment.endCamera.name}'),
  //     );
  //   }

  //   // If segment ended, show a notification
  //   if (segment == null && previousSegment != null) {
  //     submitEvent(const SpeedTrackingEvent.showError('Exited segment'));
  //   }
  // }

  void _startLocationCheckTimer() {
    _locationCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final cameraApproaching = await _trackingService.isCameraApproaching();
      if (cameraApproaching != null) {
        submitEvent(
          SpeedTrackingEvent.showCameraApproaching(cameraApproaching.camera.name, cameraApproaching.distance),
        );

        if (state.isNotificationEnabled) {
          await _notificationService.showCameraApproachingAlert(
            cameraName: cameraApproaching.camera.name,
            distanceKm: cameraApproaching.distance,
          );
        }
      }
    });
  }

  void _setupHighwayTimer() {
    _highwayCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final highway = await _trackingService.findHighwayByNearestCamera();
      if (highway != null) {
        updateState(state.copyWith(highway: highway));
        submitEvent(SpeedTrackingEvent.showHighway(highway.name));
        // TODO implement a notification for highway
        _highwayCheckTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _segmentSubscription?.cancel();
    _locationCheckTimer?.cancel();
    super.dispose();
  }
}
