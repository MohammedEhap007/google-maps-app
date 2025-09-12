import 'package:flutter/material.dart';

Future<String> loadMapStyle({
  required BuildContext context,
  required String mapStylePath,
}) async {
  // Load the map style from assets
  return await DefaultAssetBundle.of(
    context,
  ).loadString(
    mapStylePath,
  );
}
