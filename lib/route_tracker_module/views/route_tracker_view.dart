import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../helpers/show_error_bar.dart';
import '../models/get_route_body_model/get_route_body_model.dart';
import '../models/get_route_body_model/location_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

import '../helpers/get_lat_lng_bounds.dart';
import '../helpers/navigate_to_current_location.dart';
import '../models/get_route_body_model/destination.dart';
import '../models/get_route_body_model/lat_lng_model.dart';
import '../models/get_route_body_model/origin.dart';
import '../models/place_autocomplete_model/place_autocomplete_model.dart';
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
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};

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
  }

  @override
  void dispose() {
    googleMapController.dispose();
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
            // Update the current location when the map is created
            navigateToCurrentLocation(
              locationService: locationService,
              googleMapController: googleMapController,
              onLocationRetrieved: (currentLocationValue) {
                currentLocation = currentLocationValue;
              },
            );
            // Fetch predictions as the user types
            getPredictions();
          },
          initialCameraPosition: initialCameraPosition,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          polylines: polylines,
          markers: markers,
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
                  onPlaceSelected: (placeDetailsModel) async {
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
                    // Get the route points
                    List<LatLng> routePoints = await getRoutePoints();
                    // Display the route
                    displayRoute(routePoints);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
      try {
        final predictions = await googleMapsPlacesApiService.getPredictions(
          input: input,
          sessionToken: sessionToken!,
        );
        // Ensure the input hasn't changed while waiting for the response
        if (input == textEditingController.text.trim()) {
          setState(() {
            predictedPlaces.clear();
            predictedPlaces.addAll(predictions);
          });
        }
      } catch (error) {
        showErrorBar(context, 'Error fetching predictions');
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
    try {
      // Fetch the route from the Google Maps Routes API
      RoutesModel routes = await googleMapsRoutesApiService.getRoutes(
        body: body,
      );
      // Decode the polyline into a list of LatLng points
      List<LatLng> points = PolylinePoints.decodePolyline(
        routes.routes!.first.polyline!.encodedPolyline!,
      ).map((point) => LatLng(point.latitude, point.longitude)).toList();
      return points;
    } catch (error) {
      showErrorBar(context, 'No route found');
      return [];
    }
  }

  void displayRoute(List<LatLng> routePoints) {
    // Create a Polyline to represent the route
    final Polyline routePolyline = Polyline(
      polylineId: const PolylineId('route'),
      points: routePoints,
      color: Colors.blueAccent,
      width: 7,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
    if (routePoints.isNotEmpty) {
      // Clear existing polylines and add the new route polyline
      setState(() {
        polylines.clear();
        polylines.add(routePolyline);
        // Clear existing markers and add markers for the current and destination locations
        markers.clear();
        markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentLocation,
            infoWindow: const InfoWindow(
              title: 'Current Location',
            ),
          ),
        );
        markers.add(
          Marker(
            markerId: const MarkerId('destinationLocation'),
            position: destinationLocation,
            infoWindow: const InfoWindow(title: 'Destination'),
          ),
        );
      });
      // Adjust the camera to fit the route
      LatLngBounds bounds = getLatLngBounds(routePoints);
      googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    } else {
      setState(() {
        polylines.clear();
        markers.clear();
      });
    }
  }
}
