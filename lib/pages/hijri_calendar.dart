import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:qiblah_finder/Model/hijri_model.dart';
import '../services/hijri_service.dart';

class KalenderIslamPage extends StatefulWidget {
  const KalenderIslamPage({super.key});

  @override
  State<KalenderIslamPage> createState() => _KalenderIslamPageState();
}

class _KalenderIslamPageState extends State<KalenderIslamPage> {
  final HijriService _hijriService = HijriService();

  DateTime _currentDate = DateTime.now();
  List<HijriDate> _calendarData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isLocaleReady = false;

  final Color _accentPurple = const Color(0xFFAB47BC);
  final Color _glowPurple = const Color(0xFF6C1B9B);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      if (mounted) {
        setState(() {
          _isLocaleReady = true;
        });
        _fetchCalendarData();
      }
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + offset);
      _isLoading = true;
    });
    _fetchCalendarData();
  }

  Future<void> _fetchCalendarData() async {
    try {
      final data = await _hijriService.getCalendarData(
        _currentDate.month,
        _currentDate.year,
      );

      if (mounted) {
        setState(() {
          _calendarData = data;
          _isLoading = false;
          _errorMessage = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  int _getFirstDayOffset() {
    if (_calendarData.isEmpty) return 0;
    String dayName = _calendarData.first.weekdayEn.toLowerCase();
    switch (dayName) {
      case 'sunday':
        return 0;
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      default:
        return 0;
    }
  }

  BoxDecoration _getGlassyDecoration({
    bool isToday = false,
    double radius = 20,
  }) {
    return BoxDecoration(
      color: isToday
          ? _accentPurple.withOpacity(0.15)
          : Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isToday
            ? _accentPurple.withOpacity(0.5)
            : Colors.white.withOpacity(0.1),
      ),
      boxShadow: [
        BoxShadow(
          color: isToday
              ? _accentPurple.withOpacity(0.3)
              : _glowPurple.withOpacity(0.1),
          blurRadius: isToday ? 25 : 15,
          spreadRadius: isToday ? 2 : 1,
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0F0F), Color(0xFF2A0E36), Color(0xFF0F0F0F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transparentAppBar = AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const BackButton(color: Colors.white),
      title: const Text(
        "Kalender Islam",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
    );

    if (!_isLocaleReady) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: transparentAppBar,
        body: Stack(
          children: [
            _buildBackground(),
            Center(child: CircularProgressIndicator(color: _accentPurple)),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: transparentAppBar,
      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: _getGlassyDecoration(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Column(
                        children: [
                          Text(
                            DateFormat(
                              'MMMM yyyy',
                              'id_ID',
                            ).format(_currentDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!_isLoading && _calendarData.isNotEmpty)
                            Text(
                              "${_calendarData.first.hijriMonth} - ${_calendarData.last.hijriMonth} ${_calendarData.first.hijriYear}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: _getGlassyDecoration(radius: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: day == "Jum"
                                      ? _accentPurple
                                      : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: _accentPurple,
                          ),
                        )
                      : _errorMessage.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _buildCalendarGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    int firstDayOffset = _getFirstDayOffset();
    int totalItemCount = _calendarData.length + firstDayOffset;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: totalItemCount,
      itemBuilder: (context, index) {
        if (index < firstDayOffset) {
          return const SizedBox();
        }

        final data = _calendarData[index - firstDayOffset];

        bool isToday = false;
        final now = DateTime.now();
        if (_currentDate.month == now.month &&
            _currentDate.year == now.year &&
            int.parse(data.gregorianDate.substring(0, 2)) == now.day) {
          isToday = true;
        }

        return Container(
          decoration: _getGlassyDecoration(isToday: isToday, radius: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.gregorianDate.substring(0, 2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.hijriDate,
                style: TextStyle(
                  color: _accentPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
