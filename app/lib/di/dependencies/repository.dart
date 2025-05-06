import 'package:data/repositories/handler/request_handler.dart';
import 'package:data/repositories/highway/highway_repository_impl.dart';
import 'package:data/repositories/settings/settings_repository.dart';
import 'package:domain/repositories/highway_repository.dart';
import 'package:domain/repositories/settings_repository.dart';

import '../locator.dart';

void repository() {
  locator
    ///Repository
    ..registerLazySingleton(RequestHandler.new)
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        localeCacheClient: locator(),
        themeTypeCacheClient: locator(),
        requestHandler: locator(),
        cacheHandler: locator(),
      ),
    )
    ..registerLazySingleton<HighwayRepository>(
      () => HighwayRepositoryImpl(highwayClient: locator(), highwayCacheClient: locator()),
    );
}
