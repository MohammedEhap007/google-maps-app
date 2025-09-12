import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place_model.dart';
import 'load_marker_icon.dart';

Future<Set<Marker>> initMarkers() async {
  Set<Marker> markers = {};

  // Load custom marker icon
  AssetMapBitmap customMarkerIcon = await loadMarkerIcon(
    iconPath: 'assets/icons/resized_marker_icon.png',
  );

  // Create markers from the places list
  Set<Marker> myMarkers = places
      .map(
        (placeModel) => Marker(
          icon: customMarkerIcon,
          markerId: MarkerId(placeModel.id.toString()),
          position: placeModel.location,
          infoWindow: InfoWindow(title: placeModel.name),
        ),
      )
      .toSet();
  markers.addAll(myMarkers);

  return markers;
}
