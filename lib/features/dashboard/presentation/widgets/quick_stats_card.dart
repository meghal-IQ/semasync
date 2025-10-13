import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class QuickStatsCard extends StatelessWidget {
  const QuickStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'Weight Loss',
                    value: '12 lbs',
                    change: '+2 lbs this week',
                    color: AppColors.success,
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: _buildStatItem(
                    label: 'Streak',
                    value: '7 days',
                    change: 'Personal best!',
                    color: AppColors.activityRed,
                    isPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'Avg Steps',
                    value: '8,200',
                    change: '+500 vs last week',
                    color: AppColors.fiberGreen,
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: _buildStatItem(
                    label: 'Protein Goal',
                    value: '89/120g',
                    change: '74% complete',
                    color: AppColors.proteinOrange,
                    isPositive: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  const Expanded(
                    child: Text(
                      'Tip: Try adding a protein shake to reach your daily protein goal!',
                      style: TextStyle(
                        color: AppColors.warning,
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

  Widget _buildStatItem({
    required String label,
    required String value,
    required String change,
    required Color color,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppColors.success : AppColors.warning,
                size: 12,
              ),
              const SizedBox(width: AppConstants.spacing4),
              Expanded(
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? AppColors.success : AppColors.warning,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




