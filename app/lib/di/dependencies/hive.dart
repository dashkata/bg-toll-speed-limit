import 'package:data/cache/model/highway/highway_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presentation/app/di/locator.dart';

import '../../config/hive_boxes.dart';

Future<void> setupHive() async {
  await Hive.initFlutter();

  final directory = !kIsWeb ? await getApplicationDocumentsDirectory() : null;
  final collection = await BoxCollection.open('AppDB', {HiveBoxes.generic, HiveBoxes.highway}, path: directory?.path);

  final genericBox = await collection.openBox<dynamic>(HiveBoxes.generic);
  final highwayBox = await collection.openBox<HighwayCache>(HiveBoxes.highway);

  locator
    ..registerLazySingleton(() => collection)
    ..registerLazySingleton(() => genericBox, instanceName: HiveBoxes.generic)
    ..registerLazySingleton(() => highwayBox, instanceName: HiveBoxes.highway);
}
