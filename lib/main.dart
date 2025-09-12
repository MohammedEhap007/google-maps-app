import 'package:flutter/material.dart';

import 'live_location_tracker_module/screens/live_location_tracker_screen.dart';

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
