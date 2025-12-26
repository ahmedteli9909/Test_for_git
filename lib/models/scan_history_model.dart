enum ScanStatus {
  pending,
  running,
  completed,
  failed,
}

class ScanHistoryModel {
  final String id;
  final ScanStatus status;
  final int threatsFound;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? error;
  final Map<String, dynamic>? scanDetails;

  ScanHistoryModel({
    required this.id,
    required this.status,
    required this.threatsFound,
    required this.startedAt,
    this.completedAt,
    this.error,
    this.scanDetails,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id'] ?? '',
      status: _parseScanStatus(json['status']),
      threatsFound: json['threats_found'] ?? 0,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      error: json['error'],
      scanDetails: json['scan_details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'threats_found': threatsFound,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'error': error,
      'scan_details': scanDetails,
    };
  }

  static ScanStatus _parseScanStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return ScanStatus.pending;
      case 'running':
        return ScanStatus.running;
      case 'completed':
        return ScanStatus.completed;
      case 'failed':
        return ScanStatus.failed;
      default:
        return ScanStatus.pending;
    }
  }

  Duration? get duration {
    if (completedAt != null) {
      return completedAt!.difference(startedAt);
    }
    return null;
  }
}



