import 'dart:convert';
import 'package:flutter/services.dart';
import 'station.dart';
import 'metro_line.dart';

class Loader {

  static Future<List<Station>> loadStations() async {
    final String jsonString = await rootBundle.loadString('assets/stations.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => Station.fromJson(e)).toList();
  }

  static Future<List<MetroLine>> loadLines() async {
    final String jsonString = await rootBundle.loadString('assets/lignes.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => MetroLine.fromJson(e)).toList();
  }

}