import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_app/route_tracker_module/models/place_autocomplete_model/place_autocomplete_model.dart';

class GoogleMapsPlacesApiService {
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

  Future<List<PlaceAutocompleteModel>> getPredictions({
    required String input,
  }) async {
    final String url =
        '$baseUrl/autocomplete/json?input=$input&key=$googleMapsApiKey';
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
}
