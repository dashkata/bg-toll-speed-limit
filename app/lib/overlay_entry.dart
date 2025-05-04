import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// Entry point for the overlay window
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: TrueCallerOverlay()));
}

class OverlayApp extends StatefulWidget {
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  double _currentSpeed = 0.0;
  Map<String, dynamic>? _activeSegment;

  @override
  void initState() {
    super.initState();
    _setupDataListener();
  }

  void _setupDataListener() {
    FlutterOverlayWindow.overlayListener.listen((event) {
      try {
        final data = jsonDecode(event.toString()) as Map<String, dynamic>;

        setState(() {
          _currentSpeed = data['currentSpeed'] as double;

          if (data['activeSegment'] != null) {
            _activeSegment = data['activeSegment'] as Map<String, dynamic>;
          } else {
            _activeSegment = null;
          }
        });
      } catch (e) {
        // Ignore parsing errors
        print('Error parsing overlay data: $e');
      }
    });
  }

  Color _getSpeedColor() {
    final speedLimit = _activeSegment?['speedLimit'] as double? ?? 130.0;

    if (_currentSpeed > speedLimit + 10) {
      return Colors.red;
    } else if (_currentSpeed > speedLimit) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSpeedColor();
    final averageSpeed = _activeSegment?['currentAverageSpeed'] as double? ?? 0.0;
    final speedLimit = _activeSegment?['speedLimit'] as double? ?? 130.0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentSpeed.toStringAsFixed(1),
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
              ),
              const Text('km/h', style: TextStyle(fontSize: 12, color: Colors.white)),
              if (_activeSegment != null) ...[
                const Divider(height: 16, color: Colors.white24),
                Text(
                  'Avg: ${averageSpeed.toStringAsFixed(1)} km/h',
                  style: TextStyle(
                    fontSize: 14,
                    color: averageSpeed > speedLimit ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Limit: ${speedLimit.toStringAsFixed(0)} km/h',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TrueCallerOverlay extends StatefulWidget {
  const TrueCallerOverlay({super.key});

  @override
  State<TrueCallerOverlay> createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  bool isGold = true;

  final _goldColors = const [Color(0xFFa2790d), Color(0xFFebd197), Color(0xFFa2790d)];

  final _silverColors = const [Color(0xFFAEB2B8), Color(0xFFC7C9CB), Color(0xFFD7D7D8), Color(0xFFAEB2B8)];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isGold ? _goldColors : _silverColors,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                isGold = !isGold;
              });
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    ListTile(
                      leading: Container(
                        height: 80.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          shape: BoxShape.circle,
                          image: const DecorationImage(image: NetworkImage('https://api.multiavatar.com/x-slayer.png')),
                        ),
                      ),
                      title: const Text('X-SLAYER', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Sousse , Tunisia'),
                    ),
                    const Spacer(),
                    const Divider(color: Colors.black54),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text('+216 21065826'), Text('Last call - 1 min ago')],
                          ),
                          Text('Flutter Overlay', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(onPressed: () async {}, icon: const Icon(Icons.close, color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
