import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/asmaul.dart';

class AsmaulHusnaService {
  static const _endpoint = 'https://api.aladhan.com/v1/asmaAlHusna';

  static Future<List<AsmaulHusna>> fetchAll() async {
    try {
      final uri = Uri.parse(_endpoint);
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception('Gagal memuat data (Code: ${res.statusCode})');
      }

      final json = jsonDecode(res.body);

      if (json['code'] != 200 || json['data'] == null) {
        throw Exception('Terjadi kesalahan pada server API');
      }

      final List data = json['data'];

      return data.map((e) => AsmaulHusna.fromJson(e)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
