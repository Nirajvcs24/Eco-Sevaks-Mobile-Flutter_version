import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/router.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _user;
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _user = await _apiService.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final userData = await _apiService.login(email, password);
      _user = AppUser.fromJson(userData);
      notifyListeners();
      AppRouter.refreshNotifier.refresh();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password, String role) async {
    try {
      await _apiService.register(name, email, password, role);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    notifyListeners();
    AppRouter.refreshNotifier.refresh();
  }
}
