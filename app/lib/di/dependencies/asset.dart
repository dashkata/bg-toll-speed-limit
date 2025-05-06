import 'package:data/source/assets/highway/highway_client.dart';

import '../locator.dart';

void asset() {
  locator.registerLazySingleton(HighwayClient.new);
}
