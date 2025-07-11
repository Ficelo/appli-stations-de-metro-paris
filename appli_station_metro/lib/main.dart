import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/database_helper.dart';
import 'pages/map_page.dart';
import 'pages/profil_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/list_page.dart';
import 'models/loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();

  final db = await dbHelper.db;

  final users = await db.query('user');
  if (users.isEmpty) {
    await db.insert('user', {
      'username': 'default_user',
      'language': 'fr',
    });
  }

  final stations = await db.query('station');
  if(stations.isEmpty) {
    final stationsDefault = await Loader.loadStations();
    for (var s in stationsDefault) {
      await db.insert('station', {
        'nom' : s.nom,
        'note' : 0
      });
    }
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bottom Nav App',
      theme: ThemeData(useMaterial3: true),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;

  final List<Widget> _pages = [
    ListPage(),
    MapPage(),
    HomePage(),
    ProfilPage(),
    SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
