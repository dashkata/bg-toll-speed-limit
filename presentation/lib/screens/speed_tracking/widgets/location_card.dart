import 'package:domain/model/highway.dart';
import 'package:domain/model/lat_lng.dart';
import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    required this.highway,
    required this.location,
    super.key,
  });
  final Highway? highway;
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
            if (highway != null)
              Text(
                '${highway!.name} | ${highway!.code} | ${highway!.speedLimit} km/h',
                style: const TextStyle(
                  fontSize: 12,
                ),
              )
            else
              const Text(
                'Unknown',
                style: TextStyle(
                  fontSize: 12,
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
