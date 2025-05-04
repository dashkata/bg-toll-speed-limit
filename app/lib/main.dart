// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:presentation/app/app.dart';
import 'package:presentation/app/router/setup.dart';

import 'di/setup.dart';
import 'overlay_entry.dart';

// This is the entry point for the overlay window
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayApp());
}

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
  );

  await setupDependencies();

  // if (!kDebugMode) {
  //   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  //   PlatformDispatcher.instance.onError = (error, stack) {
  //     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //     return true;
  //   };

  //   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // }

  setupRouter();

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}
