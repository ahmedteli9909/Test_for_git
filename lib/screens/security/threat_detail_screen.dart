import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:d_hawk/providers/security_provider.dart';
import 'package:d_hawk/services/api_service.dart';
import 'package:d_hawk/models/threat_model.dart';
import 'package:d_hawk/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ThreatDetailScreen extends StatefulWidget {
  final String threatId;

  const ThreatDetailScreen({super.key, required this.threatId});

  @override
  State<ThreatDetailScreen> createState() => _ThreatDetailScreenState();
}

class _ThreatDetailScreenState extends State<ThreatDetailScreen> {
  ThreatModel? _threat;

  @override
  void initState() {
    super.initState();
    _loadThreatDetails();
  }

  Future<void> _loadThreatDetails() async {
    final provider = Provider.of<SecurityProvider>(context, listen: false);
    final apiService = ApiService();
    try {
      final response = await apiService.getThreatDetails(widget.threatId);
      if (response.statusCode == 200) {
        setState(() {
          _threat = ThreatModel.fromJson(response.data);
        });
      }
    } catch (e) {
      // Find threat from list if API fails
      final threats = provider.threats;
      if (threats.isNotEmpty) {
        try {
          final threat = threats.firstWhere(
            (t) => t.id == widget.threatId,
          );
          setState(() {
            _threat = threat;
          });
        } catch (e) {
          setState(() {
            _threat = _createDummyThreat();
          });
        }
      } else {
        setState(() {
          _threat = _createDummyThreat();
        });
      }
    }
  }

  ThreatModel _createDummyThreat() {
    return ThreatModel(
      id: widget.threatId,
      title: 'Unknown Threat',
      description: 'Threat details not available',
      level: ThreatLevel.medium,
      status: ThreatStatus.active,
      detectedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_threat == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Threat Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Threat Level Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _threat!.levelColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: _threat!.levelColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _threat!.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _threat!.levelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _threat!.level.name.toUpperCase(),
                              style: TextStyle(
                                color: _threat!.levelColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _threat!.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Detected At',
                      value: DateFormat('MMM dd, yyyy • HH:mm')
                          .format(_threat!.detectedAt),
                    ),
                    if (_threat!.resolvedAt != null)
                      _DetailRow(
                        icon: Icons.check_circle,
                        label: 'Resolved At',
                        value: DateFormat('MMM dd, yyyy • HH:mm')
                            .format(_threat!.resolvedAt!),
                      ),
                    if (_threat!.source != null)
                      _DetailRow(
                        icon: Icons.source,
                        label: 'Source',
                        value: _threat!.source!,
                      ),
                    if (_threat!.category != null)
                      _DetailRow(
                        icon: Icons.category,
                        label: 'Category',
                        value: _threat!.category!,
                      ),
                    _DetailRow(
                      icon: Icons.info_outline,
                      label: 'Status',
                      value: _threat!.status.name.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Actions
            if (_threat!.status == ThreatStatus.active)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle resolve action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Threat resolution initiated'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark as Resolved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

