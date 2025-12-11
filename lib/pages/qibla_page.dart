import 'dart:async';
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
  // --- Style Constants (Sama dengan Home) ---
  final Color _primaryPurple = const Color(0xFF6C1B9B);
  final Color _accentPurple = const Color(0xFFAB47BC);
  final Color _bgDark = const Color(0xFF0F0F0F);
  final Color _successGreen = const Color(0xFF00E676); // Warna saat arah benar

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
        if (mounted) {
          setState(() => _heading = heading);
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'QIBLA FINDER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _initAll,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Background Gradient (Sama dengan Home)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgDark, const Color(0xFF2A0E36), _bgDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. Ambient Light Effect (Ungu/Hijau jika pas)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isFacing
                          ? _successGreen.withOpacity(0.3)
                          : _primaryPurple.withOpacity(0.2),
                      blurRadius: 100,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Konten Utama
          SafeArea(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: _accentPurple))
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      const Spacer(),

                      // --- KOMPAS DISPLAY ---
                      // Pastikan widget CompassDisplay Anda backgroundnya transparan
                      SizedBox(
                        height: 320,
                        width: 320,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Border glow effect
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isFacing
                                      ? _successGreen.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.1),
                                  width: isFacing ? 4 : 2,
                                ),
                              ),
                            ),
                            CompassDisplay(
                              heading: heading,
                              qiblaDirection: qibla,
                              isFacing: isFacing,
                            ),
                          ],
                        ),
                      ),

                      // Indikator Status Teks
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isFacing
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _successGreen.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _successGreen),
                                  ),
                                  child: const Text(
                                    "MENGHADAP KIBLAT",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                )
                              : Text(
                                  "Putar perangkat Anda...",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                        ),
                      ),

                      const Spacer(),

                      // --- INFO PANEL (GLASSMORPHISM) ---
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoItem(
                                  "Lokasi Saat Ini",
                                  _position != null
                                      ? "${_position!.latitude.toStringAsFixed(4)}, ${_position!.longitude.toStringAsFixed(4)}"
                                      : "Mencari...",
                                  Icons.location_on_outlined,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white10,
                                ),
                                _buildInfoItem(
                                  "Sudut Kiblat",
                                  "${_qibla?.toStringAsFixed(1) ?? '-'}°",
                                  Icons.mosque_outlined,
                                  isRightAlign: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Divider(color: Colors.white.withOpacity(0.1)),
                            const SizedBox(height: 10),

                            // Compass Heading Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Arah Perangkat",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                                Text(
                                  "${heading.toStringAsFixed(0)}°",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Info Text
  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon, {
    bool isRightAlign = false,
  }) {
    return Column(
      crossAxisAlignment: isRightAlign
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRightAlign) ...[
              Icon(icon, color: _accentPurple, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            if (isRightAlign) ...[
              const SizedBox(width: 6),
              Icon(icon, color: _accentPurple, size: 16),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
