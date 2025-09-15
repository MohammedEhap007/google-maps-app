import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_app/route_tracker_module/errors/exception.dart';
import 'package:google_maps_app/route_tracker_module/services/google_maps_places_api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';

import '../../widgets/custom_search_text_field.dart';
import '../services/location_service.dart';

class RouteTrackerView extends StatefulWidget {
  const RouteTrackerView({super.key});

  @override
  State<RouteTrackerView> createState() => _RouteTrackerViewState();
}

class _RouteTrackerViewState extends State<RouteTrackerView> {
  late CameraPosition initialCameraPosition;
  late LocationService locationService;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late GoogleMapsPlacesApiService googleMapsPlacesApiService;

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
    // Set the initial camera position to a default location
    initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 3,
    );
    // Initialize the location service
    locationService = LocationService();
    // Initialize the text editing controller
    textEditingController = TextEditingController();
    // Initialize the Google Maps Places API service
    googleMapsPlacesApiService = GoogleMapsPlacesApiService();
    // Fetch predictions as the user types
    getPredictions();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            googleMapController = controller;
            updateCurrentLocation();
          },
          initialCameraPosition: initialCameraPosition,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        CustomSearchTextField(textEditingController: textEditingController),
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      // Get the current location
      LocationData currentLocationData = await locationService
          .getCurrentLocation();
      // Save the current location to a LatLng object
      LatLng currentPosition = LatLng(
        currentLocationData.latitude!,
        currentLocationData.longitude!,
      );
      // Create a CameraPosition for the current location
      CameraPosition currentCameraPosition = CameraPosition(
        target: currentPosition,
        zoom: 16.0,
      );
      // Move the camera to the current location
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(currentCameraPosition),
      );
    } on LocationServiceException catch (exception) {
      // Handle location service disabled
      // TODO: Show location service dialog
      log('Location Service Error: $exception');
    } on LocationPermissionException catch (exception) {
      // Handle location permission denied
      // TODO: Show location permission dialog
      log('Location Permission Error: $exception');
    } catch (error) {
      // Handle any other unexpected errors
      // TODO: Show a generic error dialog
      log('Unexpected Error: $error');
    }
  }

  void getPredictions() async {
    textEditingController.addListener(() async {
      if (textEditingController.text.isNotEmpty) {
        try {
          final predictions = await googleMapsPlacesApiService.getPredictions(
            input: textEditingController.text,
          );
          log('Predictions: $predictions');
        } catch (error) {
          log('Error fetching predictions: $error');
        }
      }
    });
  }
}
