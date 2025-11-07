import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/activity_provider.dart';

class DailyLifestyleGoalsScreen extends StatefulWidget {
  const DailyLifestyleGoalsScreen({super.key});

  @override
  State<DailyLifestyleGoalsScreen> createState() => _DailyLifestyleGoalsScreenState();
}

class _DailyLifestyleGoalsScreenState extends State<DailyLifestyleGoalsScreen> {
  // Mock data matching the image
  int _proteinGoal = 120;
  int _proteinServingSize = 2;
  int _fiberGoal = 25;
  int _fiberServingSize = 1;
  int _carbsGoal = 168;
  int _fatGoal = 55;
  int _caloriesGoal = 1646;
  int _waterGoal = 3493;
  int _waterServingSize = 237;
  int _stepsGoal = 3000;
  int _workoutMinGoal = 30;

  @override
  void initState() {
    super.initState();
    // Load activity data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivityData();
    });
  }

  TextStyle _montserrat({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = Colors.black,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daily Lifestyle Goals',
          style: _montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Protein Card
            _buildNutritionCardWithServingSize(
              icon: Image.asset(
                'assets/images/protein.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.water_drop,
                    size: 20,
                    color: Color(0xFFF59E0B), // Yellow/orange for protein
                  );
                },
              ),
              label: 'Protein',
              value: '$_proteinGoal',
              unit: 'g',
              servingSizeLabel: 'Serving Size',
              servingSizeValue: '$_proteinServingSize',
              servingSizeUnit: 'g',
            ),
            const SizedBox(height: AppConstants.spacing12),
            
            // Fiber Card
            _buildNutritionCardWithServingSize(
              icon: Image.asset(
                'assets/images/fiber.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.eco,
                    size: 20,
                    color: Color(0xFF10B981), // Green for fiber
                  );
                },
              ),
              label: 'Fiber',
              value: '$_fiberGoal',
              unit: 'g',
              servingSizeLabel: 'Serving Size',
              servingSizeValue: '$_fiberServingSize',
              servingSizeUnit: 'g',
            ),
            const SizedBox(height: AppConstants.spacing12),
            
            // Carbs Row
            _buildSimpleRow('Carbs', '$_carbsGoal g'),
            const SizedBox(height: AppConstants.spacing12),
            
            // Fat Row
            _buildSimpleRow('Fat', '$_fatGoal g'),
            const SizedBox(height: AppConstants.spacing12),
            
            // Calories Row
            _buildSimpleRow('Calories', '$_caloriesGoal kcal'),
            
            const SizedBox(height: AppConstants.spacing24),
            
            // Water Section
            _buildSectionHeader('Water'),
            const SizedBox(height: AppConstants.spacing12),
            _buildNutritionCardWithServingSize(
              icon: const Icon(
                Icons.water_drop,
                size: 20,
                color: Color(0xFF3B82F6), // Blue for water
              ),
              label: 'Daily Water Intake',
              value: '$_waterGoal',
              unit: 'ml',
              servingSizeLabel: 'Serving Size',
              servingSizeValue: '$_waterServingSize',
              servingSizeUnit: 'ml',
            ),
            
            const SizedBox(height: AppConstants.spacing24),
            
            // Activity Section
            _buildSectionHeader('Activity'),
            const SizedBox(height: AppConstants.spacing12),
            _buildActivityRow(
              icon: const Icon(
                Icons.directions_walk,
                size: 20,
                color: Color(0xFFDC2626), // Red for steps
              ),
              label: 'Daily Steps',
              value: '$_stepsGoal steps',
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildWorkoutRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: _montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildNutritionCardWithServingSize({
    required Widget icon,
    required String label,
    required String value,
    required String unit,
    required String servingSizeLabel,
    required String servingSizeValue,
    required String servingSizeUnit,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Left side: Icon and main info
          icon,
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: _montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280), // Medium gray
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value$unit',
                  style: _montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Vertical separator
          Container(
            width: 1,
            height: 50,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing12),
          ),
          
          // Right side: Serving size
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  servingSizeLabel,
                  style: _montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280), // Medium gray
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$servingSizeValue$servingSizeUnit',
                  style: _montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: _montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: _montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow({
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Text(
              label,
              style: _montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            value,
            style: _montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutRow() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        // Calculate today's workout minutes from workout history
        final workoutsHistory = activityProvider.workoutsHistory;
        final today = DateTime.now();
        final todaysWorkouts = workoutsHistory.where((workout) {
          final workoutDate = DateTime(workout.date.year, workout.date.month, workout.date.day);
          final todayOnly = DateTime(today.year, today.month, today.day);
          return workoutDate.year == todayOnly.year &&
                 workoutDate.month == todayOnly.month &&
                 workoutDate.day == todayOnly.day;
        }).toList();
        
        final workoutMinutes = todaysWorkouts.fold<int>(
          0,
          (sum, workout) => sum + workout.duration,
        );
        
        // Calculate progress (0.0 to 1.0)
        final progress = _workoutMinGoal > 0 
            ? (workoutMinutes / _workoutMinGoal).clamp(0.0, 1.0)
            : 0.0;
        
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 20,
                    color: Color(0xFF14B8A6), // Teal for workout
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: Text(
                      'Workout Min',
                      style: _montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    '$workoutMinutes / $_workoutMinGoal min',
                    style: _montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing12),
              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6), // Teal for workout
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


