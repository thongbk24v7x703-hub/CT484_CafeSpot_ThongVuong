import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cài đặt người dùng — phụ trách: Nguyễn Quốc Vương
class SettingsProvider extends ChangeNotifier {
  static const _keyDark = 'dark_mode';
  static const _keyNoti = 'notifications_enabled';
  static const _keyName = 'display_name';

  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _displayName = 'Sinh viên CT484';

  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get displayName => _displayName;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_keyDark) ?? false;
    _notificationsEnabled = prefs.getBool(_keyNoti) ?? true;
    _displayName = prefs.getString(_keyName) ?? 'Sinh viên CT484';
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDark, value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNoti, value);
    notifyListeners();
  }

  Future<void> setDisplayName(String value) async {
    _displayName = value.trim().isEmpty ? 'Sinh viên CT484' : value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, _displayName);
    notifyListeners();
  }
}
