import 'package:domain/services/tracking_service.dart';
import 'package:flutter/material.dart';

class SimulationControls extends StatelessWidget {
  const SimulationControls({required this.trackingService, required this.isAutoTrackingEnabled, super.key});

  final TrackingService trackingService;
  final bool isAutoTrackingEnabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Simulation Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Auto Tracking:'),
                const SizedBox(width: 8),
                Switch(value: isAutoTrackingEnabled, onChanged: trackingService.setAutoTracking),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Simulation Mode Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'This simulation moves between camera points automatically. '
              'The app will detect when you pass a camera point and track your speed.',
            ),
          ],
        ),
      ),
    );
  }
}
