import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'route_tracker_module/views/route_tracker_view.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const GoogleMapsApp());
}

class GoogleMapsApp extends StatelessWidget {
  const GoogleMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Google Maps App',
      home: RouteTrackerView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
