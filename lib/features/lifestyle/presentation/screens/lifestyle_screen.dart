import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/nutrition_provider.dart';
import '../../../../core/providers/activity_provider.dart';
import '../../../../core/api/models/nutrition_log_model.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  @override
  void initState() {
    super.initState();
    // Load all data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().loadNutritionData();
      context.read<ActivityProvider>().loadActivityData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lifestyle Goals',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1F36),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Macronutrients Section - 2x2 Grid
              _buildSectionHeader('MACRONUTRIENTS'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildModernProteinCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildModernFiberCard()),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildModernCarbsCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildModernFatCard()),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Water Section
              _buildSectionHeader('WATER'),
              const SizedBox(height: 16),
              _buildModernWaterCard(),
              
              const SizedBox(height: 24),
              
              // Other Nutrition Section
              _buildSectionHeader('OTHER'),
              const SizedBox(height: 16),
              _buildModernCaloriesCard(),
              
              const SizedBox(height: 24),
              
              // Activity Section
              _buildSectionHeader('ACTIVITY'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildModernStepsCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildModernWorkoutCard()),
                ],
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9CA3AF),
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
        final progress = (protein / proteinGoal * 100).clamp(0, 100);
        
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
                      fontSize: 14,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/${proteinGoal}g',
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
        final progress = (fiber / fiberGoal * 100).clamp(0, 100);
        
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
                      fontSize: 14,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/${fiberGoal}g',
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
        final progress = (carbs / carbsGoal * 100).clamp(0, 100);
        
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
              const Text(
                'Carbs',
                style: TextStyle(
                  fontSize: 14,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/${carbsGoal}g',
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
        final progress = (fat / fatGoal * 100).clamp(0, 100);
        
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
              const Text(
                'Fat',
                style: TextStyle(
                  fontSize: 14,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/${fatGoal}g',
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
              
              const SizedBox(height: 16),
              
              // Calories row
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
                    'Calories',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${calories.toInt()}/${caloriesGoal}kcal',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Carbs row
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(dailySummary?.carbs ?? 0).toInt()}/154g',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Fat row
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(dailySummary?.fat ?? 0).toInt()}/42g',
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
                    'Steps',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Steps visualization with footprints
              Row(
                children: List.generate(5, (index) {
                  final isActive = index < (steps / stepsGoal * 5);
                  return Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFDC2626) : const Color(0xFFE5E7EB),
                    ),
                    child: Icon(
                      Icons.directions_walk,
                      size: 10,
                      color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Steps',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  Text(
                    '${steps.toInt()}/${stepsGoal}',
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
              
              const SizedBox(height: 16),
              
              // Workout visualization with fitness icons
              Row(
                children: List.generate(5, (index) {
                  final isActive = index < (workoutMinutes / workoutGoal * 5);
                  return Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFDC2626) : const Color(0xFFE5E7EB),
                    ),
                    child: Icon(
                    Icons.fitness_center,
                      size: 10,
                      color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Workout',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  Text(
                    '${workoutMinutes.toInt()}/${workoutGoal}min',
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
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
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

  void _incrementProtein() {
    _logQuickNutrition(protein: 5);
  }

  void _decrementProtein() {
    _logQuickNutrition(protein: -5);
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
}

