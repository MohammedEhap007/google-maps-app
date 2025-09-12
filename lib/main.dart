import 'package:flutter/material.dart';

import 'widgets/custom_google_map.dart';

void main() {
  runApp(const GoogleMapsApp());
}

class GoogleMapsApp extends StatelessWidget {
  const GoogleMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Google Maps App',
      home: CustomGoogleMap(),
      debugShowCheckedModeBanner: false,
    );
  }
}
