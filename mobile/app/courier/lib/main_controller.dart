import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

final loadingStateProvider = StateProvider<bool>((_) => false);
final listLoadingStateProvider = StateProvider.family<List<bool>, int>((ref, args) {
  List<bool> loadings = [];
  for (var i = 0; i < args; i++) {
    loadings.add(false);
  }
  return loadings;
});

final sharedPrefProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final mainController = ChangeNotifierProvider<MainController>(
  (_) {
    final MainController mains = MainController(_.watch(sharedPrefProvider));
    mains.loadSettings();
    return mains;
  },
);

final locationStreamProvider = StreamProvider<LocationData>((_) => Location.instance.onLocationChanged);

class MainController extends ChangeNotifier {
  MainController([this._preferences]);
  final SharedPreferences? _preferences;
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void loadSettings() {
    int? mode = _preferences?.getInt('theme');
    if (mode == 0 || mode == null) {
      _themeMode = ThemeMode.system;
      return;
    }
    if (mode == 1) {
      _themeMode = ThemeMode.light;
      return;
    }
    _themeMode = ThemeMode.dark;
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
