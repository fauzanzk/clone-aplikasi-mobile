import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _user;
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null && _apiService.token != null;

  Future<void> init() async {
    await _apiService.init();
    if (_apiService.token != null) {
      await fetchProfile();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.login(email, password);
      if (res['success'] == true) {
        _user = UserModel.fromJson(res['data']['user']);
        await fetchProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Email atau password salah';
      }
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server backend: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String? phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.register(name, email, phone, password);
      if (res['success'] == true) {
        _user = UserModel.fromJson(res['data']['user']);
        await fetchProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Gagal melakukan pendaftaran';
      }
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server backend: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchProfile() async {
    try {
      final res = await _apiService.getProfile();
      if (res['success'] == true) {
        _user = UserModel.fromJson(res['data']['user']);
        _stats = res['data']['stats'];
        notifyListeners();
      }
    } catch (e) {
      // Ignored
    }
  }

  Future<bool> updateProfile(String name, String? phone) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _apiService.updateProfile(name, phone);
      if (res['success'] == true) {
        _user = UserModel.fromJson(res['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Error
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _apiService.setToken(null);
    _user = null;
    _stats = null;
    notifyListeners();
  }
}
