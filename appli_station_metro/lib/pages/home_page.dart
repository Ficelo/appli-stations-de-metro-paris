import 'dart:convert';
import 'dart:math';

import 'package:appli_station_metro/generated/app_localizations.dart';
import 'package:appli_station_metro/pages/station_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/database_helper.dart';
import '../models/loader.dart';
import '../models/station.dart';

import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;
  late double destinationLat;
  late double destinationLng;
  List<Station> _stations = [];
  Station? station;
  final dbHelper = DatabaseHelper();
  late Database db;
  Map<String, dynamic>? wikiData;
  bool isLoading = true;

  static const double imageHeight = 300;
  static const double imageWidth = double.infinity;

  Widget _buildWikiSection() {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: imageHeight, width: imageWidth, color: Colors.white),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: wikiData?['image'] != null
              ? ClipRRect(
            key: ValueKey(wikiData!['image']),
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              wikiData!['image'],
              height: imageHeight,
              width: imageWidth,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: imageHeight,
                  width: imageWidth,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: imageHeight,
                width: imageWidth,
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.broken_image, size: 50)),
              ),
            ),
          )
              : Container(
            key: const ValueKey('no_image'),
            height: imageHeight,
            width: imageWidth,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stations = await Loader.loadStations();
    List<Station> tempStations = [];
    final random = Random();

    for (var s in stations) {
      final sta = await dbHelper.getStationByName(s.nom);
      final vis = await dbHelper.hasUserVisitedStation(1, sta?["id"] ?? 1);

      if (!vis) {
        tempStations.add(s);
      }
    }

    final selectedStation = tempStations[random.nextInt(tempStations.length)];

    final wikipediaData = await fetchWikipediaInfo(selectedStation.nom);

    setState(() {
      _stations = tempStations;
      station = selectedStation;
      destinationLat = selectedStation.geoPoints2D.lat;
      destinationLng = selectedStation.geoPoints2D.lon;
      wikiData = wikipediaData;
      isLoading = false;
    });
  }

  Future<void> _getNewRandomStation() async {
    setState(() {
      isLoading = true;
    });

    final random = Random();
    final Station tempStation = _stations[random.nextInt(_stations.length)];

    final wikipediaData = await fetchWikipediaInfo(tempStation.nom);

    setState(() {
      station = tempStation;
      destinationLat = tempStation.geoPoints2D.lat;
      destinationLng = tempStation.geoPoints2D.lon;
      wikiData = wikipediaData;
      isLoading = false;
    });
  }

  Future<Map<String, dynamic>?> fetchWikipediaInfo(String stationName) async {
    final encodedName = Uri.encodeComponent('${stationName}_(métro_de_Paris)');
    final url = 'https://fr.wikipedia.org/api/rest_v1/page/summary/$encodedName';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'title': data['title'],
        'extract': data['extract'],
        'image': data['thumbnail']?['source'],
      };
    } else {
      print('Wikipedia error: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _getCurrentLocationAndLaunchMap() async {
    setState(() {
      _loading = true;
    });

    try {

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _loading = false;
      });

      final encodedStationName = Uri.encodeComponent("${station!.nom} Métro Paris");

      final url = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=$encodedStationName&travelmode=transit');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Google Maps')),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.homeDiscover,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => {
                    if(station?.nom != null) {
                      Get.to(StationPage(), arguments: [station?.nom])
                    }

                  },
                  child: Text(
                    station?.nom ?? AppLocalizations.of(context)!.homeLoading,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _getNewRandomStation,
                  child: _buildWikiSection(),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(AppLocalizations.of(context)!.homeDirections),
                  onPressed: _loading ? null : _getCurrentLocationAndLaunchMap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
