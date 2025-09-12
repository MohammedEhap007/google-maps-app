import 'package:google_maps_app/live_location_tracker_module/functions/show_error_bar.dart';
import 'package:location/location.dart';

Future<void> checkAndRequestLocationService({
  required Location location,
}) async {
  // Check if location service is enabled
  bool isLocationServiceEnabled = await location.serviceEnabled();
  if (!isLocationServiceEnabled) {
    isLocationServiceEnabled = await location.requestService();
    while (!isLocationServiceEnabled) {
      isLocationServiceEnabled = await location.requestService();
    }
  }
}
