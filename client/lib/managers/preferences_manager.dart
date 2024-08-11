import 'package:flutter/material.dart';
import '../models/user_preferences.dart';
import '../repositories/user_repository.dart';

class PreferencesManager {
  static final PreferencesManager _instance = PreferencesManager._internal();
  factory PreferencesManager() => _instance;
  PreferencesManager._internal();

  UserPreferences? _userPreferences;
  final UserRepository _userRepository = UserRepository();

  final List<VoidCallback> _listeners = [];

  Future<void> loadPreferences(int userId) async {
    _userPreferences = await _userRepository.getUserPreferences(userId);
    _notifyListeners();
  }

  ThemeMode get themeMode {
    final themePreference = _userPreferences?.preferences.firstWhere(
      (pref) => pref.preferenceKey == 'theme_mode',
      orElse: () => UserPreference(
        userId: 0,
        preferenceKey: 'theme_mode',
        preferenceValue: 'system',
      ),
    );
    switch (themePreference?.preferenceValue) {
      case 'light':
        print('user prefers light');
        return ThemeMode.light;
      case 'dark':
        print('user prefers dark');
        return ThemeMode.dark;
      default:
        print('user prefers system');
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_userPreferences != null) {
      String themeModeString;
      switch (mode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.system:
          themeModeString = 'system';
          break;
      }
      await _userRepository.updateUserPreference(
          _userPreferences!.preferences.first.userId,
          'theme_mode',
          themeModeString);
      await loadPreferences(_userPreferences!.preferences.first.userId);
    }
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}
