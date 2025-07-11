import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _db;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE login (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user TEXT NOT NULL,
        password TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        language TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE station (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        note INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE visited (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        stationId INTEGER,
        FOREIGN KEY(userId) REFERENCES user(id),
        FOREIGN KEY(stationId) REFERENCES station(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE avis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stationId INTEGER,
        userId INTEGER,
        text TEXT,
        note INTEGER,
        FOREIGN KEY(stationId) REFERENCES station(id),
        FOREIGN KEY(userId) REFERENCES user(id)
      );
    ''');
  }

  // USER HELPERS

  Future<Map<String, dynamic>?> getUser(String username) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'user',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertUser(String username, String language) async {
    final dbClient = await db;
    return await dbClient.insert('user', {
      'username': username,
      'language': language,
    });
  }

  Future<void> updateUser(User user) async {
    final dbClient = await db;
    await dbClient.update(
      'user',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // STATION HELPERS

  Future<int> insertStation(String nom, int note) async {
    final dbClient = await db;
    return await dbClient.insert('station', {
      'nom': nom,
      'note': note,
    });
  }

  Future<List<Map<String, dynamic>>> getAllStations() async {
    final dbClient = await db;
    return await dbClient.query('station');
  }

  Future<Map<String, dynamic>?> getStationById(int id) async {
    final dbClient = await db;
    final result = await dbClient.query('station', where: 'id = ?', whereArgs: [id], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getStationByName(String name) async {
    final dbClient = await db;
    final result = await dbClient.query('station', where: 'nom = ?', whereArgs: [name], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateStationNote(int id, int newNote) async {
    final dbClient = await db;
    return await dbClient.update(
      'station',
      {'note': newNote},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// VISITED HELPERS

  Future<int> markStationVisited(int userId, int stationId) async {
    final dbClient = await db;
    return await dbClient.insert('visited', {
      'userId': userId,
      'stationId': stationId,
    });
  }

  Future<int> unmarkStationVisited(int userId, int stationId) async {
    final dbClient = await db;
    return await dbClient.delete(
      'visited',
      where: 'userId = ? AND stationId = ?',
      whereArgs: [userId, stationId],
    );
  }

  Future<bool> hasUserVisitedStation(int userId, int stationId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'visited',
      where: 'userId = ? AND stationId = ?',
      whereArgs: [userId, stationId],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getVisitedStations(int userId) async {
    final dbClient = await db;
    return await dbClient.query(
      'visited',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // AVIS HELPERS

  Future<int> insertAvis(int stationId, int userId, String text, int note) async {
    final dbClient = await db;
    return await dbClient.insert('avis', {
      'stationId': stationId,
      'userId': userId,
      'text': text,
      'note': note,
    });
  }

  Future<List<Map<String, dynamic>>> getAvisByStation(int stationId) async {
    final dbClient = await db;
    return await dbClient.query(
      'avis',
      where: 'stationId = ?',
      whereArgs: [stationId],
    );
  }

  Future<double> getAverageNoteForStation(int stationId) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery('''
    SELECT AVG(note) as avgNote FROM avis WHERE stationId = ?
  ''', [stationId]);

    return result.first['avgNote'] != null ? (result.first['avgNote'] as double) : 0.0;
  }


}
