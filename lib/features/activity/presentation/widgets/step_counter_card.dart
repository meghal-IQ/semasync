import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class StepCounterCard extends StatelessWidget {
  const StepCounterCard({super.key});

  @override
  Widget build(BuildContext context) {
    const currentSteps = 8247;
    const targetSteps = 10000;
    final progress = currentSteps / targetSteps;

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
                  'Step Counter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Live',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 12.0,
                percent: progress,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentSteps.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'steps',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                progressColor: AppColors.activityRed,
                backgroundColor: AppColors.activityRed.withOpacity(0.1),
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStepInfo(
                  icon: Icons.directions_walk,
                  label: 'Walking',
                  value: '6,200',
                  color: AppColors.activityRed,
                ),
                _buildStepInfo(
                  icon: Icons.directions_run,
                  label: 'Running',
                  value: '1,800',
                  color: AppColors.proteinOrange,
                ),
                _buildStepInfo(
                  icon: Icons.stairs,
                  label: 'Climbing',
                  value: '247',
                  color: AppColors.fiberGreen,
                ),
              ],
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
                    Icons.trending_up,
                    color: AppColors.activityRed,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Expanded(
                    child: Text(
                      '${targetSteps - currentSteps} more steps to reach your daily goal!',
                      style: const TextStyle(
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

  Widget _buildStepInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppConstants.spacing4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}




