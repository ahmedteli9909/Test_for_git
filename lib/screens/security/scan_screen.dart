import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:d_hawk/providers/security_provider.dart';
import 'package:d_hawk/core/theme/app_theme.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Scan'),
      ),
      body: Consumer<SecurityProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Scan Icon
                Icon(
                  Icons.security,
                  size: 100,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 24),
                const Text(
                  'System Security Scan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Scan your system for potential security threats and vulnerabilities',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Scan Button
                ElevatedButton.icon(
                  onPressed: provider.isScanning
                      ? null
                      : () async {
                          final success = await provider.scanSystem();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Scan completed successfully'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.error ?? 'Scan failed',
                                ),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        },
                  icon: provider.isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(provider.isScanning ? 'Scanning...' : 'Start Scan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 32),
                // Scan Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What will be scanned?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ScanItem(
                          icon: Icons.folder,
                          title: 'File System',
                          description: 'Scan for malicious files',
                        ),
                        const SizedBox(height: 12),
                        _ScanItem(
                          icon: Icons.network_check,
                          title: 'Network',
                          description: 'Check network connections',
                        ),
                        const SizedBox(height: 12),
                        _ScanItem(
                          icon: Icons.apps,
                          title: 'Applications',
                          description: 'Scan installed applications',
                        ),
                        const SizedBox(height: 12),
                        _ScanItem(
                          icon: Icons.settings,
                          title: 'System Settings',
                          description: 'Check security configurations',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScanItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ScanItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}



