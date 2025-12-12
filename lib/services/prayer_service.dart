import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PrayerService {
  final String _baseUrl = "https://api.aladhan.com/v1";

  // Fetch by GPS 
  Future<Map<String, dynamic>?> getPrayersByCoordinates(double lat, double long) async {
    String dateStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final String url = "$_baseUrl/timings/$dateStr?latitude=$lat&longitude=$long&method=20"; 
    return _fetchData(url);
  }

  Future<Map<String, dynamic>?> _fetchData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['timings'];
      }
      return null;
    } catch (e) {
      print("Error API: $e");
      return null;
    }
  }

  // Cari Kota & Negara 
  Future<Map<String, dynamic>?> searchLocation(String query) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=1&accept-language=id"
    );

    try {
      final response = await http.get(url, headers: {'User-Agent': 'com.example.imanfinder'});

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        
        if (data.isNotEmpty) {
          final item = data[0];
          final address = item['address'];
          
          String city = address['city'] ?? 
                        address['town'] ?? 
                        address['village'] ?? 
                        address['county'] ?? 
                        address['state'] ?? 
                        "";
          
          String country = address['country'] ?? "";
          String displayName = city.isNotEmpty ? "$city, $country" : item['display_name'];

          return {
            'name': displayName,
            'lat': double.parse(item['lat']),
            'long': double.parse(item['lon']),
          };
        }
      }
    } catch (e) {
      print("Gagal search location: $e");
    }
    return null;
  }

  // Reverse Geocoding (GPS -> Nama Kota)
  Future<String> getCityNameFromCoordinates(double lat, double long) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$long&zoom=10&accept-language=id"
    );

    try {
      final response = await http.get(url, headers: {'User-Agent': 'com.example.imanfinder'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        if (address != null) {
          String city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? "";
          String country = address['country'] ?? "";
          
          if (city.isNotEmpty) return "$city, $country";
          if (country.isNotEmpty) return country;
        }
      }
    } catch (e) { print("Error Geo: $e"); }
    return "Lokasi GPS"; 
  }
}