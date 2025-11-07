import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/api/models/activity_log_model.dart';
import '../../../../core/providers/activity_provider.dart';
import '../../../logging/presentation/screens/activity_logging_screen.dart';

class StepLogItem extends StatelessWidget {
  final StepLog stepLog;
  final VoidCallback? onDeleted;
  final VoidCallback? onUpdated;

  const StepLogItem({
    super.key,
    required this.stepLog,
    this.onDeleted,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(stepLog.date);
    final isYesterday = _isYesterday(stepLog.date);

    return Dismissible(
      key: Key(stepLog.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDelete(context),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.spacing16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: InkWell(
        onTap: () => _showOptionsDialog(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
          padding: const EdgeInsets.all(AppConstants.spacing16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
        children: [
          // Steps Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatSteps(stepLog.steps),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'steps',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppConstants.spacing16),
          
          // Step Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity Entry',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Row(
                  children: [
                    if (stepLog.distance != null) ...[
                      Icon(
                        Icons.straighten,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppConstants.spacing4),
                      Text(
                        '${stepLog.distance!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing8),
                    ],
                    if (stepLog.caloriesBurned != null) ...[
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppConstants.spacing4),
                      Text(
                        '${stepLog.caloriesBurned!.toStringAsFixed(0)} cal',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (stepLog.notes != null && stepLog.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    stepLog.notes!,
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
          
          // Timestamp
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getTimeDisplay(stepLog.date, isToday, isYesterday),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (!isToday && !isYesterday)
                Text(
                  DateFormat('h:mm a').format(stepLog.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          ],
        ),
      ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Activity Entry'),
        content: Text('Are you sure you want to delete this activity entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final activityProvider = context.read<ActivityProvider>();
              final success = await activityProvider.deleteStepLog(stepLog.id);
              
              if (context.mounted) {
                Navigator.pop(context, success);
                if (success) {
                  onDeleted?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Activity entry deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: ${activityProvider.errorMessage ?? "Unknown error"}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: Text('Edit Activity'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityLoggingScreen(),
                  ),
                ).then((updated) {
                  if (updated == true) {
                    onUpdated?.call();
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: Text('Delete Activity'),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _confirmDelete(context);
                if (confirmed == true) {
                  // Already handled in _confirmDelete
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }

  String _getTimeDisplay(DateTime date, bool isToday, bool isYesterday) {
    final timeFormatter = DateFormat('h:mm a');
    
    if (isToday) {
      return 'Today\n${timeFormatter.format(date)}';
    } else if (isYesterday) {
      return 'Yesterday\n${timeFormatter.format(date)}';
    } else {
      final dateFormatter = DateFormat('MMM dd');
      return dateFormatter.format(date);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
}

