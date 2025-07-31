import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  final int id;
  final String name;
  final LatLng location;

  PlaceModel({
    required this.id,
    required this.name,
    required this.location,
  });
}

List<PlaceModel> places = [
  PlaceModel(
    id: 1,
    name: 'ميدان الشيخ حسنين',
    location: const LatLng(31.04092676824113, 31.37849104639813),
  ),
  PlaceModel(
    id: 2,
    name: 'جملة ماركت - المنصورة',
    location: const LatLng(31.04726679274247, 31.376197592970534),
  ),
  PlaceModel(
    id: 3,
    name: 'جامعة المنصورة',
    location: const LatLng(31.045094455189503, 31.3537011092201),
  ),
  // Add more places as needed
];
