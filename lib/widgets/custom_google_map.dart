import 'package:flutter/material.dart';
import 'package:google_maps_app/models/place_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
      target: LatLng(
        31.04057557844767,
        31.37803292939223,
      ),
      zoom: 12.0,
    );
    initMarkers();
    super.initState();
  }

  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          markers: markers,
          style: nightMapStyle,
          //mapType: MapType.hybrid,
          onMapCreated: (controller) {
            googleMapController = controller;
            initMapStyle();
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

  Future<void> initMapStyle() async {
    // Load the map style from assets
    nightMapStyle = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/map_styles/night_map_style.json');
    // Apply the map style to the Google Map
    setState(() {});
  }

  void initMarkers() async {
    // Load custom marker icon from assets
    // Note: Ensure the icon is in PNG format, as Google Maps Flutter does not support SVG directly
    // If you have an SVG, convert it to PNG first.
    var customMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/marker_icon.png', // Convert SVG to PNG
    );
    // Create markers from the places list
    var myMarkers = places
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
    setState(() {});
  }
}

// world view 0 -> 3
// country view 4 -> 6
// city view 10 -> 12
// street view 13 -> 17
// building view 18 -> 20
