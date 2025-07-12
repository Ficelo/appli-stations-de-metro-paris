import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get homeDiscover => 'Want to discover a new station ? Try with :';

  @override
  String get homeLoading => 'Loading...';

  @override
  String get homeDirections => 'Show directions';

  @override
  String get stationVisited => 'Marked as visited';

  @override
  String get stationNotVisited => 'Not visited';

  @override
  String get profileModifyQuestion => 'Modify your username';

  @override
  String get profileUsername => 'Username';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileModify => 'Modify';

  @override
  String get settingsLanguage => 'Language : ';
}
