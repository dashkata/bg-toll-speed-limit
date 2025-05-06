import '../../model/highway_response.dart';
import '../json_asset_client.dart';

class HighwayClient extends JsonAssetClient {
  static const String _usaPath = 'assets/data/highways_usa.json';
  static const String _path = 'assets/data/highways.json';

  @override
  String get path => _usaPath;

  @override
  set path(String path) {}

  Future<Iterable<HighwayResponse>> getHighways() async {
    final json = await readJsonList();
    return json.map(HighwayResponse.fromJson);
  }
}
