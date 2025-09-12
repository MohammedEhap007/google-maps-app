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
  String? nightMapStyle;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

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
    initPolylines();
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
          style: nightMapStyle,
          markers: markers,
          polylines: polylines,
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

  void initMapStyle() async {
    nightMapStyle = await loadMapStyle(
      context: context,
      mapStylePath: 'assets/map_styles/night_map_style.json',
    );
    // Rebuild to apply the map style
    setState(() {});
  }

  void loadMarkers() async {
    markers = await initMarkers();
    // Rebuild to show markers
    setState(() {});
  }

  void initPolylines() {
    Polyline polyline1 = const Polyline(
      polylineId: PolylineId('1'),
      color: Colors.blue,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      zIndex: 2,
      width: 5,
      points: [
        LatLng(31.095503806971635, 31.29815706102415),
        LatLng(31.05494184686604, 31.38065659554169),
        LatLng(31.016276176511532, 31.388371049170285),
        LatLng(30.881626469198256, 31.461151543735912),
      ],
    );
    Polyline polyline2 = Polyline(
      polylineId: const PolylineId('2'),
      color: Colors.red,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      zIndex: 1,
      width: 5,
      patterns: [
        PatternItem.gap(25),
        PatternItem.dash(25),
        PatternItem.gap(25),
        PatternItem.dot,
      ],
      points: const [
        LatLng(31.024316054370384, 31.232073722358727),
        LatLng(30.943214828505734, 31.377663499206218),
        LatLng(31.0317817189109, 31.553629094839895),
        LatLng(31.16712281051145, 31.452005085351804),
      ],
    );
    Polyline polyline3 = const Polyline(
      polylineId: PolylineId('3'),
      color: Colors.green,
      geodesic: true,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      width: 5,
      points: [
        LatLng(62.503733588700534, 94.95278794135676),
        LatLng(-54.07321148408361, -68.39277450715906),
      ],
    );
    polylines.add(polyline1);
    polylines.add(polyline2);
    polylines.add(polyline3);
  }
}

// world view 0 -> 3
// country view 4 -> 6
// city view 10 -> 12
// street view 13 -> 17
// building view 18 -> 20
