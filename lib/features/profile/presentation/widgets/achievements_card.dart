import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class AchievementsCard extends StatelessWidget {
  const AchievementsCard({super.key});

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
                  'Achievements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '8 unlocked',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: AppConstants.spacing12,
              mainAxisSpacing: AppConstants.spacing12,
              childAspectRatio: 1,
              children: [
                _buildAchievement(
                  icon: Icons.local_fire_department,
                  title: 'First Week',
                  description: 'Complete 7 days',
                  isUnlocked: true,
                  color: AppColors.proteinOrange,
                ),
                _buildAchievement(
                  icon: Icons.directions_run,
                  title: 'Step Master',
                  description: '10k steps/day',
                  isUnlocked: true,
                  color: AppColors.activityRed,
                ),
                _buildAchievement(
                  icon: Icons.water_drop,
                  title: 'Hydration Hero',
                  description: '2L water/day',
                  isUnlocked: true,
                  color: AppColors.waterBlue,
                ),
                _buildAchievement(
                  icon: Icons.restaurant,
                  title: 'Meal Logger',
                  description: 'Log 50 meals',
                  isUnlocked: true,
                  color: AppColors.fiberGreen,
                ),
                _buildAchievement(
                  icon: Icons.emoji_events,
                  title: 'Weight Loss',
                  description: 'Lose 10 lbs',
                  isUnlocked: true,
                  color: AppColors.success,
                ),
                _buildAchievement(
                  icon: Icons.fitness_center,
                  title: 'Workout Warrior',
                  description: '30 workouts',
                  isUnlocked: true,
                  color: AppColors.primary,
                ),
                _buildAchievement(
                  icon: Icons.calendar_month,
                  title: 'Monthly Goal',
                  description: '30 days active',
                  isUnlocked: true,
                  color: AppColors.warning,
                ),
                _buildAchievement(
                  icon: Icons.star,
                  title: 'Consistency',
                  description: '7 day streak',
                  isUnlocked: true,
                  color: AppColors.secondary,
                ),
                _buildAchievement(
                  icon: Icons.lock,
                  title: 'Coming Soon',
                  description: 'Keep going!',
                  isUnlocked: false,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  const Expanded(
                    child: Text(
                      'You\'re on fire! Unlock more achievements by staying consistent.',
                      style: TextStyle(
                        color: AppColors.primary,
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

  Widget _buildAchievement({
    required IconData icon,
    required String title,
    required String description,
    required bool isUnlocked,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing8),
      decoration: BoxDecoration(
        color: isUnlocked 
            ? color.withOpacity(0.1)
            : AppColors.textSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(
          color: isUnlocked 
              ? color.withOpacity(0.3)
              : AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isUnlocked ? color : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? color : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          // const SizedBox(height: AppConstants.spacing2),
          Text(
            description,
            style: TextStyle(
              fontSize: 8,
              color: isUnlocked ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          if (isUnlocked) ...[
            const SizedBox(height: AppConstants.spacing4),
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 12,
            ),
          ],
        ],
      ),
    );
  }
}




