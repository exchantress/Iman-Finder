import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/prayer_service.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {

  final Color _primaryPurple = const Color(0xFF6C1B9B);
  final Color _bgDark = const Color(0xFF0F0F0F);

  Map<String, dynamic>? prayerTimes;
  bool isLoading = false;
  String currentLocationName = "Mencari lokasi...";
  
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    bool useGPS = prefs.getBool('useGPS') ?? false;
    String savedName = prefs.getString('savedLocationName') ?? "Palembang, Indonesia";

    double? lastLat = prefs.getDouble('savedLat');
    double? lastLong = prefs.getDouble('savedLong');

    if (mounted) setState(() => currentLocationName = savedName);

    if (useGPS) {
      _getLocationAndFetch();
    } else if (lastLat != null && lastLong != null) {
      _fetchPrayerByCoords(lastLat, lastLong, savedName);
    } else {
      _getManualLocationAndFetch("Palembang", isRefresh: true);
    }
  }

  // Search
  Future<void> _getManualLocationAndFetch(String query, {bool isRefresh = false}) async {
    if (query.isEmpty) return;

    if (!isRefresh) {
      setState(() {
        isLoading = true;
        currentLocationName = "Mencari $query...";
      });
    }

    final locationData = await PrayerService().searchLocation(query);

    if (mounted) {
      if (locationData != null) {
        String fullName = locationData['name'];
        double lat = locationData['lat'];
        double long = locationData['long'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('useGPS', false);
        await prefs.setString('savedLocationName', fullName);
        await prefs.setDouble('savedLat', lat);
        await prefs.setDouble('savedLong', long);

        final data = await PrayerService().getPrayersByCoordinates(lat, long);

        setState(() {
          prayerTimes = data;
          currentLocationName = fullName; 
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          currentLocationName = "Kota tidak ditemukan";
        });
        _showError("Lokasi '$query' tidak ditemukan.");
      }
    }
  }

  Future<void> _fetchPrayerByCoords(double lat, double long, String name) async {
    setState(() => isLoading = true);
    final data = await PrayerService().getPrayersByCoordinates(lat, long);
    if (mounted) {
      setState(() {
        prayerTimes = data;
        currentLocationName = name;
        isLoading = false;
      });
    }
  }

  // GPS 
  Future<void> _getLocationAndFetch() async {
    _cityController.clear(); 
    setState(() {
      isLoading = true;
      currentLocationName = "Mendeteksi Lokasi...";
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError("Aktifkan GPS Anda.");
      if(mounted) setState(() => isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError("Izin lokasi ditolak.");
        if(mounted) setState(() => isLoading = false);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      final data = await PrayerService().getPrayersByCoordinates(position.latitude, position.longitude);
      String detectedName = await PrayerService().getCityNameFromCoordinates(position.latitude, position.longitude);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('useGPS', true);
      await prefs.setString('savedLocationName', detectedName);
      await prefs.setDouble('savedLat', position.latitude);
      await prefs.setDouble('savedLong', position.longitude);

      if (mounted && data != null) {
        setState(() {
          prayerTimes = data;
          isLoading = false;
          currentLocationName = detectedName;
        });
      }
    } catch (e) {
      _showError("Gagal mengambil lokasi.");
      if(mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'JADWAL SHOLAT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgDark, const Color(0xFF2A0E36), _bgDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text("Lokasi Anda", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                  const SizedBox(height: 5),
                  
                  Text(
                    currentLocationName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _cityController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Ketik lokasi Anda",
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (val) => _getManualLocationAndFetch(val),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _primaryPurple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            onPressed: () => _getManualLocationAndFetch(_cityController.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Tombol GPS
                  InkWell(
                    onTap: _getLocationAndFetch,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.location_on_outlined, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "Gunakan lokasi Anda saat ini",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // List
                  if (isLoading)
                     const Padding(
                       padding: EdgeInsets.only(top: 30),
                       child: CircularProgressIndicator(color: Colors.white),
                     )
                  else if (prayerTimes == null)
                    Padding(
                       padding: const EdgeInsets.only(top: 30),
                       child: Text("Data tidak tersedia", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                     )
                  else
                    Column(
                      children: [
                        _buildGlassTile("Subuh", "Fajr"),
                        _buildGlassTile("Dzuhur", "Dhuhr"),
                        _buildGlassTile("Ashar", "Asr"),
                        _buildGlassTile("Maghrib", "Maghrib"),
                        _buildGlassTile("Isya", "Isha"),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTile(String prayerName, String apiKey) {
    String time = prayerTimes?[apiKey] ?? "-";
    time = time.split(" ")[0]; 

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Text(
            prayerName,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          Text(
            time,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}