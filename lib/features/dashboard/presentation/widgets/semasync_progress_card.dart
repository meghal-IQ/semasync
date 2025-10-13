import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SemaSyncProgressCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int current;
  final int goal;
  final String unit;
  final int increment;
  final bool isCircular;

  const SemaSyncProgressCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.current,
    required this.goal,
    required this.unit,
    required this.increment,
    this.isCircular = false,
  });

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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppConstants.spacing8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing16),
          
          // Progress Display
          if (isCircular) ...[
            _buildCircularProgress(),
          ] else ...[
            _buildLinearProgress(),
          ],
          
          const SizedBox(height: AppConstants.spacing16),
          
          // Controls
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildLinearProgress() {
    final double progress = current / goal;
    
    return Column(
      children: [
        Text(
          '$current$unit /$goal$unit',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.divider,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress() {
    final double progress = current / goal;
    
    return Center(
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          children: [
            // Background circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.divider,
                  width: 8,
                ),
              ),
            ),
            
            // Progress circle
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 8,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$current',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Progress indicator dot
            Positioned(
              top: 0,
              left: 40,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(Icons.remove, () {
          // TODO: Decrease value
        }),
        const SizedBox(width: AppConstants.spacing16),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing12,
            vertical: AppConstants.spacing8,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
          ),
          child: Text(
            '${increment}$unit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacing16),
        _buildControlButton(Icons.add, () {
          // TODO: Increase value
        }),
      ],
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
          shape: BoxShape.circle,
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
