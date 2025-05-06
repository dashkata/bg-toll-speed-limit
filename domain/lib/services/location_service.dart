import 'package:geolocator/geolocator.dart';

/// Client for interacting with device location services
class LocationService {
  /// Request location permission from the user
  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get the current position
  Future<Position> getCurrentPosition() async {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  /// Get a stream of position updates
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  /// Get a stream of speed updates
  Stream<Position> getSpeedStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert meters to km
  }

  Future<double> calculateDistanceFromCurrentPosition(
    double endLatitude,
    double endLongitude,
  ) async {
    final currentPosition = await getCurrentPosition();
    return Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert meters to km
  }
  /// Check if current location is near a point
  Future<bool> isNearPoint(
    double targetLatitude,
    double targetLongitude,
    double radiusMeters,
  ) async {
    final currentPosition = await getCurrentPosition();
    final distanceInMeters = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distanceInMeters <= radiusMeters;
  }
}
