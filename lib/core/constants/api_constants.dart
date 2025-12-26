class ApiConstants {
  // Base URL - Update this with your actual API base URL
  static const String baseUrl = 'https://api.dhawk.com/v1';
  
  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  
  // User Endpoints
  static const String getUserProfile = '/user/profile';
  static const String updateUserProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  
  // Security Endpoints
  static const String getThreats = '/security/threats';
  static const String getThreatDetails = '/security/threats';
  static const String getSecurityStatus = '/security/status';
  static const String getSecurityAlerts = '/security/alerts';
  static const String getSecurityReports = '/security/reports';
  static const String getSecurityAnalytics = '/security/analytics';
  static const String scanSystem = '/security/scan';
  static const String getScanHistory = '/security/scan-history';
  
  // Monitoring Endpoints
  static const String getMonitoringData = '/monitoring/data';
  static const String getMonitoringStats = '/monitoring/stats';
  static const String getActiveThreats = '/monitoring/active-threats';
  
  // Settings Endpoints
  static const String getSettings = '/settings';
  static const String updateSettings = '/settings';
  static const String getNotificationSettings = '/settings/notifications';
  static const String updateNotificationSettings = '/settings/notifications';
}



