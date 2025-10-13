import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({super.key});

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
                  'Workouts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Today',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            _buildWorkoutItem(
              icon: Icons.fitness_center,
              title: 'Morning Cardio',
              duration: '30 min',
              calories: '180 cal',
              intensity: 'Moderate',
              color: AppColors.activityRed,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildWorkoutItem(
              icon: Icons.directions_walk,
              title: 'Evening Walk',
              duration: '20 min',
              calories: '85 cal',
              intensity: 'Light',
              color: AppColors.fiberGreen,
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Start new workout
                    },
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: const Text('Start Workout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.activityRed,
                      side: const BorderSide(color: AppColors.activityRed),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacing12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Log workout
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Log Workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.activityRed,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacing12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutItem({
    required IconData icon,
    required String title,
    required String duration,
    required String calories,
    required String intensity,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Row(
                  children: [
                    Text(
                      duration,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Text(
                      calories,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing8,
                        vertical: AppConstants.iconSize,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Text(
                        intensity,
                        style: TextStyle(
                          color: color,
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
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }
}




