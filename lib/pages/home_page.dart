import 'dart:ui';
import 'package:flutter/material.dart';
import 'qibla_page.dart';

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
          side: const BorderSide(color: Colors.white, width: 2),
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
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),

          // konten utama
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  // logo default (ganti nanti dengan asset Anda)
                  const FlutterLogo(size: 120),
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

                  _menuButton(context, 'RAMADHAN COUNTDOWN', () {
                    _showComingSoon(context);
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
