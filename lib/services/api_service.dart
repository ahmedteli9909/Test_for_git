import 'package:dio/dio.dart';
import 'package:d_hawk/core/constants/api_constants.dart';
import 'package:d_hawk/core/utils/storage_helper.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = StorageHelper.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - clear token and redirect to login
            StorageHelper.clearAuth();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Authentication Methods
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> register(String email, String password, String name) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> resetPassword(String token, String newPassword) async {
    try {
      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'token': token,
          'password': newPassword,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> logout() async {
    try {
      final response = await _dio.post(ApiConstants.logout);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // User Methods
  Future<Response> getUserProfile() async {
    try {
      final response = await _dio.get(ApiConstants.getUserProfile);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        ApiConstants.updateUserProfile,
        data: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final response = await _dio.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Security Methods
  Future<Response> getThreats({int? page, int? limit}) async {
    try {
      final response = await _dio.get(
        ApiConstants.getThreats,
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getThreatDetails(String threatId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.getThreatDetails}/$threatId',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getSecurityStatus() async {
    try {
      final response = await _dio.get(ApiConstants.getSecurityStatus);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getSecurityAlerts({int? page, int? limit}) async {
    try {
      final response = await _dio.get(
        ApiConstants.getSecurityAlerts,
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getSecurityReports({DateTime? startDate, DateTime? endDate}) async {
    try {
      final response = await _dio.get(
        ApiConstants.getSecurityReports,
        queryParameters: {
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getSecurityAnalytics() async {
    try {
      final response = await _dio.get(ApiConstants.getSecurityAnalytics);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> scanSystem() async {
    try {
      final response = await _dio.post(ApiConstants.scanSystem);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getScanHistory({int? page, int? limit}) async {
    try {
      final response = await _dio.get(
        ApiConstants.getScanHistory,
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Monitoring Methods
  Future<Response> getMonitoringData() async {
    try {
      final response = await _dio.get(ApiConstants.getMonitoringData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMonitoringStats() async {
    try {
      final response = await _dio.get(ApiConstants.getMonitoringStats);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getActiveThreats() async {
    try {
      final response = await _dio.get(ApiConstants.getActiveThreats);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Settings Methods
  Future<Response> getSettings() async {
    try {
      final response = await _dio.get(ApiConstants.getSettings);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateSettings(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        ApiConstants.updateSettings,
        data: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getNotificationSettings() async {
    try {
      final response = await _dio.get(ApiConstants.getNotificationSettings);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateNotificationSettings(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        ApiConstants.updateNotificationSettings,
        data: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

