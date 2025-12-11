import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RamadanCountdownPage extends StatefulWidget {
  final Future<DateTime> Function() getRamadanStart;
  const RamadanCountdownPage({super.key, required this.getRamadanStart});

  @override
  State<RamadanCountdownPage> createState() => _RamadanCountdownPageState();
}

class _RamadanCountdownPageState extends State<RamadanCountdownPage> {
  DateTime? _targetDate;
  Duration _remaining = Duration.zero;
  Timer? _timer;
  bool _isLoading = true; // State untuk loading

  @override
  void initState() {
    super.initState();
    _loadDate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDate() async {
    try {
      // Simulasi delay sedikit agar loading spinner terlihat (opsional)
      // await Future.delayed(const Duration(seconds: 1));

      final dt = await widget.getRamadanStart();

      if (!mounted) return;

      setState(() {
        _targetDate = DateTime(dt.year, dt.month, dt.day);
        _isLoading = false; // Matikan loading setelah data dapat
      });

      _startTimer();
    } catch (_) {
      // Jika error, matikan loading agar tidak stuck
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    // Jalankan sekali di awal untuk menghindari delay 1 detik pertama
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (_targetDate == null || !mounted) return;
    final diff = _targetDate!.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal
    final dateStr = _targetDate != null
        ? DateFormat.yMMMMd().format(_targetDate!)
        : '-';

    // Format waktu
    final days = _remaining.inDays;
    final h = _remaining.inHours.remainder(24).toString().padLeft(2, '0');
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 1. Background (Tetap muncul saat loading)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0F0F),
                  Color(0xFF2A0E36),
                  Color(0xFF0F0F0F),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. Logic Tampilan: Loading Spinner VS Content
          Center(
            child: _isLoading
                ? const CircularProgressIndicator(
                    color: Color(0xFFAB47BC), // Warna Ungu
                  )
                : Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C1B9B).withOpacity(0.2),
                          blurRadius: 50,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.nights_stay,
                          size: 50,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "MENUJU RAMADHAN",
                          style: TextStyle(
                            color: Colors.white54,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Countdown
                        Text(
                          "$days HARI",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "$h : $m : $s",
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'monospace',
                            color: Color(0xFFAB47BC),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
