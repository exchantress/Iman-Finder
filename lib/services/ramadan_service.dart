// lib/services/ramadan_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class RamadanService {
  static const _base = 'https://api.aladhan.com/v1';

  static Future<DateTime?> _fetchRamadanHijriByCity(
    int hijriYear,
    String city,
    String country, {
    int method = 4,
  }) async {
    final uri = Uri.parse('$_base/hijriCalendarByCity/$hijriYear/9').replace(
      queryParameters: {
        'city': city,
        'country': country,
        'method': method.toString(),
      },
    );

    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;

    final json = jsonDecode(res.body);

    if (json['code'] != 200) return null;
    if (json['data'] == null) return null;

    final List data = json['data'];
    if (data.isEmpty) return null;

    final firstDay = data[0];

    // ⚠️ PENTING: Cek struktur JSON aman
    if (firstDay['date'] == null) return null;
    if (firstDay['date']['gregorian'] == null) return null;
    if (firstDay['date']['gregorian']['date'] == null) return null;

    final gregDate =
        firstDay['date']['gregorian']['date']; // contoh "27-02-2026"

    final parts = gregDate.split('-');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }

  static int estimateHijriYear() {
    final now = DateTime.now();
    return now.year - 579; // Konversi kasar awal Hijri
  }

  static Future<DateTime?> fetchRamadanStartByCity(
    int _unusedGregorianYear, // tetap ada agar kompatibel dengan kode Anda
    String city,
    String country, {
    int method = 4,
    String? timezone,
    int? adjustment,
    bool debug = false,
  }) async {
    final hijriYear = estimateHijriYear();

    // Coba ramadhan tahun Hijri saat ini
    DateTime? ramadan = await _fetchRamadanHijriByCity(
      hijriYear,
      city,
      country,
      method: method,
    );

    if (ramadan != null) {
      final now = DateTime.now();
      if (ramadan.isAfter(now)) return ramadan;
    }

    // Jika sudah lewat, cari tahun Hijri berikutnya
    return await _fetchRamadanHijriByCity(
      hijriYear + 1,
      city,
      country,
      method: method,
    );
  }

  static Future<DateTime?> fetchRamadanStartByCoords(
    int year,
    double lat,
    double lon, {
    int method = 4,
  }) async {
    // ambil hijri year
    final hijriYear = estimateHijriYear();

    // pakai endpoint coords:
    final uri = Uri.parse('$_base/hijriCalendarByCoordinates/$hijriYear/9')
        .replace(
          queryParameters: {
            'latitude': lat.toString(),
            'longitude': lon.toString(),
            'method': method.toString(),
          },
        );

    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;

    final json = jsonDecode(res.body);
    if (json['code'] != 200) return null;

    final List data = json['data'];
    if (data.isEmpty) return null;

    final greg = data[0]['gregorian']['date'];
    final parts = greg.split('-');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }
}
