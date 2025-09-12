import 'package:location/location.dart';

Future<bool> checkAndRequestLocationPermission({
  required Location location,
}) async {
  // Check for location permission
  PermissionStatus locationPermissionStatus = await location.hasPermission();
  // If permission is denied forever, return false
  if (locationPermissionStatus == PermissionStatus.deniedForever) {
    return false;
  }
  // If permission is denied, request permission
  if (locationPermissionStatus == PermissionStatus.denied) {
    locationPermissionStatus = await location.requestPermission();
    // If permission is still not granted, return false
    if (locationPermissionStatus != PermissionStatus.granted) {
      return false;
    }
  }
  return true;
}
