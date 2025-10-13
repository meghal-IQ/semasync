import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class WaterIntakeCard extends StatefulWidget {
  const WaterIntakeCard({super.key});

  @override
  State<WaterIntakeCard> createState() => _WaterIntakeCardState();
}

class _WaterIntakeCardState extends State<WaterIntakeCard> {
  int _currentIntake = 1800; // ml
  final int _targetIntake = 2500; // ml

  void _addWater(int amount) {
    setState(() {
      _currentIntake += amount;
      if (_currentIntake > _targetIntake) {
        _currentIntake = _targetIntake;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentIntake / _targetIntake;
    final remaining = _targetIntake - _currentIntake;

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
                  'Water Intake',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Goal: 2.5L',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
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
                      '${(_currentIntake / 1000).toStringAsFixed(1)}L',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'water',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                progressColor: AppColors.waterBlue,
                backgroundColor: AppColors.waterBlue.withOpacity(0.1),
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWaterButton(
                  amount: 250,
                  label: 'Glass',
                  icon: Icons.local_drink,
                ),
                _buildWaterButton(
                  amount: 500,
                  label: 'Bottle',
                  icon: Icons.water_drop,
                ),
                _buildWaterButton(
                  amount: 1000,
                  label: 'Liter',
                  icon: Icons.local_fire_department,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                color: remaining > 0 
                    ? AppColors.waterBlue.withOpacity(0.1)
                    : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    remaining > 0 ? Icons.info_outline : Icons.check_circle,
                    color: remaining > 0 ? AppColors.waterBlue : AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Expanded(
                    child: Text(
                      remaining > 0 
                          ? '${remaining}ml more to reach your daily goal!'
                          : 'Great job! You\'ve reached your daily water goal!',
                      style: TextStyle(
                        color: remaining > 0 ? AppColors.waterBlue : AppColors.success,
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

  Widget _buildWaterButton({
    required int amount,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => _addWater(amount),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
          color: AppColors.waterBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.waterBlue, size: 24),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              '${amount}ml',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




