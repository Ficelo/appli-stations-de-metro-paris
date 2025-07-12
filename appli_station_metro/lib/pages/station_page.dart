import 'dart:convert';
import 'package:appli_station_metro/components/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../generated/app_localizations.dart';
import '../models/loader.dart';
import '../models/user.dart';


class StationPage extends StatefulWidget {
  const StationPage({super.key});

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  late String stationName;
  late int stationId;
  Map<String, dynamic>? wikiData;
  final dbHelper = DatabaseHelper();
  late Database db;
  bool visited = false;
  bool isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? ['Unknown'];
    stationName = args[0].toString();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await dbHelper.db;
    final users = await db.query('user');
    if (users.isNotEmpty) {
      setState(() {
        _user = User.fromMap(users.first);
      });
    }

    final stations = await Loader.loadStations();
    final sta = await dbHelper.getStationByName(stationName);
    final vis = await dbHelper.hasUserVisitedStation(1, sta?["id"] ?? 1);
    final wikipediaData = await fetchWikipediaInfo(stationName);


    for (var s in stations) {
      if (stationName == s.nom) {
        setState(() {
        });
      }
    }

    setState(() {
      wikiData = wikipediaData;
      visited = vis;
      stationId = sta?["id"] ?? 1;
      isLoading = false;
    });
  }

  Future<Map<String, dynamic>?> fetchWikipediaInfo(String stationName) async {

    final encodedTitle = Uri.encodeComponent((_user?.language == "fr") ? '${stationName}_(métro_de_Paris)' : '${stationName}_station');
    final summaryUrl = (_user?.language == "fr") ? 'https://fr.wikipedia.org/api/rest_v1/page/summary/$encodedTitle' : 'https://en.wikipedia.org/api/rest_v1/page/summary/$encodedTitle';

    final summaryResponse = await http.get(Uri.parse(summaryUrl));

    if (summaryResponse.statusCode != 200) {
      print('Wikipedia summary error: ${summaryResponse.statusCode}');
      return null;
    }

    final summaryData = json.decode(summaryResponse.body);

    return {
      'title': summaryData['title'],
      'extract': summaryData['extract'],
      'image': summaryData['thumbnail']?['source'],
    };
  }


  Widget _buildWikiSection() {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 180, width: double.infinity, color: Colors.white),
            SizedBox(height: 12),
            Container(height: 20, width: double.infinity, color: Colors.white),
            SizedBox(height: 8),
            Container(height: 16, width: 200, color: Colors.white),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wikiData?['image'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(wikiData!['image'], fit: BoxFit.cover),
          ),
        const SizedBox(height: 12),
        Text(
          wikiData?['extract'] ?? "Aucune description disponible.",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(stationName)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: _buildWikiSection(),
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Checkbox(
                  value: visited,
                  onChanged: (bool? value) async {
                    if (value == true) {
                      await dbHelper.markStationVisited(1, stationId);
                    } else {
                      await dbHelper.unmarkStationVisited(1, stationId);
                    }
                    setState(() {
                      visited = value ?? false;
                    });
                  },
                ),
                title: Text(
                  visited ? AppLocalizations.of(context)!.stationVisited : AppLocalizations.of(context)!.stationNotVisited,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
