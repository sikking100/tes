import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';

import 'package:api/api.dart' hide Location;

final apiProvider = Provider<Api>((_) {
  return Api(FirebaseAuth.instance);
});
final sharedPrefProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final locationProvider = FutureProvider.autoDispose((_) async => Location.instance.getLocation());

final mainController = ChangeNotifierProvider<MainController>(
  (_) {
    final MainController mains = MainController(_.watch(sharedPrefProvider));
    mains.loadSettings();
    return mains;
  },
);

final loadingProvider = StateProvider.autoDispose<bool>((_) {
  return false;
});

final manyLodingProvider = StateProvider<Map<int, bool>>((ref) {
  return {};
});

class MainController extends ChangeNotifier {
  MainController([this._preferences]);
  final SharedPreferences? _preferences;
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void loadSettings() {
    int? mode = _preferences?.getInt('theme');
    if (mode == 2) {
      _themeMode = ThemeMode.dark;
      return;
    }
    if (mode == 0) {
      _themeMode = ThemeMode.system;
      return;
    }
    _themeMode = ThemeMode.light;
    return;
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    _preferences?.setInt('theme', newThemeMode.index);
  }
}

class ModelTracking {
  final double courierLat;
  final double courierLng;
  final double heading;
  final double cusLat;
  final double cusLng;
  final String overviewPolyline;

  ModelTracking({this.cusLat = 0.0, this.cusLng = 0.0, this.courierLat = 0.0, this.courierLng = 0.0, this.heading = 0.0, this.overviewPolyline = ''});

  factory ModelTracking.fromMap(Map<String, dynamic> map) {
    return ModelTracking(
      courierLat: map['courier']['lat']?.toDouble() ?? 0.0,
      courierLng: map['courier']['lng']?.toDouble() ?? 0.0,
      heading: map['courier']['heading']?.toDouble() ?? 0.0,
      cusLat: map['customer']['lat']?.toDouble() ?? 0.0,
      cusLng: map['customer']['lng']?.toDouble() ?? 0.0,
      overviewPolyline: map['overviewPolyline'] ?? '',
    );
  }
}
