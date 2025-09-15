import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';

import '../services/location_service.dart';

class LiveLocationTrackerScreen extends StatefulWidget {
  const LiveLocationTrackerScreen({super.key});

  @override
  State<LiveLocationTrackerScreen> createState() =>
      _LiveLocationTrackerScreenState();
}

class _LiveLocationTrackerScreenState extends State<LiveLocationTrackerScreen> {
  late CameraPosition initialCameraPosition;
  late LocationService locationService;
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  bool isFirstMapLoad = true;

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

    locationService = LocationService();

    initLocation();
  }

  @override
  void dispose() {
    googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCameraPosition,
          markers: markers,
          //myLocationEnabled: true,
          myLocationButtonEnabled: false,
          //zoomControlsEnabled: false,
          onMapCreated: (controller) {
            googleMapController = controller;
          },
        ),
      ],
    );
  }

  void initLocation() async {
    await locationService.checkAndRequestLocationService();

    bool hasPermission = await locationService
        .checkAndRequestLocationPermission();

    if (hasPermission) {
      // Change location settings for real-time updates
      locationService.changeRealTimeLocationSettings(
        interval: 2000,
        distanceFilter: 5.0,
      );

      locationService.getRealTimeLocationUpdates(
        onLocationUpdate: (currentLocationData) {
          // Update the camera position
          updateCameraWithCurrentLocation(currentLocationData);
          // Update the marker position
          setCurrentLocationMarker(currentLocationData);
        },
      );
    }
  }

  void updateCameraWithCurrentLocation(LocationData currentLocationData) {
    if (isFirstMapLoad) {
      // Update the initial Zoom level to the user's location
      CameraPosition currentCameraPosition = CameraPosition(
        target: LatLng(
          currentLocationData.latitude!,
          currentLocationData.longitude!,
        ),
        zoom: 17.0,
      );

      // Update the map's camera position
      googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(currentCameraPosition),
      );
      isFirstMapLoad = false;
    } else {
      // Update the user's location without changing the zoom level
      googleMapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            currentLocationData.latitude!,
            currentLocationData.longitude!,
          ),
        ),
      );
    }
  }

  void setCurrentLocationMarker(LocationData currentLocationData) {
    Marker currentLocationMarker = Marker(
      markerId: const MarkerId('currentLocation'),
      position: LatLng(
        currentLocationData.latitude!,
        currentLocationData.longitude!,
      ),
    );
    markers.add(currentLocationMarker);
    setState(() {});
  }
}

//* Steps to get the user location:
// TODO: 1. Inquire about the location service.
// TODO: 2. Request location permission.
// TODO: 3. Get the user's current location.
// TODO: 4. Update the map's camera position to the user's location.
