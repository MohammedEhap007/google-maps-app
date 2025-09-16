import 'location.dart';

class Destination {
  Location? location;

  Destination({this.location});

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    location: json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'location': location?.toJson(),
  };
}
