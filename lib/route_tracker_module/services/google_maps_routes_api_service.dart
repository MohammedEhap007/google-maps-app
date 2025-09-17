import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/get_route_body_model/get_route_body_model.dart';
import '../models/routes_model/routes_model.dart';
import 'package:http/http.dart' as http;

class GoogleMapsRoutesApiService {
  final String baseUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

  Future<RoutesModel> getRoutes({required GetRouteBodyModel body}) async {
    // Set up URL
    final Uri url = Uri.parse(baseUrl);
    // Set up headers
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
      'X-Goog-Api-Key': apiKey,
    };
    // Make the HTTP POST request
    final http.Response response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body.toJson()),
    );
    if (response.statusCode == 200) {
      // Parse the JSON response
      final dynamic data = jsonDecode(response.body);
      // Map the response to RoutesModel and return it
      return RoutesModel.fromJson(data);
    } else {
      throw Exception('Failed to load route');
    }
  }
}
