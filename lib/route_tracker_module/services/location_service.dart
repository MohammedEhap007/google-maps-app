import 'package:location/location.dart';

import '../errors/exception.dart';

class LocationService {
  Location location = Location();

  Future<void> checkAndRequestLocationService() async {
    // Check if location service is enabled
    bool isLocationServiceEnabled = await location.serviceEnabled();
    // Request to enable location service if not enabled
    if (!isLocationServiceEnabled) {
      isLocationServiceEnabled = await location.requestService();
      // Return Exception if the user denies enabling location service
      if (!isLocationServiceEnabled) {
        throw LocationServiceException('Location service is disabled.');
      }
    }
  }

  Future<void> checkAndRequestLocationPermission() async {
    // Check for location permission
    PermissionStatus locationPermissionStatus = await location.hasPermission();
    // If permission is denied forever, return Exception
    if (locationPermissionStatus == PermissionStatus.deniedForever) {
      throw LocationPermissionException(
        'Location permission is permanently denied.',
      );
    }
    // If permission is denied, request permission
    if (locationPermissionStatus == PermissionStatus.denied) {
      locationPermissionStatus = await location.requestPermission();
      // return Exception if permission is not granted
      if (locationPermissionStatus != PermissionStatus.granted) {
        throw LocationPermissionException('Location permission is denied.');
      }
    }
  }

  void getRealTimeLocationUpdates({
    Function(LocationData)? onLocationUpdate,
  }) async {
    await checkAndRequestLocationService();
    await checkAndRequestLocationPermission();
    // Listen to location changes
    location.onLocationChanged.listen(onLocationUpdate);
  }

  Future<LocationData> getCurrentLocation() async {
    await checkAndRequestLocationService();
    await checkAndRequestLocationPermission();
    // Fetch current location
    return await location.getLocation();
  }

  void changeRealTimeLocationSettings({
    int? interval,
    double? distanceFilter,
  }) {
    location.changeSettings(
      // interval in milliseconds of location updates
      interval: interval,
      // distance in meters to trigger location updates
      distanceFilter: distanceFilter,
    );
  }
}
