import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        
        if (user == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Center(
                child: Text(
                  'No user data available',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          );
        }

        // Calculate days since GLP-1 journey started
        int journeyDays = 0;
        if (user.glp1Journey.startDate != null) {
          journeyDays = DateTime.now().difference(user.glp1Journey.startDate!).inDays;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacing4),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacing4),
                          Text(
                            'GLP-1 Journey • Day $journeyDays',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacing8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacing12,
                              vertical: AppConstants.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            ),
                            child: Text(
                              user.accountStatus == 'active' ? 'On Track' : user.accountStatus,
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Edit profile
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        label: 'Current Weight',
                        value: '${user.weight.toStringAsFixed(1)} ${user.preferredUnits.weight}',
                        color: AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        label: 'Height',
                        value: '${user.height.toStringAsFixed(1)} ${user.preferredUnits.height}',
                        color: AppColors.activityRed,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        label: 'Journey Days',
                        value: '$journeyDays',
                        color: AppColors.proteinOrange,
                      ),
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
                      Expanded(
                        child: Text(
                          user.motivation.isNotEmpty 
                            ? user.motivation 
                            : 'You\'re doing amazing! Keep up the great work on your health journey.',
                          style: const TextStyle(
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
      },
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

