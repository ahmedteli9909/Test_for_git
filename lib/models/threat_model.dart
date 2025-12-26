import 'package:flutter/material.dart';

enum ThreatLevel {
  low,
  medium,
  high,
  critical,
}

enum ThreatStatus {
  active,
  resolved,
  investigating,
}

class ThreatModel {
  final String id;
  final String title;
  final String description;
  final ThreatLevel level;
  final ThreatStatus status;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final String? source;
  final String? category;

  ThreatModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.status,
    required this.detectedAt,
    this.resolvedAt,
    this.source,
    this.category,
  });

  factory ThreatModel.fromJson(Map<String, dynamic> json) {
    return ThreatModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      level: _parseThreatLevel(json['level']),
      status: _parseThreatStatus(json['status']),
      detectedAt: json['detected_at'] != null
          ? DateTime.parse(json['detected_at'])
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      source: json['source'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level.name,
      'status': status.name,
      'detected_at': detectedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'source': source,
      'category': category,
    };
  }

  static ThreatLevel _parseThreatLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'low':
        return ThreatLevel.low;
      case 'medium':
        return ThreatLevel.medium;
      case 'high':
        return ThreatLevel.high;
      case 'critical':
        return ThreatLevel.critical;
      default:
        return ThreatLevel.medium;
    }
  }

  static ThreatStatus _parseThreatStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return ThreatStatus.active;
      case 'resolved':
        return ThreatStatus.resolved;
      case 'investigating':
        return ThreatStatus.investigating;
      default:
        return ThreatStatus.active;
    }
  }

  Color get levelColor {
    switch (level) {
      case ThreatLevel.low:
        return const Color(0xFF10B981);
      case ThreatLevel.medium:
        return const Color(0xFFF59E0B);
      case ThreatLevel.high:
        return const Color(0xFFEF4444);
      case ThreatLevel.critical:
        return const Color(0xFFDC2626);
    }
  }
}

