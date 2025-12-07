import 'dart:convert';
import 'package:http/http.dart' as http;

class QiblaService {
  /// Mengambil arah qibla dari API Aladhan (derajat)
  static Future<double> fetchQiblaDirection(double lat, double lon) async {
    final uri = Uri.parse('https://api.aladhan.com/v1/qibla/$lat/$lon');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('API error: ${res.statusCode}');
    }
    final body = jsonDecode(res.body);
    final data = body['data'];
    final dir = (data['direction'] as num).toDouble();
    return dir;
  }
}
