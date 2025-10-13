import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({super.key});

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
                  'Today\'s Nutrition',
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
                  child: _buildNutritionMetric(
                    icon: Icons.local_fire_department,
                    label: 'Calories',
                    value: '1,234',
                    target: '1,800',
                    color: AppColors.proteinOrange,
                    progress: 0.69,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: _buildNutritionMetric(
                    icon: Icons.fitness_center,
                    label: 'Protein',
                    value: '89g',
                    target: '120g',
                    color: AppColors.proteinOrange,
                    progress: 0.74,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionMetric(
                    icon: Icons.grass,
                    label: 'Fiber',
                    value: '18g',
                    target: '25g',
                    color: AppColors.fiberGreen,
                    progress: 0.72,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: _buildNutritionMetric(
                    icon: Icons.water_drop,
                    label: 'Water',
                    value: '1.8L',
                    target: '2.5L',
                    color: AppColors.waterBlue,
                    progress: 0.72,
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
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  const Expanded(
                    child: Text(
                      'Focus on increasing protein intake to support your GLP-1 journey.',
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

  Widget _buildNutritionMetric({
    required IconData icon,
    required String label,
    required String value,
    required String target,
    required Color color,
    required double progress,
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




