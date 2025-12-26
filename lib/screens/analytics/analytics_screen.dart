import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:d_hawk/providers/security_provider.dart';
import 'package:d_hawk/models/threat_model.dart';
import 'package:d_hawk/core/theme/app_theme.dart';
import 'package:d_hawk/widgets/loading_widget.dart';
import 'package:d_hawk/widgets/error_widget.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = '7d'; // 7d, 30d, 90d, 1y

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load analytics data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Analytics'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7d', child: Text('Last 7 days')),
              const PopupMenuItem(value: '30d', child: Text('Last 30 days')),
              const PopupMenuItem(value: '90d', child: Text('Last 90 days')),
              const PopupMenuItem(value: '1y', child: Text('Last year')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getPeriodLabel(_selectedPeriod)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<SecurityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Loading analytics...');
          }

          if (provider.error != null) {
            return ErrorDisplayWidget(
              message: provider.error!,
              onRetry: () {
                // Retry loading analytics
              },
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Threats',
                        value: '${provider.threats.length}',
                        icon: Icons.warning,
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Active',
                        value: '${provider.threats.where((t) => t.status == ThreatStatus.active).length}',
                        icon: Icons.error,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Resolved',
                        value: '${provider.threats.where((t) => t.status == ThreatStatus.resolved).length}',
                        icon: Icons.check_circle,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Security Score',
                        value: provider.securityStatus != null
                            ? '${provider.securityStatus!.securityScore.toInt()}%'
                            : 'N/A',
                        icon: Icons.security,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Threats by Level
                const Text(
                  'Threats by Level',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _ThreatLevelBar(
                          level: 'Critical',
                          count: provider.threats.where((t) => t.level == ThreatLevel.critical).length,
                          total: provider.threats.length,
                          color: const Color(0xFFDC2626),
                        ),
                        const SizedBox(height: 12),
                        _ThreatLevelBar(
                          level: 'High',
                          count: provider.threats.where((t) => t.level == ThreatLevel.high).length,
                          total: provider.threats.length,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 12),
                        _ThreatLevelBar(
                          level: 'Medium',
                          count: provider.threats.where((t) => t.level == ThreatLevel.medium).length,
                          total: provider.threats.length,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(height: 12),
                        _ThreatLevelBar(
                          level: 'Low',
                          count: provider.threats.where((t) => t.level == ThreatLevel.low).length,
                          total: provider.threats.length,
                          color: AppTheme.successColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Recent Activity
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: provider.threats.take(5).map((threat) {
                      return ListTile(
                        leading: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: threat.levelColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(threat.title),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy • HH:mm').format(threat.detectedAt),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: AppTheme.textSecondary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case '7d':
        return 'Last 7 days';
      case '30d':
        return 'Last 30 days';
      case '90d':
        return 'Last 90 days';
      case '1y':
        return 'Last year';
      default:
        return 'Last 7 days';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreatLevelBar extends StatelessWidget {
  final String level;
  final int count;
  final int total;
  final Color color;

  const _ThreatLevelBar({
    required this.level,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              level,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '$count',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

