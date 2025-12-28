import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focusflow/models/user_model.dart';

class UserService extends ChangeNotifier {
  static const String _keyUser = 'current_user';
  static const String _keyFirstLaunch = 'first_launch';
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_keyUser);
      if (userData != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userData));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to initialize user service: $e');
    }
  }

  Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyFirstLaunch) ?? true;
    } catch (e) {
      debugPrint('Failed to check first launch: $e');
      return true;
    }
  }

  Future<void> setFirstLaunchComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyFirstLaunch, false);
    } catch (e) {
      debugPrint('Failed to set first launch: $e');
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final now = DateTime.now();
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: email.split('@').first,
        createdAt: now,
        updatedAt: now,
      );
      await _saveUser(user);
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      debugPrint('Login failed: $e');
      return null;
    }
  }

  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final now = DateTime.now();
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        createdAt: now,
        updatedAt: now,
      );
      await _saveUser(user);
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      debugPrint('Sign up failed: $e');
      return null;
    }
  }

  Future<UserModel?> skipLogin() async {
    try {
      final now = DateTime.now();
      final user = UserModel(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@focusflow.app',
        name: 'Guest User',
        createdAt: now,
        updatedAt: now,
      );
      await _saveUser(user);
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      debugPrint('Skip login failed: $e');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      final updated = user.copyWith(updatedAt: DateTime.now());
      await _saveUser(updated);
      _currentUser = updated;
      notifyListeners();
    } catch (e) {
      debugPrint('Update user failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUser);
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout failed: $e');
    }
  }

  Future<void> _saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Failed to save user: $e');
    }
  }
}
