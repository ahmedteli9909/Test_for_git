import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:d_hawk/services/api_service.dart';
import 'package:d_hawk/models/scan_history_model.dart';
import 'package:d_hawk/core/theme/app_theme.dart';
import 'package:d_hawk/widgets/loading_widget.dart';
import 'package:d_hawk/widgets/empty_state_widget.dart';
import 'package:d_hawk/widgets/error_widget.dart';
import 'package:intl/intl.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<ScanHistoryModel> _scans = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadScanHistory();
  }

  Future<void> _loadScanHistory({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getScanHistory(
        page: _page,
        limit: _limit,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['scans'] != null) {
          final newScans = (data['scans'] as List)
              .map((json) => ScanHistoryModel.fromJson(json))
              .toList();

          setState(() {
            if (refresh) {
              _scans = newScans;
            } else {
              _scans.addAll(newScans);
            }
            _hasMore = newScans.length == _limit;
            _page++;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load scan history';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadScanHistory(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _scans.isEmpty) {
      return const LoadingWidget(message: 'Loading scan history...');
    }

    if (_error != null && _scans.isEmpty) {
      return ErrorDisplayWidget(
        message: _error!,
        onRetry: () => _loadScanHistory(refresh: true),
      );
    }

    if (_scans.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history,
        title: 'No Scan History',
        message: 'You haven\'t run any scans yet. Start a scan to see history here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _scans.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _scans.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _ScanHistoryCard(scan: _scans[index]);
      },
    );
  }
}

class _ScanHistoryCard extends StatelessWidget {
  final ScanHistoryModel scan;

  const _ScanHistoryCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (scan.status) {
      case ScanStatus.completed:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case ScanStatus.running:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.refresh;
        statusText = 'Running';
        break;
      case ScanStatus.failed:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.error;
        statusText = 'Failed';
        break;
      case ScanStatus.pending:
        statusColor = AppTheme.textSecondary;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan #${scan.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(scan.startedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoItem(
                  icon: Icons.warning,
                  label: 'Threats Found',
                  value: '${scan.threatsFound}',
                  color: scan.threatsFound > 0
                      ? AppTheme.errorColor
                      : AppTheme.successColor,
                ),
                const SizedBox(width: 24),
                if (scan.duration != null)
                  _InfoItem(
                    icon: Icons.timer,
                    label: 'Duration',
                    value: _formatDuration(scan.duration!),
                    color: AppTheme.textSecondary,
                  ),
              ],
            ),
            if (scan.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: 16, color: AppTheme.errorColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        scan.error!,
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return '${duration.inSeconds}s';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}



