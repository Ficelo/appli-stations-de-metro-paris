import './latlng.dart';

class Station {
  String nom;
  LatLngPoint geoPoints2D;
  bool visited;
  List<String> lines;

  Station({required this.nom, required this.geoPoints2D, required this.visited, required this.lines});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
        nom: json['nom'],
        geoPoints2D: LatLngPoint.fromJson(json['geo_point_2d']),
        visited: json['visited'],
        lines: (json['lignes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}