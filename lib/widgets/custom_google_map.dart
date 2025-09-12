import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../functions/init_markers.dart';
import '../functions/load_map_style.dart';
import '../models/place_model.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  String? nightMapStyle;

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
    initialCameraPosition = const CameraPosition(
      target: LatLng(
        31.04057557844767,
        31.37803292939223,
      ),
      zoom: 12.0,
    );
    initMapStyle();
    loadMarkers();
  }

  @override
  void dispose() {
    super.dispose();
    googleMapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          //zoomControlsEnabled: false,
          markers: markers,
          style: nightMapStyle,
          //mapType: MapType.hybrid,
          onMapCreated: (controller) {
            googleMapController = controller;
          },
          initialCameraPosition: initialCameraPosition,
          // cameraTargetBounds: CameraTargetBounds(
          //   LatLngBounds(
          //     northeast: const LatLng(31.417448031671345, 31.814695161540257),
          //     southwest: const LatLng(30.786770878722525, 30.99969966999413),
          //   ),
          // ),
        ),
        Positioned(
          left: 10,
          bottom: 50,
          child: ElevatedButton(
            onPressed: () {
              googleMapController.animateCamera(
                duration: const Duration(seconds: 1),
                CameraUpdate.newLatLngZoom(
                  const LatLng(31.094763404014135, 31.26588002695529),
                  19.0,
                ),
              );
            },
            child: const Text('Change Location'),
          ),
        ),
      ],
    );
  }

  void loadMarkers() async {
    markers = await initMarkers();
    // Rebuild to show markers
    setState(() {});
  }

  void initMapStyle() async {
    nightMapStyle = await loadMapStyle(
      context: context,
      mapStylePath: 'assets/map_styles/night_map_style.json',
    );
    // Rebuild to apply the map style
    setState(() {});
  }
}

// world view 0 -> 3
// country view 4 -> 6
// city view 10 -> 12
// street view 13 -> 17
// building view 18 -> 20
