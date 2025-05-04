import 'package:data/services/notification_service_impl.dart';
import 'package:data/services/overlay_service_impl.dart';
import 'package:data/services/tracking_service_impl.dart';
import 'package:domain/services/auth.dart';
import 'package:domain/services/cache_service.dart';
import 'package:domain/services/localization_service.dart';
import 'package:domain/services/notification_service.dart';
import 'package:domain/services/overlay_service.dart';
import 'package:domain/services/theme_service.dart';
import 'package:domain/services/tracking_service.dart';

import '../locator.dart';

void service() {
  locator
    ///Services
    ..registerLazySingleton(() => CacheService(settingsRepository: locator()))
    ..registerLazySingleton(Auth.new)
    ..registerLazySingleton(() => ThemeService(settingsRepository: locator(), cacheService: locator()))
    ..registerLazySingleton(() => LocalizationService(settingsRepository: locator(), cacheService: locator()))
    ..registerLazySingleton<TrackingService>(() => TrackingServiceImpl(highwayRepository: locator()))
    ..registerLazySingleton<NotificationService>(NotificationServiceImpl.new)
    ..registerLazySingleton<OverlayService>(OverlayServiceImpl.new);
}
