import 'package:latlong2/latlong.dart';

class LatLngPoint {
  final double lat;
  final double lon;

  LatLngPoint({required this.lat, required this.lon});

  factory LatLngPoint.fromJson(Map<String, dynamic> json) {
    return LatLngPoint(
      lat: json['lat'],
      lon: json['lon'],
    );
  }

  LatLng toLatLng() => LatLng(lat, lon);
}