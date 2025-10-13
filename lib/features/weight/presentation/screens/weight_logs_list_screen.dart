import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../logging/presentation/screens/weight_logging_screen.dart';

class WeightLogsListScreen extends StatefulWidget {
  const WeightLogsListScreen({super.key});

  @override
  State<WeightLogsListScreen> createState() => _WeightLogsListScreenState();
}

class _WeightLogsListScreenState extends State<WeightLogsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadWeightData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'All Weight Logs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeightLoggingScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<HealthProvider, AuthProvider>(
        builder: (context, healthProvider, authProvider, child) {
          if (healthProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final history = healthProvider.weightHistory;
          final preferredUnit = authProvider.user?.preferredUnits.weight ?? 'kg';

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monitor_weight_outlined,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  const Text(
                    'No weight logs yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  const Text(
                    'Tap + to add your first entry',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final log = history[index];
              final isFirst = index == 0;
              final isLast = index == history.length - 1;
              
              // Calculate change from previous entry (in kg)
              double? changeKg;
              if (!isLast) {
                final previousLog = history[index + 1];
                changeKg = log.weight - previousLog.weight;
              }

              return _buildWeightLogCard(
                log: log,
                changeKg: changeKg,
                isFirst: isFirst,
                preferredUnit: preferredUnit,
                onDelete: () => _deleteLog(context, log.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "weight_logs_fab",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WeightLoggingScreen()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWeightLogCard({
    required dynamic log,
    double? changeKg,
    required bool isFirst,
    required String preferredUnit,
    required VoidCallback onDelete,
  }) {
    // Convert weight from kg to preferred unit
    final weightConverted = UnitConverter.convertWeight(log.weight, preferredUnit);
    
    // Convert change from kg to preferred unit
    final change = changeKg != null ? UnitConverter.convertWeight(changeKg.abs(), preferredUnit) : null;
    final isPositive = changeKg != null && changeKg > 0;
    final isNegative = changeKg != null && changeKg < 0;
    final sign = isPositive ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Weight Display
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weightConverted.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  preferredUnit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppConstants.spacing16),
          
          // Weight Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weight Entry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Row(
                  children: [
                    if (change != null) ...[
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: isPositive ? AppColors.error : Colors.green,
                      ),
                      const SizedBox(width: AppConstants.spacing4),
                      Text(
                        '$sign${change.toStringAsFixed(1)}$preferredUnit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isPositive ? AppColors.error : Colors.green,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '0.00$preferredUnit',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (log.notes != null && log.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    log.notes!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Date and Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDateTime(log.date),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              GestureDetector(
                onTap: () => _showDeleteDialog(context, onDelete),
                child: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.error.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Weight Entry'),
        content: const Text('Are you sure you want to delete this weight entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLog(BuildContext context, String logId) async {
    final success = await context.read<HealthProvider>().deleteWeight(logId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Weight entry deleted' : 'Failed to delete entry'),
          backgroundColor: success ? Colors.green : AppColors.error,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (logDate == today) {
      return 'Today, ${_formatTime(dateTime)}';
    }
    
    return '${dateTime.month}/${dateTime.day}/${dateTime.year.toString().substring(2)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute$period';
  }
}

