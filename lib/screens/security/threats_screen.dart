import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:d_hawk/providers/security_provider.dart';
import 'package:d_hawk/models/threat_model.dart';
import 'package:d_hawk/core/theme/app_theme.dart';
import 'package:d_hawk/widgets/loading_widget.dart';
import 'package:d_hawk/widgets/empty_state_widget.dart';
import 'package:d_hawk/widgets/error_widget.dart';
import 'package:intl/intl.dart';

class ThreatsScreen extends StatefulWidget {
  const ThreatsScreen({super.key});

  @override
  State<ThreatsScreen> createState() => _ThreatsScreenState();
}

class _ThreatsScreenState extends State<ThreatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ThreatLevel? _selectedLevel;
  ThreatStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SecurityProvider>(context, listen: false).loadThreats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ThreatModel> _filterThreats(List<ThreatModel> threats) {
    return threats.where((threat) {
      final matchesSearch = _searchQuery.isEmpty ||
          threat.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          threat.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLevel = _selectedLevel == null || threat.level == _selectedLevel;
      final matchesStatus = _selectedStatus == null || threat.status == _selectedStatus;
      return matchesSearch && matchesLevel && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Threats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<SecurityProvider>(context, listen: false).loadThreats();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search threats...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Filter Chips
          if (_selectedLevel != null || _selectedStatus != null)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedLevel != null)
                    Chip(
                      label: Text('Level: ${_selectedLevel!.name}'),
                      onDeleted: () {
                        setState(() {
                          _selectedLevel = null;
                        });
                      },
                    ),
                  if (_selectedStatus != null)
                    Chip(
                      label: Text('Status: ${_selectedStatus!.name}'),
                      onDeleted: () {
                        setState(() {
                          _selectedStatus = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          // Threats List
          Expanded(
            child: Consumer<SecurityProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.threats.isEmpty) {
                  return const LoadingWidget(message: 'Loading threats...');
                }

                if (provider.error != null && provider.threats.isEmpty) {
                  return ErrorDisplayWidget(
                    message: provider.error!,
                    onRetry: () => provider.loadThreats(),
                  );
                }

                final filteredThreats = _filterThreats(provider.threats);

                if (filteredThreats.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.shield_outlined,
                    title: _searchQuery.isNotEmpty || _selectedLevel != null || _selectedStatus != null
                        ? 'No threats found'
                        : 'No threats detected',
                    message: _searchQuery.isNotEmpty || _selectedLevel != null || _selectedStatus != null
                        ? 'Try adjusting your search or filters'
                        : 'Your system is secure',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadThreats(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredThreats.length,
                    itemBuilder: (context, index) {
                      final threat = filteredThreats[index];
                      return _ThreatCard(threat: threat);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Threats'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Threat Level:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ThreatLevel.values.map((level) {
                    return ChoiceChip(
                      label: Text(level.name.toUpperCase()),
                      selected: _selectedLevel == level,
                      onSelected: (selected) {
                        setState(() {
                          _selectedLevel = selected ? level : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ThreatStatus.values.map((status) {
                    return ChoiceChip(
                      label: Text(status.name.toUpperCase()),
                      selected: _selectedStatus == status,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? status : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedLevel = null;
                _selectedStatus = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _ThreatCard extends StatelessWidget {
  final ThreatModel threat;

  const _ThreatCard({required this.threat});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/threat-detail/${threat.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: threat.levelColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      threat.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _ThreatLevelBadge(level: threat.level),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                threat.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(threat.detectedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  _ThreatStatusBadge(status: threat.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreatLevelBadge extends StatelessWidget {
  final ThreatLevel level;

  const _ThreatLevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = level == ThreatLevel.low
        ? AppTheme.successColor
        : level == ThreatLevel.medium
            ? AppTheme.warningColor
            : level == ThreatLevel.high
                ? AppTheme.errorColor
                : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ThreatStatusBadge extends StatelessWidget {
  final ThreatStatus status;

  const _ThreatStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case ThreatStatus.active:
        color = AppTheme.errorColor;
        text = 'Active';
        break;
      case ThreatStatus.resolved:
        color = AppTheme.successColor;
        text = 'Resolved';
        break;
      case ThreatStatus.investigating:
        color = AppTheme.warningColor;
        text = 'Investigating';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
