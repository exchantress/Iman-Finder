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

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF8A2BE2);
    final Color backgroundColor = const Color(0xFF1E1E2C);
    final Color cardColor = const Color(0xFF2D2D44);

    if (!_isLocaleReady) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Kalender Islam",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
                      DateFormat('MMMM yyyy', 'id_ID').format(_currentDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!_isLoading && _calendarData.isNotEmpty)
                      Text(
                        "${_calendarData.first.hijriMonth} - ${_calendarData.last.hijriMonth} ${_calendarData.first.hijriYear}",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: day == "Jum" ? primaryColor : Colors.grey,
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
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _buildCalendarGrid(cardColor, primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Color cardColor, Color primaryColor) {
    int firstDayOffset = _getFirstDayOffset();
    int totalItemCount = _calendarData.length + firstDayOffset;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: totalItemCount,
      itemBuilder: (context, index) {
        if (index < firstDayOffset) {
          return const SizedBox();
        }

        final data = _calendarData[index - firstDayOffset];

        bool isToday = false;
        final now = DateTime.now();
        final targetDate = now;

        if (_currentDate.month == targetDate.month &&
            _currentDate.year == targetDate.year &&
            int.parse(data.gregorianDate.substring(0, 2)) == targetDate.day) {
          isToday = true;
        }

        return Container(
          decoration: BoxDecoration(
            color: isToday ? primaryColor.withOpacity(0.2) : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: isToday ? Border.all(color: primaryColor, width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.gregorianDate.substring(0, 2),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.hijriDate,
                style: TextStyle(
                  color: primaryColor,
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
