import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLngBounds getLatLngBounds(List<LatLng> routePoints) {
  var southWestLatitude = routePoints.first.latitude;
  var southWestLongitude = routePoints.first.longitude;
  var northEastLatitude = routePoints.first.latitude;
  var northEastLongitude = routePoints.first.longitude;
  for (var point in routePoints) {
    southWestLatitude = min(southWestLatitude, point.latitude);
    southWestLongitude = min(southWestLongitude, point.longitude);
    northEastLatitude = max(northEastLatitude, point.latitude);
    northEastLongitude = max(northEastLongitude, point.longitude);
  }
  return LatLngBounds(
    // southwest is the smallest point in the route
    southwest: LatLng(southWestLatitude, southWestLongitude),
    // northeast is the biggest point in the route
    northeast: LatLng(northEastLatitude, northEastLongitude),
  );
}
