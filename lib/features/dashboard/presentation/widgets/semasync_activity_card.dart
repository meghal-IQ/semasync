import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SemaSyncActivityCard extends StatelessWidget {
  const SemaSyncActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: AppColors.activityRed,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing8),
              const Text(
                'Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing16),
          
          // Steps
          _buildActivityItem(
            'Steps',
            '0/3000',
            Icons.directions_walk,
          ),
          
          const SizedBox(height: AppConstants.spacing12),
          
          // Workout
          _buildActivityItem(
            'Workout',
            '0/30min',
            Icons.fitness_center,
          ),
          
          const SizedBox(height: AppConstants.spacing12),
          
          // Step indicators
          _buildStepIndicators(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 16,
        ),
        const SizedBox(width: AppConstants.spacing8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      children: List.generate(5, (index) {
        return Container(
          margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.divider,
          ),
        );
      }),
    );
  }
}
