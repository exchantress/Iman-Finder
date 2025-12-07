import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const QiblaFinderApp());
}

class QiblaFinderApp extends StatelessWidget {
  const QiblaFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qibla Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}
