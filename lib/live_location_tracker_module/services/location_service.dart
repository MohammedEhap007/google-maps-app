import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  Future<bool> checkAndRequestLocationService() async {
    // Check if location service is enabled
    bool isLocationServiceEnabled = await location.serviceEnabled();
    // Request to enable location service if not enabled
    if (!isLocationServiceEnabled) {
      isLocationServiceEnabled = await location.requestService();
      // Return false if the user denies enabling location service
      if (!isLocationServiceEnabled) {
        return false;
      }
    }
    // Location service is enabled
    return true;
  }

  Future<bool> checkAndRequestLocationPermission() async {
    // Check for location permission
    PermissionStatus locationPermissionStatus = await location.hasPermission();
    // If permission is denied forever, return false
    if (locationPermissionStatus == PermissionStatus.deniedForever) {
      return false;
    }
    // If permission is denied, request permission
    if (locationPermissionStatus == PermissionStatus.denied) {
      locationPermissionStatus = await location.requestPermission();
      // return true if permission is granted, else false
      return locationPermissionStatus == PermissionStatus.granted;
    }
    return true;
  }

  void getRealTimeLocationUpdates({
    Function(LocationData)? onLocationUpdate,
  }) {
    // Listen to location changes
    location.onLocationChanged.listen(onLocationUpdate);
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
