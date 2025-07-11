import 'package:latlong2/latlong.dart';

class MetroLine {
  final LatLng station1;
  final LatLng station2;
  final String ligne;

  MetroLine({required this.station1, required this.station2, required this.ligne});

  factory MetroLine.fromJson(Map<String, dynamic> json) {
    return MetroLine(
        station1: LatLng(json['station1']['lat'], json['station1']['lon']),
        station2: LatLng(json['station2']['lat'], json['station2']['lon']),
        ligne: json['ligne']
    );
  }
}