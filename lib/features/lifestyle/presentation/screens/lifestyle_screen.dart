import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/nutrition_provider.dart';
import '../../../../core/providers/activity_provider.dart';
import '../../../../core/api/models/nutrition_log_model.dart';
import '../../../dashboard/presentation/widgets/protein_card.dart';
import '../../../dashboard/presentation/widgets/fiber_card.dart';
import '../../../dashboard/presentation/widgets/water_card.dart';
import '../../../dashboard/presentation/widgets/custom_day_picker.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  int _selectedDayIndex = 4; // Default to today
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().loadNutritionData();
      context.read<ActivityProvider>().loadActivityData();
    });
  }
  
  void _onDaySelected(int index) {
    setState(() {
      _selectedDayIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text(
          'Lifestyle Goals',
          style: TextStyle(
                      fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1F36),
            letterSpacing: -0.5,
          ),
        ),
                ],
      ),), Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                CustomDayPicker(
                  selectedIndex: _selectedDayIndex,
                  onDaySelected: _onDaySelected,
                ),

                const SizedBox(height: 24),

              _buildSectionHeader('MACRONUTRIENTS'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildProteinCardForLifestyle()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildFiberCardForLifestyle()),
                ],
              ),
              
              const SizedBox(height: 16),
              
                    // Water and Other Row
              Row(
                children: [
                        Expanded(child: _buildWaterCardForLifestyle()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildOtherCardForLifestyle()),
                ],
              ),
              
              const SizedBox(height: 24),
              
                    // Activity Section
                    _buildSectionHeader('ACTIVITY'),
              const SizedBox(height: 16),
              
                    _buildActivityCardForLifestyle(),
              
              const SizedBox(height: 16),
                    
                    _buildWorkoutCardForLifestyle(),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProteinCardForLifestyle() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final protein = dailySummary?.protein ?? 0;
        
        return ProteinCard(
          protein: protein.toDouble(),
          proteinGoal: 120,
          onIncrement: () => _incrementProtein(),
          onDecrement: () => _decrementProtein(),
        );
      },
    );
  }

  Widget _buildFiberCardForLifestyle() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final fiber = dailySummary?.fiber ?? 0;
        
        return FiberCard(
          fiber: fiber.toDouble(),
          fiberGoal: 20,
          onIncrement: () => _incrementFiber(),
          onDecrement: () => _decrementFiber(),
        );
      },
    );
  }

  Widget _buildWaterCardForLifestyle() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final water = dailySummary?.water ?? 0;
        final waterGoal = dailySummary?.waterGoal ?? 2500;
        
        return WaterCard(
          water: water.toDouble(),
          waterGoal: waterGoal.toDouble(),
          onIncrement: () => _incrementWater(),
          onDecrement: () => _decrementWater(),
        );
      },
    );
  }

  Widget _buildOtherCardForLifestyle() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final calories = dailySummary?.calories ?? 0;
        final carbs = dailySummary?.carbs ?? 0;
        final fat = dailySummary?.fat ?? 0;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Other',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F36),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Calories row with icon and progress
              Row(
                children: [
                  // Container(
                  //   width: 6,
                  //   height: 6,
                  //   decoration: const BoxDecoration(
                  //     color: Color(0xFFF97316),
                  //     shape: BoxShape.circle,
                  //   ),
                  // ),
                  // const SizedBox(width: 8),
                  const Text(
                    'Calories',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${calories.toInt()}/1268kcal',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Calories progress bar
              Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (calories / 1268).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Carbs row with icon and progress
              Row(
                children: [
                  const Text(
                    'Carbs',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${carbs.toInt()}/154g',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Carbs progress bar
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (carbs / 154).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF84CC16),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Fat row with icon and progress
              Row(
                children: [
                  const Text(
                    'Fat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${fat.toInt()}/42g',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Fat progress bar
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (fat / 42).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(2),
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

  Widget _buildActivityCardForLifestyle() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        final activitySummary = activityProvider.activitySummary;
        final steps = activitySummary?.todaySteps ?? 0;
        final stepsGoal = activitySummary?.stepsGoal ?? 10000;
        final progress = (steps / stepsGoal).clamp(0.0, 1.0);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Activity icon using image
                  Image.asset(
                    'assets/images/activity_logo.png',
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Steps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600]!,
                        ),
                      ),
                      Text(
                        '$steps / $stepsGoal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 10 footprint icons using images
              Row(
                children: List.generate(10, (index) {
                  final isActive = index < (progress * 10);
                  return Padding(
                    padding: EdgeInsets.only(right: index == 9 ? 0 : 6),
                    child: Image.asset(
                      isActive ? 'assets/images/step_fill.png' : 'assets/images/step_blank.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutCardForLifestyle() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        final workoutsHistory = activityProvider.workoutsHistory;
        final today = DateTime.now();
        final todaysWorkouts = workoutsHistory.where((workout) {
          return workout.date.year == today.year &&
                 workout.date.month == today.month &&
                 workout.date.day == today.day;
        }).toList();
        
        final workoutMinutes = todaysWorkouts.fold<int>(
          0,
          (sum, workout) => sum + workout.duration,
        );
        
        const workoutGoal = 30;
        final progress = (workoutMinutes / workoutGoal).clamp(0.0, 1.0);
        
        return Container(
          padding: const EdgeInsets.all(16),
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
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Workout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Workout',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600]!,
                        ),
                      ),
                      Text(
                        '${workoutMinutes.toString().padLeft(2, '0')} / ${workoutGoal.toString().padLeft(2, '0')} Min',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF52D7D5),
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

  void _incrementProtein() {
    _logQuickNutrition(protein: 1);
  }

  void _decrementProtein() {
    _logQuickNutrition(protein: -1);
  }

  void _incrementFiber() {
    _logQuickNutrition(fiber: 1);
  }

  void _decrementFiber() {
    _logQuickNutrition(fiber: -1);
  }

  void _incrementWater() {
    _logQuickWater(237);
  }

  void _decrementWater() {
    _logQuickWater(-237);
  }

  void _logQuickNutrition({double? fiber, double? protein}) async {
    try {
      final nutritionProvider = context.read<NutritionProvider>();
      final now = DateTime.now();
      final mealType = _getMealTypeForTime(now);
      final foods = <Food>[];
      
      if (fiber != null) {
        foods.add(Food(
          name: fiber > 0 ? 'Fiber Supplement' : 'Fiber Removal',
          portion: '${fiber.abs()}g',
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          fiber: fiber,
        ));
      }
      
      if (protein != null) {
        foods.add(Food(
          name: protein > 0 ? 'Protein Supplement' : 'Protein Removal',
          portion: '${protein.abs()}g',
          calories: protein * 4,
          protein: protein,
          carbs: 0,
          fat: 0,
        ));
      }
      
      if (foods.isNotEmpty) {
        final request = MealLogRequest(
          date: now,
          mealType: mealType,
          foods: foods,
          notes: 'Quick log from lifestyle',
        );
        
        await nutritionProvider.logMeal(request);
        await nutritionProvider.loadDailySummary();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _logQuickWater(int amount) async {
    try {
      final nutritionProvider = context.read<NutritionProvider>();
      final now = DateTime.now();
      final waterEntry = WaterEntry(
        time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        amount: amount,
        type: amount > 0 ? 'Glass' : 'Removal',
      );

      final request = WaterLogRequest(
        date: now,
        entries: [waterEntry],
        notes: amount > 0 ? 'Quick log from lifestyle' : 'Quick removal from lifestyle',
      );

      await nutritionProvider.logWater(request);
    } catch (e) {
      // Handle error silently
    }
  }

  String _getMealTypeForTime(DateTime time) {
    final hour = time.hour;
    if (hour < 11) return 'breakfast';
    if (hour < 15) return 'lunch';
    if (hour < 19) return 'dinner';
    return 'snack';
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildModernProteinCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final protein = dailySummary?.protein ?? 0;
        const proteinGoal = 120;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEA580C),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Protein',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${protein.toInt()}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '/ 120g',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProteinCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final protein = dailySummary?.protein ?? 0;
        const proteinGoal = 120;
        final progress = (protein / proteinGoal * 100).clamp(0, 100);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEA580C),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Protein',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Center(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: progress / 100,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEA580C)),
                        strokeWidth: 6,
                      ),
                      Center(
                        child: Text(
                          '${protein.toInt()}g',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Center(
                child: Text(
                  'Goal: ${proteinGoal}g',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(Icons.remove, () => _decrementProtein()),
                  const SizedBox(width: AppConstants.spacing12),
                  const Text(
                    '5g',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  _buildControlButton(Icons.add, () => _incrementProtein()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernFiberCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final fiber = dailySummary?.fiber ?? 0;
        const fiberGoal = 25;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Fiber',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${fiber.toInt()}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '/ 25g',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiberCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final fiber = dailySummary?.fiber ?? 0;
        const fiberGoal = 25;
        final progress = (fiber / fiberGoal * 100).clamp(0, 100);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Fiber',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Center(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: progress / 100,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                        strokeWidth: 6,
                      ),
                      Center(
                        child: Text(
                          '${fiber.toInt()}g',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Center(
                child: Text(
                  'Goal: ${fiberGoal}g',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(Icons.remove, () => _decrementFiber()),
                  const SizedBox(width: AppConstants.spacing12),
                  const Text(
                    '1g',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  _buildControlButton(Icons.add, () => _incrementFiber()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernCarbsCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final carbs = dailySummary?.carbs ?? 0;
        const carbsGoal = 168;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Carbs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F36),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${carbs.toInt()}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '/ 168g',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarbsCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final carbs = dailySummary?.carbs ?? 0;
        const carbsGoal = 168;
        final progress = (carbs / carbsGoal * 100).clamp(0, 100);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 8),
              const Text(
                'Carbs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                value: progress / 100,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Text(
                '${carbs.toInt()}g / ${carbsGoal}g',
                style: const TextStyle(
                  fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                ),
              ),
              Text(
                '${progress.toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernFatCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final fat = dailySummary?.fat ?? 0;
        const fatGoal = 55;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F36),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${fat.toInt()}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '/ 55g',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFatCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final fat = dailySummary?.fat ?? 0;
        const fatGoal = 55;
        final progress = (fat / fatGoal * 100).clamp(0, 100);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 8),
              const Text(
                'Fat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                value: progress / 100,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Text(
                '${fat.toInt()}g / ${fatGoal}g',
                style: const TextStyle(
                  fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                ),
              ),
              Text(
                '${progress.toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernCaloriesCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final calories = dailySummary?.calories ?? 0;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Other',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F36),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Calories row
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                          color: Color(0xFFF97316),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Calories',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const Spacer(),
                  Text(
                        '${calories.toInt()}/126',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
                  ),
                ],
              ),
              
              // Large purple add button overlapping top-right
              Positioned(
                top: 0,
                right: -15,
                child: Container(
                  width: 56,
                  height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCaloriesCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final calories = dailySummary?.calories ?? 0;
        const caloriesGoal = 1646;
        final progress = (calories / caloriesGoal * 100).clamp(0, 100);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                ),
                child: const Icon(
                Icons.local_fire_department,
                  color: Colors.white,
                  size: 20,
              ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${calories.toInt()} / ${caloriesGoal} kcal',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                ),
                child: Text(
                  '${progress.toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernWaterCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final waterAmount = dailySummary?.water ?? 0;
        final waterGoal = dailySummary?.waterGoal ?? 2500;
        
        return Container(
          padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Water box - rectangular outline
                    Container(
                width: 80,
                height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                    color: const Color(0xFFA78BFA),
                          width: 2,
                        ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                child: Text(
                        '${waterAmount.toInt()}ml',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B5CF6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Water',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Goal: ${waterGoal.toInt()}ml',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildControlButton(Icons.remove, () => _decrementWater()),
                        const SizedBox(width: 12),
                        const Text(
                          '237ml',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildControlButton(Icons.add, () => _incrementWater()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaterCard() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final dailySummary = nutritionProvider.dailySummary;
        final waterAmount = dailySummary?.water ?? 0;
        final waterGoal = dailySummary?.waterGoal ?? 2500;
        final waterProgress = (waterAmount / waterGoal * 100).clamp(0, 100);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Water glass with fill level
              SizedBox(
                width: 60,
                height: 80,
                child: Stack(
                  children: [
                    // Glass outline
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    // Water fill
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: (waterProgress / 100) * 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    // Water amount text
                    Center(
                      child: Text(
                        '${waterAmount.toInt()}ml',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 24),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Water',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Goal: ${waterGoal.toInt()}ml',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButton(Icons.remove, () => _decrementWater()),
                        const SizedBox(width: 12),
                        const Text(
                          '237ml',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildControlButton(Icons.add, () => _incrementWater()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernStepsCard() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        final activitySummary = activityProvider.activitySummary;
        final steps = activitySummary?.todaySteps ?? 0;
        final stepsGoal = activitySummary?.stepsGoal ?? 10000;
        final progress = (steps / stepsGoal * 100).clamp(0, 100);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Row(
                children: [
                  const Icon(
                    Icons.directions_run,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Steps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600]!,
                        ),
                      ),
                      Text(
                        '$steps / $stepsGoal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36),
                    ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Footprint icons - 10 total
              Row(
                children: List.generate(10, (index) {
                  final isActive = index < (steps / stepsGoal * 10);
                  return Container(
                    width: 20,
                    height: 20,
                    margin: EdgeInsets.only(right: index == 9 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.red : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bed_rounded,
                      size: 12,
                      color: isActive ? Colors.white : Colors.grey[400],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepsCard() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        final activitySummary = activityProvider.activitySummary;
        final steps = activitySummary?.todaySteps ?? 0;
        final stepsGoal = activitySummary?.stepsGoal ?? 10000;
        final progress = (steps / stepsGoal * 100).clamp(0, 100);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Steps',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Center(
                child: Text(
                  '${steps.toInt()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                minHeight: 8,
              ),
              
              const SizedBox(height: 8),
              
              Center(
                child: Text(
                  'Goal: ${stepsGoal} steps',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernWorkoutCard() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        // Calculate today's workout minutes from workout history
        final workoutsHistory = activityProvider.workoutsHistory;
        final today = DateTime.now();
        final todaysWorkouts = workoutsHistory.where((workout) {
          return workout.date.year == today.year &&
                 workout.date.month == today.month &&
                 workout.date.day == today.day;
        }).toList();
        
        final workoutMinutes = todaysWorkouts.fold<int>(
          0,
          (sum, workout) => sum + workout.duration,
        );
        
        const workoutGoal = 30;
        final progress = (workoutMinutes / workoutGoal * 100).clamp(0, 100);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Workout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Workout',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600]!,
                    ),
                  ),
                  Text(
                        '${workoutMinutes.toString().padLeft(2, '0')} / ${workoutGoal.toString().padLeft(2, '0')} Min',
                    style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DD4BF),
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

  Widget _buildWorkoutCard() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        // Calculate today's workout minutes from workout history
        final workoutsHistory = activityProvider.workoutsHistory;
        final today = DateTime.now();
        final todaysWorkouts = workoutsHistory.where((workout) {
          return workout.date.year == today.year &&
                 workout.date.month == today.month &&
                 workout.date.day == today.day;
        }).toList();
        
        final workoutMinutes = todaysWorkouts.fold<int>(
          0,
          (sum, workout) => sum + workout.duration,
        );
        
        const workoutGoal = 30;
        final progress = (workoutMinutes / workoutGoal * 100).clamp(0, 100);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Workout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Center(
                child: Text(
                  '${workoutMinutes.toInt()} min',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1F36),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                minHeight: 8,
              ),
              
              const SizedBox(height: 8),
              
              Center(
                child: Text(
                  'Goal: ${workoutGoal} min',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.black,
        ),
      ),
    );
  }
}

