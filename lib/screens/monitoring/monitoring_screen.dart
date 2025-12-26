import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:d_hawk/providers/security_provider.dart';
import 'package:d_hawk/core/theme/app_theme.dart';
import 'package:d_hawk/widgets/loading_widget.dart';
import 'package:d_hawk/widgets/empty_state_widget.dart';
import 'package:d_hawk/widgets/error_widget.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SecurityProvider>(context, listen: false).loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<SecurityProvider>(context, listen: false).loadAlerts();
            },
          ),
        ],
      ),
      body: Consumer<SecurityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.alerts.isEmpty) {
            return const LoadingWidget(message: 'Loading monitoring data...');
          }

          if (provider.error != null && provider.alerts.isEmpty) {
            return ErrorDisplayWidget(
              message: provider.error!,
              onRetry: () => provider.loadAlerts(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAlerts(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Monitoring Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.monitor_heart,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Active Monitoring',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Real-time threat detection',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: true,
                                onChanged: (value) {
                                  // Handle monitoring toggle
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Active Alerts',
                          value: '${provider.alerts.length}',
                          icon: Icons.notifications_active,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Threats',
                          value: '${provider.threats.length}',
                          icon: Icons.warning,
                          color: AppTheme.warningColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Recent Alerts
                  const Text(
                    'Recent Alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.alerts.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.check_circle_outline,
                      title: 'No Active Alerts',
                      message: 'Your system is currently secure with no active alerts.',
                    )
                  else
                    ...provider.alerts.take(10).map((alert) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: alert.levelColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(alert.title),
                          subtitle: Text(alert.description),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
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

