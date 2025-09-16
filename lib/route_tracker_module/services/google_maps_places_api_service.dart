import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/place_autocomplete_model/place_autocomplete_model.dart';
import '../models/place_details_model/place_details_model.dart';

class GoogleMapsPlacesApiService {
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

  Future<List<PlaceAutocompleteModel>> getPredictions({
    required String input,
    required String sessionToken,
  }) async {
    final String url =
        '$baseUrl/autocomplete/json?input=$input&sessiontoken=$sessionToken&key=$googleMapsApiKey';
    // Make the HTTP GET request
    final http.Response response = await http.get(Uri.parse(url));
    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final dynamic data = jsonDecode(response.body);
      // Extract predictions List from the response
      final List<dynamic> predictions = data['predictions'];
      // Map the predictions to PlaceAutocompleteModel and return the list
      return predictions
          .map((prediction) => PlaceAutocompleteModel.fromJson(prediction))
          .toList();
    } else {
      throw Exception('Failed to load autocomplete data');
    }
  }

  Future<PlaceDetailsModel> getPlaceDetails({
    required String placeId,
  }) async {
    final String url =
        '$baseUrl/details/json?place_id=$placeId&key=$googleMapsApiKey';
    // Make the HTTP GET request
    final http.Response response = await http.get(Uri.parse(url));
    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final dynamic data = jsonDecode(response.body);
      // Extract result from the response
      final Map<String, dynamic> result = data['result'];
      // Map the result to PlaceDetailsModel and return it
      return PlaceDetailsModel.fromJson(result);
    } else {
      throw Exception('Failed to load place details');
    }
  }
}
