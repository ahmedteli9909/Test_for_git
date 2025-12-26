import 'package:d_hawk/core/utils/storage_helper.dart';
import 'package:d_hawk/models/user_model.dart';
import 'package:d_hawk/services/api_service.dart';
import 'dart:convert';

class AuthService {
  final ApiService _apiService = ApiService();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['token'] != null) {
          await StorageHelper.saveToken(data['token']);
          if (data['user'] != null) {
            _currentUser = UserModel.fromJson(data['user']);
            await StorageHelper.saveUserData(jsonEncode(data['user']));
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await _apiService.register(email, password, name);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['token'] != null) {
          await StorageHelper.saveToken(data['token']);
          if (data['user'] != null) {
            _currentUser = UserModel.fromJson(data['user']);
            await StorageHelper.saveUserData(jsonEncode(data['user']));
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _apiService.forgotPassword(email);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _apiService.resetPassword(token, newPassword);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore errors during logout
    } finally {
      await StorageHelper.clearAuth();
      _currentUser = null;
    }
  }

  Future<bool> checkAuth() async {
    final token = StorageHelper.getToken();
    if (token == null) return false;

    final userData = StorageHelper.getUserData();
    if (userData != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userData));
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<void> loadUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();
      if (response.statusCode == 200) {
        _currentUser = UserModel.fromJson(response.data['user'] ?? response.data);
        await StorageHelper.saveUserData(
          jsonEncode(_currentUser!.toJson()),
        );
      }
    } catch (e) {
      // Handle error
    }
  }
}



