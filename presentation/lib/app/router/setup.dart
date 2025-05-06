import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/locator.dart';
import 'routes.dart';

void setupRouter() {
  locator.registerLazySingleton(
    () => GoRouter(
      routes: routes,
      debugLogDiagnostics: true,
      initialLocation: Routes.speedTracking,
      errorBuilder: (_, __) => const Center(child: Text('404 Not Found')),
    
    ),
  );
}
