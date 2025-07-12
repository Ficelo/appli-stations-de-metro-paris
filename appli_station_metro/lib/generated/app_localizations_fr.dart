import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get helloWorld => 'Bonjour Monde!';

  @override
  String get homeDiscover => 'Envie de découvrir une nouvelle station ? Essayez avec :';

  @override
  String get homeLoading => 'Chargement...';

  @override
  String get homeDirections => 'Afficher les directions';

  @override
  String get stationVisited => 'Marquée comme visitée';

  @override
  String get stationNotVisited => 'Non visitée';

  @override
  String get profileModifyQuestion => 'Modification de votre nom d\'utilisateur';

  @override
  String get profileUsername => 'Nom d\'utilisateur';

  @override
  String get profileCancel => 'Annuler';

  @override
  String get profileModify => 'Modifier';

  @override
  String get settingsLanguage => 'Langue : ';
}
