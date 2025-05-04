import 'package:go_router/go_router.dart';

import '../../screens/speed_tracking/speed_tracking_screen.dart';

class Routes {
  static const String speedTracking = '/speed-tracking';
}

final routes = [
  GoRoute(
    path: Routes.speedTracking,
    name: Routes.speedTracking,
    builder: (_, __) => const SpeedTrackingScreen(),
  ),
];
