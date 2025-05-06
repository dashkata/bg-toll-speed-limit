import 'package:presentation/app/main_viewmodel.dart';
import 'package:presentation/controllers/theme_controller.dart';
import 'package:presentation/screens/speed_tracking/viewmodel/speed_tracking_view_model.dart';

import '../locator.dart';

void viewmodel() {
  locator
    ///Controllers
    ..registerLazySingleton(() => ThemeController(themeService: locator()))
    ///View models
    ..registerFactory(
      () => MainViewModel(
        localizationService: locator(),
        themeController: locator(),
        cacheService: locator(),
        auth: locator(),
        router: locator(),
      ),
    )
    ..registerFactory(
      () => SpeedTrackingViewModel(
        trackingService: locator(),
        locationService: locator(),
        notificationService: locator(),
        overlayService: locator(),
      ),
    );
}
