import '../model/highway.dart';

/// Repository for accessing highway and camera point data
abstract class HighwayRepository {
  /// Get all highways
  Future<List<Highway>> getHighways();
}
