import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class TodayTasksCard extends StatelessWidget {
  const TodayTasksCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Tasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '3/5 completed',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            _buildTaskItem(
              title: 'Take morning medication',
              time: '8:00 AM',
              isCompleted: true,
              priority: 'High',
            ),
            _buildTaskItem(
              title: 'Log breakfast meal',
              time: '8:30 AM',
              isCompleted: true,
              priority: 'Medium',
            ),
            _buildTaskItem(
              title: 'Drink 2L of water',
              time: 'All day',
              isCompleted: false,
              priority: 'High',
            ),
            _buildTaskItem(
              title: 'Complete 10k steps',
              time: 'All day',
              isCompleted: false,
              priority: 'Medium',
            ),
            _buildTaskItem(
              title: 'Log evening meal',
              time: '7:00 PM',
              isCompleted: true,
              priority: 'Medium',
            ),
            const SizedBox(height: AppConstants.spacing20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                color: AppColors.activityRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: AppColors.activityRed,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  const Expanded(
                    child: Text(
                      'You have 2 tasks remaining. Keep going!',
                      style: TextStyle(
                        color: AppColors.activityRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem({
    required String title,
    required String time,
    required bool isCompleted,
    required String priority,
  }) {
    final priorityColor = priority == 'High' 
        ? AppColors.error 
        : priority == 'Medium' 
            ? AppColors.warning 
            : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppColors.success.withOpacity(0.1)
            : AppColors.textSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(
          color: isCompleted 
              ? AppColors.success.withOpacity(0.3)
              : priorityColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? AppColors.success : priorityColor,
            size: 20,
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.textSecondary,
                      size: 12,
                    ),
                    const SizedBox(width: AppConstants.spacing4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




