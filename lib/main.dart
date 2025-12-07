import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const QiblaFinderApp());
}

class QiblaFinderApp extends StatelessWidget {
  const QiblaFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qibla Finder',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const QiblaHomePage(),
    );
  }
}

class QiblaHomePage extends StatefulWidget {
  const QiblaHomePage({super.key});

  @override
  State<QiblaHomePage> createState() => _QiblaHomePageState();
}

class _QiblaHomePageState extends State<QiblaHomePage> {
  double? _heading; // heading dari kompas (derajat)
  double? _qiblaDirection; // arah kiblat dari API (derajat)
  Position? _position;
  StreamSubscription<CompassEvent>? _compassSub;
  bool _isLoading = false;
  String? _error;

  static const double toleranceDegrees = 5.0; // threshold "menghadap kiblat"

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  Future<void> _initAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1) Request location permission & get position
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled. Please enable GPS.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error =
              'Location permission permanently denied. Please enable from settings.';
          _isLoading = false;
        });
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _position = pos;
      });

      // 2) Fetch qibla from Aladhan API
      await _fetchQiblaDirection(pos.latitude, pos.longitude);

      // 3) Listen to compass events
      _compassSub = FlutterCompass.events!.listen((event) {
        double heading = event.heading ?? 0;
        // Some devices may return NaN
        if (heading.isNaN) return;
        setState(() {
          _heading = heading;
        });
      });
    } catch (e) {
      setState(() {
        _error = 'Error initializing: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchQiblaDirection(double lat, double lon) async {
    final uri = Uri.parse('https://api.aladhan.com/v1/qibla/$lat/$lon');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'];
        final dir = (data['direction'] as num).toDouble();
        setState(() {
          _qiblaDirection = dir;
        });
      } else {
        setState(() {
          _error = 'API error: ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch qibla: $e';
      });
    }
  }

  String _formatDouble(double? v) {
    if (v == null) return '-';
    return v.toStringAsFixed(2) + '°';
  }

  double _angleDifference(double a, double b) {
    // smallest difference between two angles a and b (degrees)
    double diff = (a - b).abs() % 360;
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading ?? 0.0;
    final qibla = _qiblaDirection ?? 0.0;
    final diff = _qiblaDirection != null
        ? _angleDifference(qibla, heading)
        : null;
    final isFacing = diff != null && diff <= toleranceDegrees;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _initAll();
            },
            tooltip: 'Refresh location & qibla',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Kompas area
                  Expanded(
                    child: Center(
                      child: CompassDisplay(
                        heading: heading,
                        qiblaDirection: qibla,
                        isFacing: isFacing,
                      ),
                    ),
                  ),

                  // Info & stats
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Lokasi (lat, lon):'),
                              Text(
                                _position != null
                                    ? '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}'
                                    : '-',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Arah Kiblat:'),
                              Text(_formatDouble(_qiblaDirection)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Arah HP (heading):'),
                              Text(_formatDouble(_heading)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Selisih:'),
                              Text(
                                diff == null
                                    ? '-'
                                    : '${diff.toStringAsFixed(2)}°',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (isFacing) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sudah menghadap kiblat ✅'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Belum menghadap kiblat. Selisih ${diff?.toStringAsFixed(2)}°',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Cek Arah Sekarang'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Widget menampilkan grafis kompas dan panah kiblat
class CompassDisplay extends StatelessWidget {
  final double heading;
  final double qiblaDirection;
  final bool isFacing;

  const CompassDisplay({
    super.key,
    required this.heading,
    required this.qiblaDirection,
    required this.isFacing,
  });

  @override
  Widget build(BuildContext context) {
    // Kompas (rotasi negatif karena kita memutar background agar sesuai heading)
    final double compassRotation = -heading * pi / 180;

    // Sudut panah qiblat relatif terhadap layar: panah seharusnya mengarah pada absolute qiblaDirection
    // Karena kompas (background) sudah diputar, untuk menggambar panah absolut kita set rotation = qiblaDirection
    final double qiblaRotation = 0;

    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background kompas (image jika ada)
          Transform.rotate(
            angle: compassRotation,
            child: SizedBox(
              width: 300,
              height: 300,
              child: _buildCompassBackground(context),
            ),
          ),

          // Panah fixed menunjukkan arah kiblat (absolut)
          Transform.rotate(
            angle: qiblaRotation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.navigation,
                  size: 56,
                  color: isFacing ? Colors.green : Colors.redAccent,
                ),
                const SizedBox(height: 8),
                Text(
                  'Qibla',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isFacing ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          // Center dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassBackground(BuildContext context) {
    // Gunakan asset compass.png jika ada; otherwise draw simple circle with N/E/S/W
    return Image.asset(
      'assets/compass.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // fallback: simple drawn compass
        return CustomPaint(painter: _CompassPainter());
      },
    );
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.45;
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    final border = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, border);

    final textPainter = (String text, Offset pos) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    };

    // N E S W labels
    textPainter('N', center + Offset(0, -radius + 16));
    textPainter('E', center + Offset(radius - 12, 0));
    textPainter('S', center + Offset(0, radius - 16));
    textPainter('W', center + Offset(-radius + 12, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
