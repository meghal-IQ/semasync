import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/api/models/activity_log_model.dart';
import '../../../../core/providers/activity_provider.dart';
import '../../../logging/presentation/screens/activity_logging_screen.dart';

class WorkoutLogItem extends StatelessWidget {
  final WorkoutLog workoutLog;
  final VoidCallback? onDeleted;
  final VoidCallback? onUpdated;

  const WorkoutLogItem({
    super.key,
    required this.workoutLog,
    this.onDeleted,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(workoutLog.date);
    final isYesterday = _isYesterday(workoutLog.date);

    return Dismissible(
      key: Key(workoutLog.id),
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
          // Workout Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.background,
            ),
            child: Icon(
              _getWorkoutIcon(workoutLog.type),
              color: AppColors.primary,
              size: 24,
            ),
          ),
          
          const SizedBox(width: AppConstants.spacing12),
          
          // Workout Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workoutLog.type,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.background,
                      ),
                      child: Text(
                        '${workoutLog.duration} min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.background,
                      ),
                      child: Text(
                        'Intensity: ${workoutLog.intensity}/10',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing4),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppConstants.spacing4),
                    Text(
                      '${workoutLog.caloriesBurned.toStringAsFixed(0)} cal',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (workoutLog.notes != null && workoutLog.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    workoutLog.notes!,
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
                _getTimeDisplay(workoutLog.date, isToday, isYesterday),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (!isToday && !isYesterday)
                Text(
                  DateFormat('h:mm a').format(workoutLog.date),
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
        title: Text('Delete Workout Entry'),
        content: Text('Are you sure you want to delete this workout entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final activityProvider = context.read<ActivityProvider>();
              final success = await activityProvider.deleteWorkoutLog(workoutLog.id);
              
              if (context.mounted) {
                Navigator.pop(context, success);
                if (success) {
                  onDeleted?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Workout entry deleted successfully'),
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
              title: Text('Edit Workout'),
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
              title: Text('Delete Workout'),
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

  IconData _getWorkoutIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return Icons.favorite;
      case 'strength training':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'swimming':
        return Icons.pool;
      case 'cycling':
        return Icons.directions_bike;
      case 'running':
        return Icons.directions_run;
      case 'walking':
        return Icons.directions_walk;
      case 'hiit':
        return Icons.bolt;
      case 'pilates':
        return Icons.accessibility_new;
      case 'sports':
        return Icons.sports_basketball;
      default:
        return Icons.fitness_center;
    }
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

