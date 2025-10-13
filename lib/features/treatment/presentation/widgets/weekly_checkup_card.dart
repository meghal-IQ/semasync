import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/weekly_checkup_provider.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../../../../core/api/models/weekly_checkup_model.dart';
import '../screens/weekly_checkup_screen.dart';

class WeeklyCheckupCard extends StatelessWidget {
  const WeeklyCheckupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<WeeklyCheckupProvider, HealthProvider, TreatmentProvider>(
      builder: (context, checkupProvider, healthProvider, treatmentProvider, child) {
        final latestCheckup = checkupProvider.latestCheckup;
        final isDue = checkupProvider.isDueForWeeklyCheckup();
        final daysSince = checkupProvider.getDaysSinceLastCheckup();

        return Container(
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
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Weekly Checkup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing8,
                        vertical: AppConstants.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: isDue ? AppColors.warning : AppColors.success,
                      ),
                      child: Text(
                        isDue ? 'Due' : 'Up to date',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.spacing16),
                
                if (latestCheckup != null) ...[
                  _buildCheckupSummary(latestCheckup),
                  const SizedBox(height: AppConstants.spacing16),
                  _buildRecommendationCard(latestCheckup),
                ] else ...[
                  _buildNoCheckupState(),
                ],
                
                const SizedBox(height: AppConstants.spacing16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showWeeklyCheckupDialog(context),
                    icon: const Icon(Icons.medical_services),
                    label: Text(isDue ? 'Start Weekly Checkup' : 'View Checkup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
                    ),
                  ),
                ),
                
                if (isDue && daysSince > 0) ...[
                  const SizedBox(height: AppConstants.spacing8),
                  Text(
                    'Overdue by $daysSince day${daysSince == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckupSummary(WeeklyCheckup checkup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppConstants.spacing8),
            Text(
              'Last checkup: ${_formatDate(checkup.date)}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.spacing8),
        
        Row(
          children: [
            Icon(
              Icons.monitor_weight,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppConstants.spacing8),
            Text(
              'Weight: ${checkup.currentWeight.toStringAsFixed(1)} ${checkup.weightUnit}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (checkup.weightChange != null) ...[
              const SizedBox(width: AppConstants.spacing8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing6,
                  vertical: AppConstants.spacing2,
                ),
                decoration: BoxDecoration(
                  color: checkup.weightChange! > 0 ? AppColors.success : AppColors.error,
                ),
                child: Text(
                  '${checkup.weightChange! > 0 ? '+' : ''}${checkup.weightChange!.toStringAsFixed(1)} ${checkup.weightUnit}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: AppConstants.spacing8),
        
        Row(
          children: [
            Icon(
              Icons.warning_amber,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppConstants.spacing8),
            Text(
              'Side effects: ${checkup.sideEffects.length} (${checkup.overallSideEffectSeverity.toStringAsFixed(1)}/10)',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(WeeklyCheckup checkup) {
    final recommendation = DosageRecommendation.values.firstWhere(
      (r) => r.name == checkup.dosageRecommendation,
      orElse: () => DosageRecommendation.continueCurrent,
    );

    Color cardColor;
    IconData iconData;
    
    switch (recommendation) {
      case DosageRecommendation.continueCurrent:
        cardColor = AppColors.success;
        iconData = Icons.check_circle;
        break;
      case DosageRecommendation.increaseDose:
        cardColor = AppColors.primary;
        iconData = Icons.trending_up;
        break;
      case DosageRecommendation.decreaseDose:
        cardColor = AppColors.warning;
        iconData = Icons.trending_down;
        break;
      case DosageRecommendation.pauseTreatment:
        cardColor = AppColors.error;
        iconData = Icons.pause_circle;
        break;
      case DosageRecommendation.consultDoctor:
        cardColor = AppColors.error;
        iconData = Icons.medical_services;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        border: Border.all(color: cardColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: cardColor, size: 20),
              const SizedBox(width: AppConstants.spacing8),
              Expanded(
                child: Text(
                  recommendation.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cardColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing8),
          
          Text(
            recommendation.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: AppConstants.spacing8),
          
          Text(
            checkup.recommendationReason,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCheckupState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
      ),
      child: Column(
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppConstants.spacing12),
          const Text(
            'No weekly checkup yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          const Text(
            'Start your first weekly checkup to get personalized dosage recommendations based on your weight and side effects.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showWeeklyCheckupDialog(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeeklyCheckupScreen()),
    );
    
    // Refresh weekly checkup data when returning from the screen
    final weeklyCheckupProvider = Provider.of<WeeklyCheckupProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    
    // Force refresh both weekly checkup and health data
    await weeklyCheckupProvider.loadLatestWeeklyCheckup();
    await weeklyCheckupProvider.loadWeeklyCheckups();
    await healthProvider.loadWeightData();
  }
}
