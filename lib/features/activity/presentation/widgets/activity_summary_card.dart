import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class ActivitySummaryCard extends StatelessWidget {
  const ActivitySummaryCard({super.key});

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
                  'Today\'s Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Sep 17, 2024',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.directions_run,
                    label: 'Steps',
                    value: '8,247',
                    target: '10,000',
                    color: AppColors.activityRed,
                    progress: 0.82,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.local_fire_department,
                    label: 'Calories',
                    value: '420',
                    target: '500',
                    color: AppColors.proteinOrange,
                    progress: 0.84,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.access_time,
                    label: 'Active Time',
                    value: '45m',
                    target: '60m',
                    color: AppColors.primary,
                    progress: 0.75,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: '6.2',
                    target: '8.0',
                    color: AppColors.fiberGreen,
                    progress: 0.78,
                    unit: 'km',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  const Expanded(
                    child: Text(
                      'Great job! You\'re on track to meet your daily goals.',
                      style: TextStyle(
                        color: AppColors.success,
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

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required String target,
    required Color color,
    required double progress,
    String? unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: AppConstants.spacing4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: AppConstants.spacing4),
              Text(
                unit,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppConstants.spacing4),
        Text(
          'of $target',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}




