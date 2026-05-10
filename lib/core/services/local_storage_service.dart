import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  static const String _userBox = 'user_box';
  static const String _tripsBox = 'trips_box';
  static const String _settingsBox = 'settings_box';

  /// Call once in main() before runApp
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    await Hive.openBox<Map>(_userBox);
    await Hive.openBox<Map>(_tripsBox);
    await Hive.openBox(_settingsBox);
  }

  // ─── User ────────────────────────────────────────────────────
  Box<Map> get _user => Hive.box<Map>(_userBox);

  void saveUser(Map<String, dynamic> user) =>
      _user.put('current_user', user);

  Map<String, dynamic>? getUser() {
    final raw = _user.get('current_user');
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw);
  }

  void clearUser() => _user.delete('current_user');

  // ─── Trips ───────────────────────────────────────────────────
  Box<Map> get _trips => Hive.box<Map>(_tripsBox);

  List<Map<String, dynamic>> getAllTrips() {
    return _trips.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  void saveTrip(Map<String, dynamic> trip) {
    final id = trip['id'] as String;
    _trips.put(id, trip);
  }

  void deleteTrip(String id) => _trips.delete(id);

  Map<String, dynamic>? getTrip(String id) {
    final raw = _trips.get(id);
    return raw == null ? null : Map<String, dynamic>.from(raw);
  }

  // ─── Settings ────────────────────────────────────────────────
  Box get _settings => Hive.box(_settingsBox);

  dynamic getSetting(String key, {dynamic defaultValue}) =>
      _settings.get(key, defaultValue: defaultValue);

  void setSetting(String key, dynamic value) => _settings.put(key, value);
}

/// Global singleton – use via ref.watch/read after registering as a Provider
final localStorageService = LocalStorageService();
