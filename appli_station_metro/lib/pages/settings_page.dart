import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../components/database_helper.dart';
import '../generated/app_localizations.dart';
import '../models/user.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final dbHelper = DatabaseHelper();
  late Database db;
  User? _user;
  String? _selectedLanguage;


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await dbHelper.db;
    final users = await db.query('user');
    if(users.isNotEmpty) {
      setState(() {
        _user = User.fromMap(users.first);
        _selectedLanguage = _user?.language ?? "fr";
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
              children: [
                Text(AppLocalizations.of(context)!.settingsLanguage),
                DropdownMenu<String>(
                  initialSelection: _selectedLanguage,
                  onSelected: (String? value) => {
                    setState(() {
                      _selectedLanguage = value;
                      _user?.language = value ?? "fr";
                      dbHelper.updateUser(_user!);
                    })
                  },
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: "fr", label: "Français"),
                    DropdownMenuEntry(value: "en", label: "English"),
                  ],
                ),
              ]
          ),
        )
    );
  }
}
