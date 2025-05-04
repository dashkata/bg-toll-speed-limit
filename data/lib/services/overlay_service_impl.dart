import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:domain/model/tracking_segment.dart';
import 'package:domain/services/overlay_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayServiceImpl implements OverlayService {
  final _overlayDataStreamController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<bool> isPermissionGranted() async {
    try {
      return await FlutterOverlayWindow.isPermissionGranted();
    } catch (e) {
      log('Error checking overlay permission: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final permissions = await FlutterOverlayWindow.requestPermission();
      return permissions ?? false;
    } catch (e) {
      log('Error requesting overlay permission: $e');
      return false;
    }
  }

  @override
  Future<void> showOverlay() async {
    final isActive = await FlutterOverlayWindow.isActive();
    if (isActive) {
      return;
    }
    try {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: 'Speed Monitor',
        overlayContent: 'Showing current speed information',
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.left,
        alignment: OverlayAlignment.centerLeft,
        height: 300,
        width: 300,
      );

      log('Overlay window shown successfully');
    } catch (e) {
      log('Error showing overlay: $e');
    }
  }

  @override
  Future<void> closeOverlay() async {
    try {
      final isActive = await FlutterOverlayWindow.isActive();
      if (isActive) {
        await FlutterOverlayWindow.closeOverlay();
        log('Overlay window closed successfully');
      }
    } catch (e) {
      log('Error closing overlay: $e');
    }
  }

  @override
  Future<void> shareData({required double currentSpeed, required TrackingSegment? activeSegment}) async {
    try {
      final data = jsonEncode({
        'currentSpeed': currentSpeed,
        'activeSegment':
            activeSegment != null
                ? {
                  'id': activeSegment.id,
                  'startCamera': {
                    'name': activeSegment.startCamera.name,
                    'kilometerMark': activeSegment.startCamera.kilometerMark,
                  },
                  'endCamera': {
                    'name': activeSegment.endCamera.name,
                    'kilometerMark': activeSegment.endCamera.kilometerMark,
                  },
                  'distanceKm': activeSegment.distanceKm,
                  'speedLimit': activeSegment.speedLimit,
                  'currentAverageSpeed': activeSegment.currentAverageSpeed,
                }
                : null,
      });

      await FlutterOverlayWindow.shareData(data);
    } catch (e) {
      log('Error sharing data with overlay: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>> getOverlayDataStream() {
    return _overlayDataStreamController.stream;
  }

  void dispose() {
    _overlayDataStreamController.close();
  }
}
