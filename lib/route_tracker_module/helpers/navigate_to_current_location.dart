import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../errors/exception.dart';
import '../services/location_service.dart';

void navigateToCurrentLocation({
  required LocationService locationService,
  required GoogleMapController googleMapController,
  required ValueChanged<LatLng> onLocationRetrieved,
}) async {
  try {
    // Get the current location
    LocationData currentLocationData = await locationService
        .getCurrentLocation();
    // Save the current location to a LatLng object
    LatLng currentLocation = LatLng(
      currentLocationData.latitude!,
      currentLocationData.longitude!,
    );
    // Pass the current location to the onLocationRetrieved callback
    onLocationRetrieved(currentLocation);
    // Create a CameraPosition for the current location
    CameraPosition currentCameraPosition = CameraPosition(
      target: currentLocation,
      zoom: 16.0,
    );
    // Move the camera to the current location
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(currentCameraPosition),
    );
  } on LocationServiceException catch (exception) {
    // Handle location service disabled
    log('Location Service Error: $exception');
  } on LocationPermissionException catch (exception) {
    // Handle location permission denied
    log('Location Permission Error: $exception');
  } catch (error) {
    // Handle any other unexpected errors
    log('Unexpected Error: $error');
  }
}
