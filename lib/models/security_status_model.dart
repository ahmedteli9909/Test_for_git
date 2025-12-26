class SecurityStatusModel {
  final String overallStatus; // safe, warning, critical
  final int totalThreats;
  final int activeThreats;
  final int resolvedThreats;
  final double securityScore; // 0-100
  final DateTime lastScan;
  final Map<String, int> threatsByLevel;
  final List<String> recommendations;

  SecurityStatusModel({
    required this.overallStatus,
    required this.totalThreats,
    required this.activeThreats,
    required this.resolvedThreats,
    required this.securityScore,
    required this.lastScan,
    required this.threatsByLevel,
    required this.recommendations,
  });

  factory SecurityStatusModel.fromJson(Map<String, dynamic> json) {
    return SecurityStatusModel(
      overallStatus: json['overall_status'] ?? 'safe',
      totalThreats: json['total_threats'] ?? 0,
      activeThreats: json['active_threats'] ?? 0,
      resolvedThreats: json['resolved_threats'] ?? 0,
      securityScore: (json['security_score'] ?? 0.0).toDouble(),
      lastScan: json['last_scan'] != null
          ? DateTime.parse(json['last_scan'])
          : DateTime.now(),
      threatsByLevel: Map<String, int>.from(json['threats_by_level'] ?? {}),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_status': overallStatus,
      'total_threats': totalThreats,
      'active_threats': activeThreats,
      'resolved_threats': resolvedThreats,
      'security_score': securityScore,
      'last_scan': lastScan.toIso8601String(),
      'threats_by_level': threatsByLevel,
      'recommendations': recommendations,
    };
  }
}



