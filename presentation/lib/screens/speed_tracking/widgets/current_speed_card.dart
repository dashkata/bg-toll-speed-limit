import 'package:flutter/material.dart';

class CurrentSpeedCard extends StatelessWidget {
  const CurrentSpeedCard({
    required this.currentSpeed,
    required this.speedColor,
    super.key,
  });
  final double currentSpeed;
  final Color speedColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Current Speed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentSpeed.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: speedColor,
              ),
            ),
            const Text(
              'km/h',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
