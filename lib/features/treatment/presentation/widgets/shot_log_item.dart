import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/api/models/shot_log_model.dart';
import '../../../../core/api/services/treatment_service.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../../domain/models/side_effect.dart';
import '../../../logging/presentation/screens/shot_logging_screen_updated.dart';

class ShotLogItem extends StatelessWidget {
  final ShotLog shot;
  final List<SideEffect> sideEffects;
  final VoidCallback? onDeleted;
  final VoidCallback? onUpdated;

  const ShotLogItem({
    super.key,
    required this.shot,
    required this.sideEffects,
    this.onDeleted,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    final isToday = _isToday(shot.date);
    final isYesterday = _isYesterday(shot.date);

    return Dismissible(
      key: Key(shot.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDelete(context),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
        decoration: BoxDecoration(
          color: AppColors.error,
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
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Row(
          children: [
            // Syringe icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
              ),
              child: const Icon(
                Icons.medical_services,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            
            const SizedBox(width: AppConstants.spacing12),
            
            // Shot details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medication and dosage
                  Text(
                    '${shot.dosage} of ${shot.medication}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.spacing4),
                  
                  // Injection site and pain level
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${shot.injectionSite} - ${shot.painLevel}/10 pain',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Side effects indicator
                  if (sideEffects.isNotEmpty || (shot.sideEffects.isNotEmpty && shot.sideEffects.first != 'None')) ...[
                    const SizedBox(height: AppConstants.spacing8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing8,
                        vertical: AppConstants.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppConstants.spacing4),
                          Text(
                            '${sideEffects.length + shot.sideEffects.where((e) => e != 'None').length} side effects',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getTimeDisplay(shot.date, isToday, isYesterday),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!isToday && !isYesterday)
                  Text(
                    timeFormatter.format(shot.date),
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
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shot Log'),
        content: const Text('Are you sure you want to delete this shot log? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final treatmentProvider = context.read<TreatmentProvider>();
              final success = await treatmentProvider.deleteShot(shot.id);
              
              if (context.mounted) {
                Navigator.pop(context, success);
                if (success) {
                  onDeleted?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Shot log deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: ${treatmentProvider.errorMessage ?? "Unknown error"}'),
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
            child: const Text('Delete'),
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
              title: const Text('Edit Shot'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShotLoggingScreenUpdated(
                      existingShot: shot,
                    ),
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
              title: const Text('Delete Shot'),
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
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeDisplay(DateTime date, bool isToday, bool isYesterday) {
    final timeFormatter = DateFormat('h:mm a');
    
    if (isToday) {
      return 'Today, ${timeFormatter.format(date)}';
    } else if (isYesterday) {
      return 'Yesterday, ${timeFormatter.format(date)}';
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
