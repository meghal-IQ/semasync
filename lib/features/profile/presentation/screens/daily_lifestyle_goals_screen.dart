import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class DailyLifestyleGoalsScreen extends StatefulWidget {
  const DailyLifestyleGoalsScreen({super.key});

  @override
  State<DailyLifestyleGoalsScreen> createState() => _DailyLifestyleGoalsScreenState();
}

class _DailyLifestyleGoalsScreenState extends State<DailyLifestyleGoalsScreen> {
  // Mock data
  int _proteinGoal = 120;
  int _proteinServingSize = 5;
  int _fiberGoal = 25;
  int _fiberServingSize = 1;
  int _carbsGoal = 168;
  int _fatGoal = 55;
  int _caloriesGoal = 1646;
  int _waterGoal = 3493;
  int _waterServingSize = 237;
  int _stepsGoal = 3000;
  int _workoutMinGoal = 30;
  bool _autopilot = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Daily Lifestyle Goals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          // _buildSectionHeader('MACRONUTRIENTS'),
          _buildGoalItem(Icons.water_drop, 'Protein', _proteinGoal, 'g', AppColors.primary),
          _buildServingSizeItem('Serving Size', _proteinServingSize, 'g'),
          const SizedBox(height: AppConstants.spacing12),
          _buildGoalItem(Icons.grass, 'Fiber', _fiberGoal, 'g', Colors.green),
          _buildServingSizeItem('Serving Size', _fiberServingSize, 'g'),
          const SizedBox(height: AppConstants.spacing12),
          _buildGoalItem(null, 'Carbs', _carbsGoal, 'g', null),
          const SizedBox(height: AppConstants.spacing12),
          _buildGoalItem(null, 'Fat', _fatGoal, 'g', null),
          const SizedBox(height: AppConstants.spacing12),
          _buildGoalItem(null, 'Calories', _caloriesGoal, 'kcal', null),
          
          const SizedBox(height: AppConstants.spacing24),
          _buildSectionHeader('WATER'),
          _buildGoalItem(Icons.water, 'Daily Water Intake', _waterGoal, 'ml', Colors.blue),
          _buildServingSizeItem('Serving Size', _waterServingSize, 'ml'),
          
          const SizedBox(height: AppConstants.spacing24),
          _buildSectionHeader('ACTIVITY'),
          _buildGoalItem(Icons.directions_walk, 'Daily Steps', _stepsGoal, 'steps', Colors.red),
          const SizedBox(height: AppConstants.spacing12),
          _buildGoalItem(Icons.fitness_center, 'Workout Min', _workoutMinGoal, 'min', Colors.red),
          
          const SizedBox(height: AppConstants.spacing24),
          // _buildSectionHeader('AUTOPILOT'),
          // Container(
          //   padding: const EdgeInsets.all(AppConstants.spacing16),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          //   ),
          //   child: Row(
          //     children: [
          //       Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
          //       const SizedBox(width: AppConstants.spacing16),
          //       const Expanded(
          //         child: Text(
          //           'Autopilot - Lifestyle Goals',
          //           style: TextStyle(
          //             fontSize: 16,
          //             color: AppColors.textPrimary,
          //           ),
          //         ),
          //       ),
          //       Switch(
          //         value: _autopilot,
          //         onChanged: (value) {
          //           setState(() => _autopilot = value);
          //         },
          //         activeColor: AppColors.primary,
          //       ),
          //     ],
          //   ),
          // ),
          
          const SizedBox(height: AppConstants.spacing32),
          
          // Buttons
          // Row(
          //   children: [
          //     Expanded(
          //       child: OutlinedButton(
          //         onPressed: () {
          //           // Re-calculate logic
          //         },
          //         style: OutlinedButton.styleFrom(
          //           padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
          //           side: const BorderSide(color: AppColors.border),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          //           ),
          //         ),
          //         child: const Text(
          //           'Re-Calculate',
          //           style: TextStyle(color: AppColors.textPrimary),
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: AppConstants.spacing12),
          //     Expanded(
          //       child: ElevatedButton(
          //         onPressed: () {
          //           Navigator.pop(context);
          //         },
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.black,
          //           foregroundColor: Colors.white,
          //           padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          //           ),
          //         ),
          //         child: const Text('Save'),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGoalItem(IconData? icon, String label, int value, String unit, Color? iconColor) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 24),
            const SizedBox(width: AppConstants.spacing16),
          ],
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing8,
              vertical: AppConstants.spacing4,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Row(
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing4),
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
        ],
      ),
    );
  }

  Widget _buildServingSizeItem(String label, int value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing8,
        vertical: AppConstants.spacing8,
      ),
      child: Row(
        children: [
          const SizedBox(width: 40), // Indent to align with parent item
          Icon(Icons.add_circle_outline, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: AppConstants.spacing8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing12,
              vertical: AppConstants.spacing6,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Row(
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing4),
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
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Goal Calculations'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('TDEE Calculation', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('We use the Mifflin-St Jeor formula to calculate your Basal Metabolic Rate (BMR):'),
              SizedBox(height: 8),
              Text('For men:\nBMR = (10 × weight) + (6.25 × height) - (5 × age) + 5'),
              SizedBox(height: 8),
              Text('For women:\nBMR = (10 × weight) + (6.25 × height) - (5 × age) - 161'),
              SizedBox(height: 16),
              Text('Macronutrient Goals', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Protein: 0.8-1.2g per pound of body weight'),
              Text('• Fiber: 14g per 1,000 calories consumed'),
              Text('• Carbs: 45-65% of total daily calories'),
              Text('• Fat: 20-35% of total daily calories'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}


