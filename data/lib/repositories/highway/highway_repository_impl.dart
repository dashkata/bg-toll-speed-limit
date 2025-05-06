import 'package:domain/model/highway.dart';
import 'package:domain/repositories/highway_repository.dart';

import '../../cache/cache_client.dart';
import '../../cache/highway/highway_cache_client.dart';
import '../../source/assets/highway/highway_client.dart';
import '../../source/model/highway_response.dart';
import 'mappers/cache_mapper.dart';
import 'mappers/highway_mapper.dart';

class HighwayRepositoryImpl implements HighwayRepository {
  HighwayRepositoryImpl({required this.highwayClient, required this.highwayCacheClient});

  final HighwayClient highwayClient;
  final HighwayCacheClient highwayCacheClient;

  //TODO figure out a way to get segments

  @override
  Future<List<Highway>> getHighways() async {
    final isCacheEmpty = await highwayCacheClient.isEmpty();
    if (isCacheEmpty) {
      final highways = await highwayClient.getHighways();
      await _cacheHighways(highways);
      return highways.map((e) => e.toDomain()).toList();
    }

    final cachedHighways = await highwayCacheClient.getAll();
    return cachedHighways.map((e) => e.toDomain()).toList();
  }

  Future<void> _cacheHighways(Iterable<HighwayResponse> highways) async {
    for (final e in highways) {
      await highwayCacheClient.put(id: e.id, data: e.toCache());
    }
  }
}
