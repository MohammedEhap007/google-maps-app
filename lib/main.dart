import 'package:flutter/material.dart';
import 'package:google_maps_app/live_location_tracker_module/screens/live_location_tracker_screen.dart';

import 'basics_module/widgets/custom_google_map.dart';

void main() {
  runApp(const GoogleMapsApp());
}

class GoogleMapsApp extends StatelessWidget {
  const GoogleMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Google Maps App',
      home: LiveLocationTrackerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
