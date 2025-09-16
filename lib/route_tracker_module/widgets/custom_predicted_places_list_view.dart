import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_app/route_tracker_module/models/place_details_model/place_details_model.dart';
import 'package:google_maps_app/route_tracker_module/services/google_maps_places_api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place_autocomplete_model/place_autocomplete_model.dart';

class CustomPredictedPlacesListView extends StatelessWidget {
  const CustomPredictedPlacesListView({
    super.key,
    required this.predictedPlaces,
    required this.googleMapsPlacesApiService,
    required this.onPlaceSelected,
  });

  final List<PlaceAutocompleteModel> predictedPlaces;
  final GoogleMapsPlacesApiService googleMapsPlacesApiService;
  final void Function(PlaceDetailsModel) onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Padding(
              padding: EdgeInsets.only(
                left: 8.0,
              ),
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 32.0,
              ),
            ),
            title: Text(
              // Display only the main part of the description (before the first comma)
              predictedPlaces[index].description!.split(',').first,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            titleAlignment: ListTileTitleAlignment.center,
            subtitle: Text(
              // Display the rest of the description (after the first comma)
              predictedPlaces[index].description!.split(',').skip(1).join(','),
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.arrow_outward_rounded,
                size: 24.0,
              ),
              onPressed: () async {
                PlaceDetailsModel placeDetails =
                    await googleMapsPlacesApiService.getPlaceDetails(
                      placeId: predictedPlaces[index].placeId!,
                    );
                // Call the onPlaceSelected callback with the fetched place details
                onPlaceSelected(placeDetails);
              },
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          color: Colors.grey,
          indent: 50.0,
          height: 0.0,
        ),
        itemCount: predictedPlaces.length,
      ),
    );
  }
}
