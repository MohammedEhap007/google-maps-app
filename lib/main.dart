import 'package:flutter/material.dart';
import 'package:google_maps_app/widgets/custom_google_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
