import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class RouteTrackerView extends StatefulWidget {
  const RouteTrackerView({super.key});

  @override
  State<RouteTrackerView> createState() => _RouteTrackerViewState();
}

class _RouteTrackerViewState extends State<RouteTrackerView> {
  late CameraPosition initialCameraPosition;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition on Android to improve performance
    if (Platform.isAndroid) {
      unawaited(
        (GoogleMapsFlutterPlatform.instance as GoogleMapsFlutterAndroid)
            .warmup(),
      );
    }

    initialCameraPosition = const CameraPosition(target: LatLng(0, 0));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCameraPosition,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
      ],
    );
  }
}
