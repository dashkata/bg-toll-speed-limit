import 'package:domain/model/highway.dart';
import 'package:domain/model/tracking_segment.dart';
import 'package:flutter/material.dart';

class HighwayInfoCard extends StatelessWidget {
  const HighwayInfoCard({required this.activeSegment, required this.currentHighway, super.key});

  final TrackingSegment? activeSegment;
  final Highway? currentHighway;

  @override
  Widget build(BuildContext context) {
    // If we have no highway info, show a placeholder
    if (currentHighway == null && activeSegment == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.route, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'No Highway Detected',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Determine which highway to display
    final highway = currentHighway ?? activeSegment!.startCamera.highway;
    final isInSegment = activeSegment != null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.route, color: isInSegment ? Colors.blue : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  highway.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isInSegment ? Colors.blue[800] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                _buildHighwayCodeBadge(highway.code),
              ],
            ),
            const SizedBox(height: 8),
            Text('Speed Limit: ${highway.speedLimit.toInt()} km/h', style: const TextStyle(fontSize: 14)),
            if (isInSegment)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Tracking segment: ${activeSegment!.startCamera.name} → ${activeSegment!.endCamera.name}',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighwayCodeBadge(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.blue[800], borderRadius: BorderRadius.circular(4)),
      child: Text(code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
