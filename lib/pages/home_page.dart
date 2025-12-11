import 'package:flutter/material.dart';
import 'qibla_page.dart';
import '../services/ramadan_service.dart';
import 'ramadan_countdown.dart';
import 'asmaul_page.dart'; // Sesuaikan pathnya

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Palet Warna
  final Color _primaryPurple = const Color(0xFF6C1B9B); // Ungu gelap
  final Color _accentPurple = const Color(0xFFAB47BC); // Ungu terang
  final Color _bgDark = const Color(0xFF0F0F0F); // Hitam pekat

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Background Gradient (Hitam ke Ungu)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgDark, const Color(0xFF2A0E36), _bgDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 2. Ornamen visual (Lingkaran cahaya ungu pudar di pojok)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryPurple.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: _primaryPurple.withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // 3. Konten Utama
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Logo dengan efek shadow agar pop-out
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryPurple.withOpacity(0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 180, // Ukuran disesuaikan agar proporsional
                      height: 180,
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "ISLAMIC TOOLS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Daftar Menu
                  _buildMenuCard(
                    context,
                    title: 'Arah Kiblat',
                    subtitle: 'Kompas penunjuk Ka\'bah',
                    icon: Icons.explore_outlined,
                    isHighlight: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QiblaPage()),
                      );
                    },
                  ),

                  _buildMenuCard(
                    context,
                    title: 'Asmaul Husna',
                    subtitle: '99 Nama Allah',
                    icon: Icons.menu_book_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AsmaulHusnaPage(),
                        ),
                      );
                    },
                  ),

                  _buildMenuCard(
                    context,
                    title: 'Ramadhan Countdown',
                    subtitle: 'Hitung mundur bulan suci',
                    icon: Icons.nights_stay_outlined,
                    onTap: () => _openRamadhanCountdown(context),
                  ),

                  _buildMenuCard(
                    context,
                    title: 'Kalender Islam',
                    subtitle: 'Hijriyah & Masehi',
                    icon: Icons.calendar_month_outlined,
                    onTap: () => _showComingSoon(context),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "v1.0.0",
                    style: TextStyle(color: Colors.white.withOpacity(0.3)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Button Custom (Glassmorphism Style)
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Efek gradient halus pada tombol
        gradient: LinearGradient(
          colors: isHighlight
              ? [_primaryPurple, _accentPurple]
              : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(isHighlight ? 0.5 : 0.1),
          width: 1,
        ),
        boxShadow: isHighlight
            ? [
                BoxShadow(
                  color: _primaryPurple.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          highlightColor: _accentPurple.withOpacity(0.2),
          splashColor: _primaryPurple.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Coming Soon', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Fitur ini akan tersedia di rilis selanjutnya.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK', style: TextStyle(color: _accentPurple)),
          ),
        ],
      ),
    );
  }
}

// Logic dipisah agar lebih rapi (dan perbaikan async gap)
Future<void> _openRamadhanCountdown(BuildContext ctx) async {
  final now = DateTime.now();
  final yearsToCheck = [now.year, now.year + 1];

  // Tampilkan Loading
  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const CircularProgressIndicator(color: Colors.purpleAccent),
      ),
    ),
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

    // Cek apakah widget masih aktif sebelum melakukan navigasi
    if (!ctx.mounted) return;

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
          backgroundColor: Colors.redAccent,
          content: Text(
            'Tanggal 1 Ramadhan tidak ditemukan untuk rentang pengecekan.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  } catch (e) {
    if (!ctx.mounted) return;
    Navigator.pop(ctx); // close loader jika error

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Gagal mengambil data: $e'),
      ),
    );
  }
}
