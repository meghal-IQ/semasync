import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/medication_level_provider.dart';

class MedicationLevelCardSimplified extends StatelessWidget {
  const MedicationLevelCardSimplified({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationLevelProvider>(
      builder: (context, medicationProvider, child) {
        final currentLevel = medicationProvider.currentLevelPercentage;
        final levelRounded = currentLevel.round();
        
        // Determine status dynamically based on level
        // Optimal: 70-95%, High: 95-100%, Low: below 70%
        final isOptimal = levelRounded >= 70 && levelRounded <= 95;
        final isHigh = levelRounded > 95;
        final isLow = levelRounded < 70;
        
        // Always show Optimal badge when in optimal range
        final statusText = isOptimal 
            ? 'Optimal' 
            : (isHigh ? 'High' : 'Low');
        
        return Card(
          color: AppColors.lightGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with syringe icon and Optimal badge
                Row(
                  children: [
                    Icon(
                      Icons.vaccines, // Syringe icon
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Text(
                      'Medication Level',
                      style: AppTextStyles.title(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // Optimal badge on the right (light green bg, dark green text)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing8,
                        vertical: AppConstants.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCFEEE4), // Light green background (more visible)
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Color(0xFF037952), // Dark green text
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing12),
                
                // Current Status text
                Text(
                  'Current Status',
                  style: AppTextStyles.title(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                
                // Progress bar with percentage circle on the left
                Row(
                  children: [
                    // Percentage circle on the left
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.success, 
                        borderRadius: BorderRadius.circular(45)
                        // shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacing12,
                            vertical: AppConstants.spacing4,
                          ),
                          child: Text(
                            '$levelRounded%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    // Progress bar
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (currentLevel / 100).clamp(0.0, 1.0),
                          backgroundColor: AppColors.darkGrey,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                          minHeight: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

