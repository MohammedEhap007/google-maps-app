import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<AssetMapBitmap> loadMarkerIcon({required String iconPath}) async {
  // Load custom marker icon from assets
  // Note: Ensure the icon is in PNG format
  AssetMapBitmap customMarkerIcon = await BitmapDescriptor.asset(
    const ImageConfiguration(),
    iconPath,
  );
  return customMarkerIcon;
}
