import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qiblah_finder/Model/hijri_model.dart';

class HijriService {
  static const String _baseUrl = 'https://api.aladhan.com/v1/gToHCalendar';
  Future<List<HijriDate>> getCalendarData(int month, int year) async {
    final url = Uri.parse('$_baseUrl/$month/$year');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((e) => HijriDate.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat data. Kode: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi atau parsing data.');
    }
  }
}
