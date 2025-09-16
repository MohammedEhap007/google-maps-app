import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_app/route_tracker_module/models/get_route_body_model/get_route_body_model.dart';
import 'package:google_maps_app/route_tracker_module/models/get_route_body_model/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

import '../errors/exception.dart';
import '../models/get_route_body_model/destination.dart';
import '../models/get_route_body_model/lat_lng.dart';
import '../models/get_route_body_model/origin.dart';
import '../models/place_autocomplete_model/place_autocomplete_model.dart';
import '../models/routes_model/route.dart';
import '../models/routes_model/routes_model.dart';
import '../services/google_maps_places_api_service.dart';
import '../services/google_maps_routes_api_service.dart';
import '../services/location_service.dart';
import '../widgets/custom_predicted_places_list_view.dart';
import '../widgets/custom_search_text_field.dart';

class RouteTrackerView extends StatefulWidget {
  const RouteTrackerView({super.key});

  @override
  State<RouteTrackerView> createState() => _RouteTrackerViewState();
}

class _RouteTrackerViewState extends State<RouteTrackerView> {
  late CameraPosition initialCameraPosition;
  late LocationService locationService;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late GoogleMapsPlacesApiService googleMapsPlacesApiService;
  late GoogleMapsRoutesApiService googleMapsRoutesApiService;
  late Uuid uuid;
  late LatLng currentLocation;
  late LatLng destinationLocation;
  List<PlaceAutocompleteModel> predictedPlaces = [];
  String? sessionToken;

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
    // Set the initial camera position to a default location
    initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 3,
    );
    // Initialize the location service
    locationService = LocationService();
    // Initialize the UUID generator
    uuid = const Uuid();
    // Initialize the text editing controller
    textEditingController = TextEditingController();
    // Initialize the Google Maps Places API service
    googleMapsPlacesApiService = GoogleMapsPlacesApiService();
    // Initialize the Google Maps Routes API service
    googleMapsRoutesApiService = GoogleMapsRoutesApiService();
    // Fetch predictions as the user types
    getPredictions();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            googleMapController = controller;
            updateCurrentLocation();
          },
          initialCameraPosition: initialCameraPosition,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                CustomSearchTextField(
                  textEditingController: textEditingController,
                ),
                const SizedBox(height: 8.0),
                CustomPredictedPlacesListView(
                  predictedPlaces: predictedPlaces,
                  googleMapsPlacesApiService: googleMapsPlacesApiService,
                  // Pass the onPlaceSelected callback to clear the text field and predictions
                  onPlaceSelected: (placeDetailsModel) {
                    setState(() {
                      textEditingController.clear();
                      predictedPlaces.clear();
                      // Reset the session token
                      sessionToken = null;
                    });
                    // Update the destination location with the selected place's coordinates
                    destinationLocation = LatLng(
                      placeDetailsModel.geometry!.location!.lat!,
                      placeDetailsModel.geometry!.location!.lng!,
                    );
                    getRoutePoints();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      // Get the current location
      LocationData currentLocationData = await locationService
          .getCurrentLocation();
      // Save the current location to a LatLng object
      currentLocation = LatLng(
        currentLocationData.latitude!,
        currentLocationData.longitude!,
      );
      // Create a CameraPosition for the current location
      CameraPosition currentCameraPosition = CameraPosition(
        target: currentLocation,
        zoom: 16.0,
      );
      // Move the camera to the current location
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(currentCameraPosition),
      );
    } on LocationServiceException catch (exception) {
      // Handle location service disabled
      // TODO: Show location service dialog
      log('Location Service Error: $exception');
    } on LocationPermissionException catch (exception) {
      // Handle location permission denied
      // TODO: Show location permission dialog
      log('Location Permission Error: $exception');
    } catch (error) {
      // Handle any other unexpected errors
      // TODO: Show a generic error dialog
      log('Unexpected Error: $error');
    }
  }

  void getPredictions() {
    textEditingController.addListener(() async {
      final input = textEditingController.text.trim();
      if (input.isEmpty) {
        setState(() {
          predictedPlaces.clear();
        });
        return;
      }
      // Generate a new session token if it's null
      sessionToken ??= uuid.v4();
      log(sessionToken!);
      try {
        final predictions = await googleMapsPlacesApiService.getPredictions(
          input: input,
          sessionToken: sessionToken!,
        );
        // Only update if the text field still has the same content
        if (input == textEditingController.text.trim()) {
          setState(() {
            predictedPlaces.clear();
            predictedPlaces.addAll(predictions);
          });
        }
      } catch (error) {
        log('Error fetching predictions: $error');
        setState(() {
          predictedPlaces.clear();
        });
      }
    });
  }

  Future<List<LatLng>> getRoutePoints() async {
    // Get the body for the route request
    GetRouteBodyModel body = GetRouteBodyModel(
      origin: Origin(
        location: LocationModel(
          latLng: LatLngModel(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
          ),
        ),
      ),
      destination: Destination(
        location: LocationModel(
          latLng: LatLngModel(
            latitude: destinationLocation.latitude,
            longitude: destinationLocation.longitude,
          ),
        ),
      ),
    );
    // Fetch the route from the Google Maps Routes API
    RoutesModel routes = await googleMapsRoutesApiService.getRoutes(body: body);
    // Decode the polyline into a list of LatLng points
    List<LatLng> points = PolylinePoints.decodePolyline(
      routes.routes!.first.polyline!.encodedPolyline!,
    ).map((point) => LatLng(point.latitude, point.longitude)).toList();
    return points;
  }
}
