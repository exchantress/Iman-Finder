import 'dart:ui';
import 'package:flutter/material.dart';
import 'qibla_page.dart';
import '../services/ramadan_service.dart';
import 'ramadan_countdown.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _menuButton(BuildContext ctx, String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          side: const BorderSide(color: Colors.white, width: 3),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background: pakai gradien + blur supaya mirip foto blur di gambar Anda
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF22303F), Color(0xFF0F1720)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // blur layer untuk efek
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: const Color.fromARGB(255, 230, 230, 230).withOpacity(0.2),
            ),
          ),

          // konten utama
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  // logo default (ganti nanti dengan asset Anda)
                  Image.asset('assets/logo.png', width: 300, height: 300),
                  const SizedBox(height: 36),

                  _menuButton(context, 'COMPASS ARAH KIBLAT', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QiblaPage()),
                    );
                  }),

                  _menuButton(context, 'ASMAUL HUSNA', () {
                    _showComingSoon(context);
                  }),

                  _menuButton(context, 'RAMADHAN COUNTDOWN', () async {
                    await _openRamadhanCountdown(context);
                  }),

                  _menuButton(context, 'KALENDER ISLAM', () {
                    _showComingSoon(context);
                  }),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('Fitur ini akan tersedia di rilis selanjutnya.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

Future<void> _openRamadhanCountdown(BuildContext ctx) async {
  final now = DateTime.now();
  final yearsToCheck = [now.year, now.year + 1];
  showDialog(
    context: ctx,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    DateTime? dt;
    for (final y in yearsToCheck) {
      dt = await RamadanService.fetchRamadanStartByCity(
        y,
        'Jakarta',
        'Indonesia',
        method: 4,
      );
      if (dt != null) break;
    }
    Navigator.pop(ctx); // close loader
    if (dt != null) {
      Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) =>
              RamadanCountdownPage(getRamadanStart: () async => dt!),
        ),
      );
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal 1 Ramadhan tidak ditemukan untuk rentang pengecekan.',
          ),
        ),
      );
    }
  } catch (e) {
    Navigator.pop(ctx);
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text('Gagal mengambil tanggal Ramadhan: $e')),
    );
  }
}
