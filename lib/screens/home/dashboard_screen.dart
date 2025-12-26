import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:d_hawk/providers/auth_provider.dart';
import 'package:d_hawk/providers/security_provider.dart';
import 'package:d_hawk/core/theme/app_theme.dart';
import 'package:d_hawk/screens/security/threats_screen.dart';
import 'package:d_hawk/screens/monitoring/monitoring_screen.dart';
import 'package:d_hawk/screens/reports/reports_screen.dart';
import 'package:d_hawk/screens/settings/settings_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SecurityProvider>(context, listen: false).loadSecurityStatus();
      Provider.of<SecurityProvider>(context, listen: false).loadThreats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [_DashboardHome(), ThreatsScreen(), MonitoringScreen(), ReportsScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.security_outlined), selectedIcon: Icon(Icons.security), label: 'Threats'),
          NavigationDestination(icon: Icon(Icons.monitor_outlined), selectedIcon: Icon(Icons.monitor), label: 'Monitoring'),
          NavigationDestination(icon: Icon(Icons.assessment_outlined), selectedIcon: Icon(Icons.assessment), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('D-HAWK Security'),
        actions: [IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.push('/profile'))],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await securityProvider.loadSecurityStatus();
          await securityProvider.loadThreats();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              if (authProvider.user != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome back,', style: Theme.of(context).textTheme.bodyMedium),
                              Text(authProvider.user!.name, style: Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Security Status Card
              Consumer<SecurityProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.securityStatus == null) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final status = provider.securityStatus;
                  if (status == null) {
                    return const Card(
                      child: Padding(padding: EdgeInsets.all(24), child: Text('No security status available')),
                    );
                  }

                  final statusColor = status.overallStatus == 'safe'
                      ? AppTheme.successColor
                      : status.overallStatus == 'warning'
                      ? AppTheme.warningColor
                      : AppTheme.errorColor;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Security Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  status.overallStatus.toUpperCase(),
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Security Score
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Security Score', style: Theme.of(context).textTheme.bodyMedium),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${status.securityScore.toInt()}%',
                                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: status.securityScore / 100,
                                  strokeWidth: 8,
                                  backgroundColor: AppTheme.textSecondary.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),
                          // Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                label: 'Total Threats',
                                value: '${status.totalThreats}',
                                icon: Icons.warning_amber_rounded,
                                color: AppTheme.warningColor,
                              ),
                              _StatItem(label: 'Active', value: '${status.activeThreats}', icon: Icons.error_outline, color: AppTheme.errorColor),
                              _StatItem(
                                label: 'Resolved',
                                value: '${status.resolvedThreats}',
                                icon: Icons.check_circle_outline,
                                color: AppTheme.successColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Quick Actions
              const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(icon: Icons.security, title: 'Scan System', color: AppTheme.primaryColor, onTap: () => context.push('/scan')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.assessment,
                      title: 'View Reports',
                      color: AppTheme.secondaryColor,
                      onTap: () => context.push('/reports'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.analytics,
                      title: 'Analytics',
                      color: AppTheme.primaryColor,
                      onTap: () => context.push('/analytics'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.history,
                      title: 'Scan History',
                      color: AppTheme.secondaryColor,
                      onTap: () => context.push('/scan-history'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.monitor,
                      title: 'Monitoring',
                      color: AppTheme.successColor,
                      onTap: () => context.push('/monitoring'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(icon: Icons.settings, title: 'Settings', color: AppTheme.warningColor, onTap: () => context.push('/settings')),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Recent Threats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Threats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      // Switch to threats tab
                      // This would need to be handled by parent
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Consumer<SecurityProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.threats.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (provider.threats.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline, size: 48, color: AppTheme.successColor),
                              const SizedBox(height: 12),
                              Text('No threats detected', style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: provider.threats.take(3).map((threat) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(color: threat.levelColor, shape: BoxShape.circle),
                          ),
                          title: Text(threat.title),
                          subtitle: Text(DateFormat('MMM dd, yyyy • HH:mm').format(threat.detectedAt)),
                          trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                          onTap: () => context.push('/threat-detail/${threat.id}'),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
