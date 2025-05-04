import 'package:domain/model/lat_lng.dart';
import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    required this.location,
    super.key,
  });
  final LatLng location;

  @override
  Widget build(BuildContext context) {
    final lat = location.latitude;
    final lng = location.longitude;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Current Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}',
              style: const TextStyle(
                fontFamily: 'Roboto Mono',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
