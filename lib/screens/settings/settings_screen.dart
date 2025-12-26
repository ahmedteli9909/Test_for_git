import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:d_hawk/core/theme/app_theme.dart';
import 'package:d_hawk/providers/auth_provider.dart';
import 'package:d_hawk/core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailAlerts = true;
  bool _pushNotifications = true;
  bool _autoScan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _SettingsSection(
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                subtitle: const Text('Manage your profile information'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                subtitle: const Text('Update your password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showChangePasswordDialog(context);
                },
              ),
            ],
          ),
          // Notifications Section
          _SettingsSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive security alerts'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const Divider(),
              SwitchListTile(
                secondary: const Icon(Icons.email),
                title: const Text('Email Alerts'),
                subtitle: const Text('Receive alerts via email'),
                value: _emailAlerts,
                onChanged: _notificationsEnabled
                    ? (value) {
                        setState(() {
                          _emailAlerts = value;
                        });
                      }
                    : null,
              ),
              const Divider(),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive push notifications'),
                value: _pushNotifications,
                onChanged: _notificationsEnabled
                    ? (value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                      }
                    : null,
              ),
            ],
          ),
          // Security Section
          _SettingsSection(
            title: 'Security',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.security),
                title: const Text('Auto Scan'),
                subtitle: const Text('Automatically scan system periodically'),
                value: _autoScan,
                onChanged: (value) {
                  setState(() {
                    _autoScan = value;
                  });
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Scan History'),
                subtitle: const Text('View past scan results'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/scan-history'),
              ),
            ],
          ),
          // About Section
          _SettingsSection(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help & Support coming soon')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy Policy coming soon')),
                  );
                },
              ),
            ],
          ),
          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await authProvider.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle password change
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password change initiated'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

