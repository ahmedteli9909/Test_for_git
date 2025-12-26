import 'package:flutter/foundation.dart';
import 'package:d_hawk/models/threat_model.dart';
import 'package:d_hawk/models/security_status_model.dart';
import 'package:d_hawk/services/api_service.dart';

class SecurityProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  SecurityStatusModel? _securityStatus;
  List<ThreatModel> _threats = [];
  List<ThreatModel> _alerts = [];
  bool _isLoading = false;
  String? _error;
  bool _isScanning = false;

  SecurityStatusModel? get securityStatus => _securityStatus;
  List<ThreatModel> get threats => _threats;
  List<ThreatModel> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isScanning => _isScanning;

  Future<void> loadSecurityStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getSecurityStatus();
      if (response.statusCode == 200) {
        _securityStatus = SecurityStatusModel.fromJson(response.data);
      }
    } catch (e) {
      _error = 'Failed to load security status';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadThreats({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getThreats(page: page, limit: limit);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['threats'] != null) {
          _threats = (data['threats'] as List)
              .map((json) => ThreatModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      _error = 'Failed to load threats';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAlerts({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getSecurityAlerts(page: page, limit: limit);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['alerts'] != null) {
          _alerts = (data['alerts'] as List)
              .map((json) => ThreatModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      _error = 'Failed to load alerts';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> scanSystem() async {
    _isScanning = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.scanSystem();
      _isScanning = false;
      if (response.statusCode == 200) {
        // Reload security status after scan
        await loadSecurityStatus();
        await loadThreats();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to start scan';
      _isScanning = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}



