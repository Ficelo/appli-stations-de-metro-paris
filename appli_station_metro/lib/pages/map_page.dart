import 'dart:convert';
import 'package:appli_station_metro/pages/station_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import '../components/constants.dart';
import '../components/database_helper.dart';
import '../models/station.dart';
import '../models/metro_line.dart';
import '../models/loader.dart';


// Loaders

Future<List<Station>> loadStations() async {
  final String jsonString = await rootBundle.loadString('assets/stations.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((e) => Station.fromJson(e)).toList();
}

Future<List<MetroLine>> loadLines() async {
  final String jsonString = await rootBundle.loadString('assets/lignes.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((e) => MetroLine.fromJson(e)).toList();
}

// Map Page

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Station> _stations = [];
  List<MetroLine> _lines = [];
  final dbHelper = DatabaseHelper();
  late Database db;

  bool isSameLocation(LatLng a, LatLng b, {double tolerance = 0.0001}) {
    return (a.latitude - b.latitude).abs() < tolerance &&
        (a.longitude - b.longitude).abs() < tolerance;
  }

  bool displayLine(MetroLine line) {
    bool station1 = false;
    bool station2 = false;

    for (var sta in _stations) {
      final LatLng stationLatLng = sta.geoPoints2D.toLatLng();

      if (isSameLocation(line.station1, stationLatLng)) {
        station1 = sta.visited;
      }
      if (isSameLocation(line.station2, stationLatLng)) {
        station2 = sta.visited;
      }

      if (station1 && station2) return true;
    }

    return false;
  }

  final mapController = MapController();

  final LatLng _center = LatLng(48.8566, 2.3522);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stations = await Loader.loadStations();

    for (var s in stations) {
      final sta = await dbHelper.getStationByName(s.nom);
      final visited = await dbHelper.hasUserVisitedStation(1, sta?["id"] ?? 1);
      s.visited = visited;
    }

    final lines = await Loader.loadLines();
    setState(() {
      _stations = stations;
      _lines = lines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            tileProvider: NetworkTileProvider(
                headers: {
                  'User-Agent': 'AppliStationMetro/1.0 (teiva.trillard@gmail.com)'
                }
            ),
          ),
          PolylineLayer( // Changer quand y'aura la bdd
            polylines: _lines.where((line) => displayLine(line)).map((line) {
              return Polyline(
                points: [line.station1, line.station2],
                color: Color(Constantes.couleursLignes[line.ligne]!),
                strokeWidth: 5.0,
                borderColor: Colors.black,
                borderStrokeWidth: 2.0
              );
            }).toList(),
          ),

          // Changer quand y'aura la bdd
          MarkerLayer(
            markers: _stations.where((station) => station.visited).map((station) {
              return Marker(
                point: station.geoPoints2D.toLatLng(),
                width: 15,
                height: 15,
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => {Get.to(StationPage(), arguments: [station.nom])},
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                )
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
