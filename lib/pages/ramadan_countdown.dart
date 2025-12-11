// lib/pages/ramadan_countdown.dart
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
  DateTime? _startDate;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStartDate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStartDate() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dt = await widget.getRamadanStart();
      final local = DateTime(dt.year, dt.month, dt.day, 0, 0, 0);
      setState(() {
        _startDate = local;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _error = 'Gagal mengambil tanggal Ramadhan: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_startDate == null) return;
    _updateRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    if (_startDate == null) return;
    final now = DateTime.now();
    final remaining = _startDate!.difference(now);
    setState(() {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    });
  }

  String _formattedDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '$days hari  ${_two(hours)}:${_two(minutes)}:${_two(seconds)}';
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  double _progressPercent() {
    if (_startDate == null) return 0.0;
    final baseline = _startDate!.subtract(const Duration(days: 365));
    final total = _startDate!.difference(baseline).inSeconds;
    final elapsed = DateTime.now().difference(baseline).inSeconds;
    if (total <= 0) return 1.0;
    final pct = elapsed / total;
    return pct.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMMd();
    return Scaffold(
      appBar: AppBar(title: const Text('Ramadhan Countdown')),
      body: _loading
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
                  if (_startDate != null) ...[
                    Text(
                      'Ramadhan dimulai pada:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      df.format(_startDate!),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Sisa waktu',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _formattedDuration(_remaining),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: _progressPercent(),
                              minHeight: 10,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(_progressPercent() * 100).toStringAsFixed(0)}% menuju Ramadhan',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () async {
                        await _loadStartDate();
                      },
                      child: const Text('Refresh tanggal Ramadhan'),
                    ),
                  ] else
                    const Text('Tanggal Ramadhan belum tersedia'),
                ],
              ),
            ),
    );
  }
}
