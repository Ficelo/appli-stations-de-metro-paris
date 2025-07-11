import 'package:appli_station_metro/pages/station_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../components/constants.dart';
import '../models/loader.dart';
import '../models/station.dart';

List<String> allStations = [];

class MetroIcon extends StatelessWidget {
  final String line;
  final Function(String) onTap;

  const MetroIcon({super.key, required this.line, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: GestureDetector(
        onTap: () => onTap(line),
        child: SizedBox(
          width: 64,
          height: 64,
          child: SvgPicture.asset(
            "assets/icones_lignes/metro_ligne_$line.svg",
          ),
        ),
      ),
    );
  }
}

class MetroStation extends StatelessWidget {
  final List<String> lines;
  final bool visited;
  final String name;
  final String currentLine;

  const MetroStation({
    super.key,
    required this.lines,
    required this.visited,
    required this.name,
    required this.currentLine,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(StationPage(), arguments: [name]);
      },
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 16.0,
                  height: 100.0,
                  color: Color(Constantes.couleursLignes[currentLine]!),
                ),
                Container(
                  width: 64.0,
                  height: 64.0,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                    color: (lines.length > 1)
                        ? Colors.white
                        : Color(Constantes.couleursLignes[currentLine]!),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Container(
                  height: 64.0,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 24.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  String _currentLine = "1";
  Map<String, Station> _stationMap = {};



  @override
  void initState() {
    super.initState();
    for (var ligne in Constantes.reseauComplet) {
      for (var station in ligne) {
        if (!allStations.contains(station)){
          allStations.add(station);
        }
      }
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final stations = await Loader.loadStations();
    final map = {for (var s in stations) s.nom: s};

    setState(() {
      _stationMap = map;
    });
  }

  void _changeCurrentLine(String line) {
    setState(() {
      _currentLine = line;
    });
  }

  int _getLineIndex(String line) {
    const lines = ["1", "2", "3", "3b", "4", "5", "6", "7", "7b", "8", "9", "10", "11", "12", "13", "14"];
    return lines.indexOf(line);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 16.0, top: 16.0),
            child: SearchAnchor.bar(
              suggestionsBuilder: (BuildContext context, SearchController controller) {
                final String input = controller.value.text;
                return allStations
                    .where((station) => station.toLowerCase().contains(input.toLowerCase()))
                    .map((stationFiltered) => ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  title: Text(stationFiltered),
                  onTap: () => {
                    Get.to(StationPage(), arguments: [stationFiltered])
                  },
                ));
              },
            ),
          ),
          SizedBox(
            height: 64.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: Constantes.couleursLignes.keys
                  .where((key) => key != "7bis" && key != "3bis")
                  .map((key) => MetroIcon(line: key, onTap: _changeCurrentLine))
                  .toList(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Builder(
                builder: (_) {
                  final int index = _getLineIndex(_currentLine);
                  final List<String> lineStations =
                  Constantes.reseauComplet[index];

                  return ListView(
                    scrollDirection: Axis.vertical,
                    children: lineStations
                        .map((stationName) {
                          final station = _stationMap[stationName];
                          if (station == null) return const SizedBox.shrink();

                          return MetroStation(
                            lines: station.lines,
                            visited: station.visited,
                            name: station.nom,
                            currentLine: _currentLine,
                          );
                        }
                    ).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
