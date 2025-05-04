import 'package:domain/model/tracking_segment.dart';
import 'package:flutter/material.dart';

class ActiveSegmentCard extends StatelessWidget {
  const ActiveSegmentCard({
    required this.segment,
    super.key,
  });
  final TrackingSegment? segment;

  @override
  Widget build(BuildContext context) {
    final trackingSegment = segment;
    if (trackingSegment == null) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'No Active Segment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Start tracking to monitor your average speed',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final averageSpeed = trackingSegment.currentAverageSpeed ?? 0.0;
    final isOverLimit = averageSpeed > trackingSegment.speedLimit;
    final averageSpeedColor = isOverLimit ? Colors.red : Colors.green;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${trackingSegment.startCamera.name} → ${trackingSegment.endCamera.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Average Speed'),
                    Text(
                      '${averageSpeed.toStringAsFixed(1)} km/h',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: averageSpeedColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Speed Limit'),
                    Text(
                      '${trackingSegment.speedLimit.toStringAsFixed(0)} km/h',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Distance'),
                    Text(
                      '${trackingSegment.distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
