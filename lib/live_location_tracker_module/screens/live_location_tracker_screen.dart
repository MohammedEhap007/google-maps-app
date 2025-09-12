import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_app/live_location_tracker_module/functions/show_error_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';

import '../functions/check_and_request_location_permission.dart';
import '../functions/check_and_request_location_service.dart';

class LiveLocationTrackerScreen extends StatefulWidget {
  const LiveLocationTrackerScreen({super.key});

  @override
  State<LiveLocationTrackerScreen> createState() =>
      _LiveLocationTrackerScreenState();
}

class _LiveLocationTrackerScreenState extends State<LiveLocationTrackerScreen> {
  late CameraPosition initialCameraPosition;
  late Location location;
  GoogleMapController? googleMapController;

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

    initialCameraPosition = const CameraPosition(
      target: LatLng(0.0, 0.0),
      zoom: 3.0,
    );

    location = Location();

    initLocation(location: location);
  }

  @override
  void dispose() {
    googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (controller) {
              googleMapController = controller;
            },
          ),
        ],
      ),
    );
  }

  void initLocation({
    required Location location,
  }) async {
    try {
      await checkAndRequestLocationService(location: location);
      bool hasPermission = await checkAndRequestLocationPermission(
        location: location,
      );
      if (hasPermission) {
        getLocationData(
          location: location,
        );
      } else {
        // Check if widget is still mounted before using context
        if (mounted) {
          showErrorBar(
            context,
            "Location permission denied, can't track location",
          );
        }
      }
    } catch (e) {
      // Handle any errors during location initialization
      if (mounted) {
        showErrorBar(context, "Failed to initialize location: $e");
      }
    }
  }

  void getLocationData({
    required Location location,
  }) {
    location.onLocationChanged.listen((currentLocation) {
      // Use current location data
      CameraPosition currentCameraPosition = CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 15.0,
      );
      googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(currentCameraPosition),
      );
    });
  }
}

//* Steps to get the user location:
  // TODO: 1. Inquire about the location service.
  // TODO: 2. Request location permission.
  // TODO: 3. Get the user's current location.
  // TODO: 4. Update the map's camera position to the user's location.
