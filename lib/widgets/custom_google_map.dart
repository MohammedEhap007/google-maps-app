import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Use this method if you don't have a direct access to the image file
  // Like you have the image coming form an API or a different source 
  Future<Uint8List> resizeImageFromRawData(
    String imagePath,
    double width,
  ) async {
    // Load the image data from assets
    var imageData = await rootBundle.load(imagePath);

    // Instantiate the image codec with the loaded data and target width
    // Note: This step will resize the image to the specified width
    var imageCodec = await ui.instantiateImageCodec(
      imageData.buffer.asUint8List(),
      targetWidth: width.round(),
    );

    // Get the first frame of the image codec
    var imageFrameInfo = await imageCodec.getNextFrame();

    // Convert the image to a byte array
    // using the specified format (PNG in this case)
    var imageByteData = await imageFrameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    // Return the byte array as Uint8List
    return imageByteData!.buffer.asUint8List();
  }

  void initMarkers() async {
    // Load custom marker icon from assets
    // Note: Ensure the icon is in PNG format
    var customMarkerIcon = BitmapDescriptor.bytes(
      await resizeImageFromRawData(
        'assets/icons/marker_icon.png',
      100.0,
      ),
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
