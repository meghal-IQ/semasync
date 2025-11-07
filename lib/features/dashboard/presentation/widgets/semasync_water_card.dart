import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';

class SemaSyncWaterCard extends StatelessWidget {
  const SemaSyncWaterCard({super.key});

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
                Icons.water_drop,
                color: AppColors.waterBlue,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing8),
              Text(
                'Water',
                style: AppTextStyles.title(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing16),
          
          // Water Glass
          Center(
            child: Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.waterBlue.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Center(
                child: Text(
                  '0ml',
                  style: AppTextStyles.title(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppConstants.spacing16),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(Icons.remove, () {
                // TODO: Decrease water intake
              }),
              const SizedBox(width: AppConstants.spacing8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing12,
                  vertical: AppConstants.spacing8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.waterBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '237ml',
                  style: AppTextStyles.title(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.waterBlue,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing8),
              _buildControlButton(Icons.add, () {
                // TODO: Increase water intake
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.textSecondary,
          size: 16,
        ),
      ),
    );
  }
}
