import 'package:data/services/notification_service_impl.dart';
import 'package:data/services/overlay_service_impl.dart';
import 'package:data/services/simulated_tracking_service.dart';
import 'package:data/services/tracking_service_impl.dart';
import 'package:domain/services/auth.dart';
import 'package:domain/services/cache_service.dart';
import 'package:domain/services/localization_service.dart';
import 'package:domain/services/notification_service.dart';
import 'package:domain/services/overlay_service.dart';
import 'package:domain/services/theme_service.dart';
import 'package:domain/services/tracking_service.dart';

import '../locator.dart';

// Flag to enable simulation mode
const bool useSimulation = true;

// Simulation speed settings
const double simulationSpeedKmh = 300.0; // Increased from 100 to 300 for faster camera passing

void service() {
  locator
    ///Services
    ..registerLazySingleton(() => CacheService(settingsRepository: locator()))
    ..registerLazySingleton(Auth.new)
    ..registerLazySingleton(() => ThemeService(settingsRepository: locator(), cacheService: locator()))
    ..registerLazySingleton(() => LocalizationService(settingsRepository: locator(), cacheService: locator()))
    // Conditionally register either the real tracking service or the simulated one
    ..registerLazySingleton<TrackingService>(
      () =>
          useSimulation
              ? SimulatedTrackingService(
                highwayRepository: locator(),
                simulatedSpeedKmh: simulationSpeedKmh, // Using the configurable speed
              )
              : TrackingServiceImpl(highwayRepository: locator()),
    )
    ..registerLazySingleton<NotificationService>(NotificationServiceImpl.new)
    ..registerLazySingleton<OverlayService>(OverlayServiceImpl.new);
}
