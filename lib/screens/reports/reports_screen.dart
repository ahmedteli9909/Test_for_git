import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:d_hawk/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => context.push('/analytics'),
            tooltip: 'View Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report download initiated')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Generate Report Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Generate Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showDateRangePicker(context);
                      },
                      icon: const Icon(Icons.date_range),
                      label: const Text('Select Date Range'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Recent Reports
            const Text(
              'Recent Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _ReportCard(
              title: 'Weekly Security Report',
              date: DateTime.now().subtract(const Duration(days: 2)),
              type: 'Weekly',
            ),
            _ReportCard(
              title: 'Monthly Security Report',
              date: DateTime.now().subtract(const Duration(days: 15)),
              type: 'Monthly',
            ),
            _ReportCard(
              title: 'Threat Analysis Report',
              date: DateTime.now().subtract(const Duration(days: 30)),
              type: 'Analysis',
            ),
          ],
        ),
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
    ).then((dateRange) {
      if (dateRange != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Generating report for ${DateFormat('MMM dd').format(dateRange.start)} - ${DateFormat('MMM dd').format(dateRange.end)}',
            ),
          ),
        );
      }
    });
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final String type;

  const _ReportCard({
    required this.title,
    required this.date,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.description,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(title),
        subtitle: Text(
          '${DateFormat('MMM dd, yyyy').format(date)} • $type',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Viewing $title')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading $title')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

