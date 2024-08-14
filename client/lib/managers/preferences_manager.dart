import 'package:clinicbro/utils/theme_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/preference_map.dart';
import '../models/user_preferences.dart';
import '../repositories/user_repository.dart';

class PreferencesManager {
  static final PreferencesManager _instance = PreferencesManager._internal();
  factory PreferencesManager() => _instance;
  PreferencesManager._internal();

  UserPreferences? _userPreferences;
  final UserRepository _userRepository = UserRepository();

  final List<VoidCallback> _listeners = [];

  PreferenceMap? _allPreferences;

  Future<void> reloadAllPreferences(int userId) async {
    _allPreferences = await _userRepository.getAllPreferences();
  }

  Future<void> reloadUserPreferences(int userId) async {
    _userPreferences = await _userRepository.getUserPreferences(userId);
    _notifyListeners();
  }

  Future<void> updateUserPreference(
      String preferenceKey, String preferenceValue) async {
    if (_userPreferences != null) {
      await _userRepository.updateUserPreference(
        _userPreferences!.userId,
        preferenceKey,
        preferenceValue,
      );
      await reloadUserPreferences(_userPreferences!.userId);
    }
  }

  Future<PreferenceMap?> getAllPreferences() async {
    _allPreferences ??= await _userRepository.getAllPreferences();
    return _allPreferences;
  }

  String? getUserPreference(String preferenceKey) {
    return _userPreferences!.preferences[preferenceKey];
  }

  Future<void> setUserPreference(
      String preferenceKey, String preferenceValue) async {
    await _userRepository.updateUserPreference(
        _userPreferences!.userId, preferenceKey, preferenceValue);
    await reloadUserPreferences(_userPreferences!.userId);
  }

  String _getPreferenceValue(String preferenceKey, String defaultValue) {
    final preferenceValue = _userPreferences?.preferences[preferenceKey] ??
        _allPreferences?[preferenceKey]?.first ??
        defaultValue;
    return preferenceValue;
  }

  ThemeMode get themeMode {
    return stringToThemeMode(_getPreferenceValue('theme_mode', 'system'));
  }

  String get fontFamily {
    return _getPreferenceValue('font_family', 'Fira Sans');
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

class EditPreferencesModel {
  ThemeMode themeMode;
  String fontFamily;
  EditPreferencesModel(this.themeMode, this.fontFamily);
}
