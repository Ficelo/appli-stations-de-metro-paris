import 'package:appli_station_metro/components/database_helper.dart';
import 'package:appli_station_metro/pages/list_page.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../components/constants.dart';
import '../models/loader.dart';
import '../models/station.dart';
import '../models/user.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final dbHelper = DatabaseHelper();
  late Database db;
  User? _user;
  List<Station> _stations = [];
  final List<String> _lines = ["1", "2", "3", "3bis", "4", "5", "6", "7", "7b", "8", "9", "10", "11", "12", "13", "14"];
  Map<String, int> _ligneVisited = {};
  Map<String, int> _lignesTaille = {};

  Future<void> _loadState() async {
    db = await dbHelper.db;
    final users = await db.query('user');
    if (users.isNotEmpty) {
      setState(() {
        _user = User.fromMap(users.first);
      });
      print('Loaded user: ${_user!.username}');
    } else {
      print('No users found');
    }

    final stations = await Loader.loadStations();
    final lines = await Loader.loadLines();

    Map<String, int> visitedMap = {};
    Map<String, int> totalMap = {};

    for (var line in lines) {
      visitedMap[line.ligne] = 0;
      totalMap[line.ligne] = 0;
    }

    for (var station in stations) {
      final sta = await dbHelper.getStationByName(station.nom);
      final visited = await dbHelper.hasUserVisitedStation(1, sta?["id"] ?? 1);
      station.visited = visited;

      for (var line in station.lines) {
        totalMap[line] = (totalMap[line] ?? 0) + 1;
        if (visited) {
          visitedMap[line] = (visitedMap[line] ?? 0) + 1;
        }
      }
    }

    setState(() {
      _stations = stations;
      _ligneVisited = visitedMap;
      _lignesTaille = totalMap;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalStations = _stations.length;
    final totalVisited = _stations.where((station) => station.visited).length;
    final totalColor = Colors.blue.value;

    return SafeArea(
      child: Column(
        children: [
          const Center(
            child: Icon(Icons.account_circle_outlined, size: 100.0),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IgnorePointer(child: IconButton(icon: Icon(Icons.edit, color: Colors.transparent), onPressed: () {})),
                Text(_user?.username ?? "", style: const TextStyle(fontSize: 24)),
                IconButton(
                  onPressed: () {
                    final TextEditingController controller = TextEditingController(text: _user?.username ?? "");
                    showDialog(context: context,
                        builder: (BuildContext context) => Dialog(
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 300,
                                  height: 180,
                                  child: Column(
                                  children: [
                                    Text("Modification de votre nom d'utilisateur", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                    const SizedBox(height: 14.0),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                                      child: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          labelText: "Nom d'utilisateur",
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.blue,
                                              side: const BorderSide(color: Colors.blue),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: const Text("Annuler"),
                                          ),
                                        ),
                                        const SizedBox(width: 16), // Space between buttons
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _user?.username = controller.text;
                                              dbHelper.updateUser(_user!);
                                              Navigator.of(context).pop();
                                              setState(() {
                                                _user?.username = controller.text;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: const Text("Modifier"),
                                          ),
                                        ),
                                      ],
                                    ),
                                    )
                                  ],
                                )
                              )
                          ),
                        ));
                  },
                  icon: const Icon(Icons.edit),
                )
              ],
            ),
          ),

          // Divider before total progress bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Divider(color: Colors.black),
          ),

          // Total progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                const Text("Total : ",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(totalColor).withAlpha(50),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: LinearProgressIndicator(
                          value: totalStations == 0 ? 0 : totalVisited / totalStations,
                          color: Color(totalColor),
                          backgroundColor: Colors.transparent,
                          minHeight: 32,
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            "$totalVisited / $totalStations",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider after total progress bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Divider(color: Colors.black),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: _lines.map((line) {
                    final lineName = line;
                    final visited = _ligneVisited[lineName] ?? 0;
                    final total = _lignesTaille[lineName] ?? 1;
                    final lineColor = Constantes.couleursLignes[lineName] ?? 0xFFFFF000;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          MetroIcon(line: lineName, onTap: (l) => {}),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Color(lineColor).withAlpha(50),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: LinearProgressIndicator(
                                      value: total == 0 ? 0 : visited / total,
                                      color: Color(lineColor),
                                      backgroundColor: Colors.transparent,
                                      minHeight: 32,
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Center(
                                      child: Text(
                                        "$visited / $total",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
