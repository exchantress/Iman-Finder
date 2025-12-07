import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../services/qibla_service.dart';
import '../widgets/compass_display.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  StreamSubscription<CompassEvent>? _compassSub;
  double? _heading;
  double? _qibla;
  Position? _position;
  bool _loading = false;
  String? _error;

  static const double toleranceDegrees = 5.0;

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
      _loading = true;
      _error = null;
    });

    try {
      final pos = await LocationService.getCurrentPosition();
      setState(() => _position = pos);

      final dir = await QiblaService.fetchQiblaDirection(
        pos.latitude,
        pos.longitude,
      );
      setState(() => _qibla = dir);

      _compassSub = FlutterCompass.events!.listen((event) {
        final heading = event.heading ?? 0;
        if (heading.isNaN) return;
        setState(() => _heading = heading);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  double _angleDifference(double a, double b) {
    double diff = (a - b).abs() % 360;
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading ?? 0.0;
    final qibla = _qibla ?? 0.0;
    final diff = _qibla != null ? _angleDifference(qibla, heading) : null;
    final isFacing = diff != null && diff <= toleranceDegrees;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass Arah Kiblat'),
        actions: [
          IconButton(
            onPressed: _initAll,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: CompassDisplay(
                        heading: heading,
                        qiblaDirection: qibla,
                        isFacing: isFacing,
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Lokasi:'),
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
                              Text('${_qibla?.toStringAsFixed(2) ?? '-'}°'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Arah HP:'),
                              Text('${_heading?.toStringAsFixed(2) ?? '-'}°'),
                            ],
                          ),
                          const SizedBox(height: 10),
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
