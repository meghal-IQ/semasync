import 'package:flutter/material.dart';
import '../../../../core/services/ai_food_recognition_service.dart';
import '../../../../core/services/food_recognition_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/food_database_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MealLoggingScreen extends StatefulWidget {
  final FoodItem? preselectedFood;
  
  const MealLoggingScreen({super.key, this.preselectedFood});

  @override
  State<MealLoggingScreen> createState() => _MealLoggingScreenState();
}

class _MealLoggingScreenState extends State<MealLoggingScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'Breakfast';
  String _selectedFood = '';
  double _servingSize = 1.0;
  String _notes = '';
  List<Map<String, dynamic>> _foodItems = [];

  final List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  final List<Map<String, dynamic>> _foodDatabase = [
    // Proteins
    {
      'name': 'Chicken Breast',
      'calories': 165.0,
      'protein': 31.0,
      'carbs': 0.0,
      'fat': 3.6,
      'category': 'Protein',
      'barcode': '123456789'
    },
    {
      'name': 'Salmon Fillet',
      'calories': 208.0,
      'protein': 25.0,
      'carbs': 0.0,
      'fat': 12.0,
      'category': 'Protein',
      'barcode': '123456790'
    },
    {
      'name': 'Ground Turkey',
      'calories': 189.0,
      'protein': 22.0,
      'carbs': 0.0,
      'fat': 10.0,
      'category': 'Protein',
      'barcode': '123456791'
    },
    {
      'name': 'Eggs (Large)',
      'calories': 70.0,
      'protein': 6.0,
      'carbs': 0.6,
      'fat': 5.0,
      'category': 'Protein',
      'barcode': '123456792'
    },
    {
      'name': 'Greek Yogurt',
      'calories': 100.0,
      'protein': 17.0,
      'carbs': 6.0,
      'fat': 0.0,
      'category': 'Dairy',
      'barcode': '123456793'
    },
    {
      'name': 'Cottage Cheese',
      'calories': 98.0,
      'protein': 11.0,
      'carbs': 3.4,
      'fat': 4.3,
      'category': 'Dairy',
      'barcode': '123456794'
    },
    
    // Carbohydrates
    {
      'name': 'Brown Rice',
      'calories': 111.0,
      'protein': 2.6,
      'carbs': 23.0,
      'fat': 0.9,
      'category': 'Grains',
      'barcode': '123456795'
    },
    {
      'name': 'Quinoa',
      'calories': 120.0,
      'protein': 4.4,
      'carbs': 22.0,
      'fat': 1.9,
      'category': 'Grains',
      'barcode': '123456796'
    },
    {
      'name': 'Sweet Potato',
      'calories': 86.0,
      'protein': 1.6,
      'carbs': 20.0,
      'fat': 0.1,
      'category': 'Vegetables',
      'barcode': '123456797'
    },
    {
      'name': 'Oatmeal',
      'calories': 68.0,
      'protein': 2.4,
      'carbs': 12.0,
      'fat': 1.4,
      'category': 'Grains',
      'barcode': '123456798'
    },
    {
      'name': 'Banana',
      'calories': 89.0,
      'protein': 1.1,
      'carbs': 23.0,
      'fat': 0.3,
      'category': 'Fruits',
      'barcode': '123456799'
    },
    {
      'name': 'Apple',
      'calories': 52.0,
      'protein': 0.3,
      'carbs': 14.0,
      'fat': 0.2,
      'category': 'Fruits',
      'barcode': '123456800'
    },
    
    // Vegetables
    {
      'name': 'Broccoli',
      'calories': 34.0,
      'protein': 2.8,
      'carbs': 7.0,
      'fat': 0.4,
      'category': 'Vegetables',
      'barcode': '123456801'
    },
    {
      'name': 'Spinach',
      'calories': 23.0,
      'protein': 2.9,
      'carbs': 3.6,
      'fat': 0.4,
      'category': 'Vegetables',
      'barcode': '123456802'
    },
    {
      'name': 'Carrots',
      'calories': 41.0,
      'protein': 0.9,
      'carbs': 10.0,
      'fat': 0.2,
      'category': 'Vegetables',
      'barcode': '123456803'
    },
    {
      'name': 'Bell Peppers',
      'calories': 31.0,
      'protein': 1.0,
      'carbs': 7.0,
      'fat': 0.3,
      'category': 'Vegetables',
      'barcode': '123456804'
    },
    
    // Fats
    {
      'name': 'Almonds',
      'calories': 579.0,
      'protein': 21.0,
      'carbs': 22.0,
      'fat': 50.0,
      'category': 'Nuts',
      'barcode': '123456805'
    },
    {
      'name': 'Avocado',
      'calories': 160.0,
      'protein': 2.0,
      'carbs': 9.0,
      'fat': 15.0,
      'category': 'Fruits',
      'barcode': '123456806'
    },
    {
      'name': 'Olive Oil',
      'calories': 884.0,
      'protein': 0.0,
      'carbs': 0.0,
      'fat': 100.0,
      'category': 'Oils',
      'barcode': '123456807'
    },
    {
      'name': 'Peanut Butter',
      'calories': 588.0,
      'protein': 25.0,
      'carbs': 20.0,
      'fat': 50.0,
      'category': 'Nuts',
      'barcode': '123456808'
    },
    
    // Common Meals
    {
      'name': 'Grilled Chicken Salad',
      'calories': 250.0,
      'protein': 30.0,
      'carbs': 15.0,
      'fat': 8.0,
      'category': 'Meal',
      'barcode': '123456809'
    },
    {
      'name': 'Salmon with Rice',
      'calories': 400.0,
      'protein': 35.0,
      'carbs': 35.0,
      'fat': 15.0,
      'category': 'Meal',
      'barcode': '123456810'
    },
    {
      'name': 'Protein Smoothie',
      'calories': 200.0,
      'protein': 25.0,
      'carbs': 20.0,
      'fat': 5.0,
      'category': 'Beverage',
      'barcode': '123456811'
    },
  ];

  final List<String> _foodCategories = [
    'All',
    'Protein',
    'Dairy',
    'Grains',
    'Vegetables',
    'Fruits',
    'Nuts',
    'Oils',
    'Meal',
    'Beverage',
  ];

  String _selectedCategory = 'All';
  File? _capturedImage;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedFood != null) {
      _addPreselectedFood();
    }
  }

  void _addPreselectedFood() {
    final food = widget.preselectedFood!;
    final foodItem = {
      'name': food.name,
      'calories': food.calories,
      'protein': food.protein,
      'carbs': food.carbs,
      'fat': food.fat,
      'fiber': food.fiber,
      'category': food.category,
      'servingSize': _servingSize,
    };
    
    setState(() {
      _foodItems.add(foodItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              _saveMeal(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          _buildDateSelector(),
          const SizedBox(height: AppConstants.spacing16),
          _buildMealTypeSelector(),
          const SizedBox(height: AppConstants.spacing16),
          _buildFoodSearch(),
          const SizedBox(height: AppConstants.spacing16),
          _buildServingSizeSelector(),
          const SizedBox(height: AppConstants.spacing16),
          _buildFoodItemsList(),
          const SizedBox(height: AppConstants.spacing16),
          _buildQuickNutritionSummary(),
          const SizedBox(height: AppConstants.spacing16),
          _buildNutritionSummary(),
          const SizedBox(height: AppConstants.spacing16),
          _buildNotesField(),
          const SizedBox(height: AppConstants.spacing32),
          _buildSaveButton(),
          const SizedBox(height: AppConstants.spacing16),
          // TEMPORARY: Test button for debugging
          ElevatedButton(
            onPressed: _testRecognitionDialog,
            child: const Text('Test Recognition Dialog'),
          ),
          const SizedBox(height: AppConstants.spacing8),
          // Simple test button
          ElevatedButton(
            onPressed: _simpleTestDialog,
            child: const Text('Simple Test Dialog'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.primary),
        title: const Text('Date & Time'),
        subtitle: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate
              .year} at ${_selectedDate.hour}:${_selectedDate.minute.toString()
              .padLeft(2, '0')}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectDateTime,
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.restaurant, color: AppColors.primary),
        title: const Text('Meal Type'),
        subtitle: Text(_selectedMealType),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectMealType,
      ),
    );
  }

  Widget _buildFoodSearch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Search Food',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _captureFoodImage,
                      tooltip: 'Take Photo',
                    ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanBarcode,
                      tooltip: 'Scan Barcode',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search for food items...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedFood = value;
                });
              },
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildCategoryFilter(),
            const SizedBox(height: AppConstants.spacing12),
            if (_selectedFood.isNotEmpty || _selectedCategory != 'All') ...[
              _buildFoodResults(),
            ] else
              ...[
              _buildQuickFoodSuggestions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _foodCategories.map((category) => 
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.spacing8),
            child: FilterChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildFoodResults() {
    final filteredFoods = _foodDatabase.where((food) {
      final matchesSearch = _selectedFood.isEmpty || 
          food['name'].toLowerCase().contains(_selectedFood.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || 
          food['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (filteredFoods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'No food items found',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Try a different search term or category',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredFoods.map((food) => _buildFoodItemTile(food)).toList(),
    );
  }

  Widget _buildQuickFoodSuggestions() {
    final recentFoods = _foodDatabase.take(6).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Add',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        Wrap(
          spacing: AppConstants.spacing8,
          runSpacing: AppConstants.spacing8,
          children: recentFoods.map((food) => 
            GestureDetector(
              onTap: () => _addFoodItem(food),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing12,
                  vertical: AppConstants.spacing8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      food['name'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${food['calories']} cal',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildFoodItemTile(Map<String, dynamic> food) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _showFoodDetails(food),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing8),
            decoration: BoxDecoration(
              color: _getCategoryColor(food['category']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              _getCategoryIcon(food['category']),
              color: _getCategoryColor(food['category']),
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                  // Enhanced nutritional info display with all data
                  Wrap(
                    spacing: AppConstants.spacing6,
                    runSpacing: AppConstants.spacing4,
                  children: [
                      _buildNutritionChip(
                          '${food['calories']} cal', AppColors.proteinOrange),
                      _buildNutritionChip(
                          '${food['protein']}g protein', AppColors.fiberGreen),
                      _buildNutritionChip(
                          '${food['carbs']}g carbs', AppColors.waterBlue),
                      _buildNutritionChip(
                          '${food['fat']}g fat', AppColors.activityRed),
                      if (food['fiber'] > 0)
                        _buildNutritionChip(
                            '${food['fiber']}g fiber', AppColors.fiberGreen),
                      if (food['sodium'] > 0)
                        _buildNutritionChip('${food['sodium']}mg sodium',
                            AppColors.activityRed),
                      if (food['saturatedFat'] > 0)
                        _buildNutritionChip('${food['saturatedFat']}g sat fat',
                            AppColors.activityRed),
                      if (food['totalSugars'] > 0)
                        _buildNutritionChip('${food['totalSugars']}g sugar',
                            AppColors.waterBlue),
                      if (food['cholesterol'] > 0)
                        _buildNutritionChip('${food['cholesterol']}mg chol',
                            AppColors.activityRed),
                      if (food['potassium'] > 0)
                        _buildNutritionChip(
                            '${food['potassium']}mg K', AppColors.fiberGreen),
                      if (food['calcium'] > 0)
                        _buildNutritionChip(
                            '${food['calcium']}mg Ca', AppColors.waterBlue),
                      if (food['iron'] > 0)
                        _buildNutritionChip(
                            '${food['iron']}mg Fe', AppColors.proteinOrange),
                      if (food['vitaminA'] > 0)
                        _buildNutritionChip(
                            '${food['vitaminA']}mcg A', AppColors.fiberGreen),
                      if (food['vitaminC'] > 0)
                        _buildNutritionChip(
                            '${food['vitaminC']}mg C', AppColors.waterBlue),
                      if (food['vitaminD'] > 0)
                        _buildNutritionChip('${food['vitaminD']}mcg D',
                            AppColors.proteinOrange),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                    Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing6,
                      vertical: AppConstants.spacing2,
                      ),
                      decoration: BoxDecoration(
                      color: _getCategoryColor(food['category']).withOpacity(
                          0.2),
                      borderRadius: BorderRadius.circular(
                          AppConstants.radiusSmall),
                      ),
                      child: Text(
                        food['category'],
                        style: TextStyle(
                          color: _getCategoryColor(food['category']),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(
                      Icons.info_outline, color: AppColors.primary),
                  onPressed: () => _showFoodDetails(food),
                  tooltip: 'View Details',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: () => _addFoodItem(food),
                  tooltip: 'Add to Meal',
          ),
        ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServingSizeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Serving Size',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_servingSize.toStringAsFixed(1)} serving${_servingSize != 1
                      ? 's'
                      : ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Slider(
              value: _servingSize,
              min: 0.1,
              max: 5.0,
              divisions: 49,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _servingSize = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0.1 serving',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '5.0 servings',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemsList() {
    if (_foodItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppConstants.spacing12),
              Text(
                'No food items added yet',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Search and add food items to log your meal',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Food Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            ..._foodItems.map((item) => _buildFoodItemTile(item)).toList(),
          ],
        ),
      ),
    );
  }


  Widget _buildQuickNutritionSummary() {
    if (_foodItems.isEmpty) return const SizedBox.shrink();

    // Calculate totals
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;

    for (var item in _foodItems) {
      final servingSize = item['servingSize'] as double;
      totalCalories += ((item['calories'] as double) * servingSize);
      totalProtein += ((item['protein'] as double) * servingSize);
      totalCarbs += ((item['carbs'] as double) * servingSize);
      totalFat += ((item['fat'] as double) * servingSize);
      totalFiber += ((item['fiber'] as double) * servingSize);
    }

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.spacing8),
                const Text(
                  'Meal Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Large calorie display
            Center(
              child: Column(
                children: [
                  Text(
                    totalCalories.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    'Calories',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing20),

            // Macro breakdown
            Row(
              children: [
                Expanded(
                  child: _buildQuickMacroItem(
                      'Protein', totalProtein.toStringAsFixed(1), 'g',
                      AppColors.fiberGreen),
                ),
                Expanded(
                  child: _buildQuickMacroItem(
                      'Carbs', totalCarbs.toStringAsFixed(1), 'g',
                      AppColors.waterBlue),
                ),
                Expanded(
                  child: _buildQuickMacroItem(
                      'Fat', totalFat.toStringAsFixed(1), 'g',
                      AppColors.activityRed),
                ),
                Expanded(
                  child: _buildQuickMacroItem(
                      'Fiber', totalFiber.toStringAsFixed(1), 'g',
                      AppColors.fiberGreen),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMacroItem(String label, String value, String unit,
      Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.7),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionSummary() {
    if (_foodItems.isEmpty) return const SizedBox.shrink();

    // Calculate totals
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalSaturatedFat = 0;
    double totalPolyunsaturatedFat = 0;
    double totalMonounsaturatedFat = 0;
    double totalTransFat = 0;
    double totalCholesterol = 0;
    double totalSodium = 0;
    double totalTotalSugars = 0;
    double totalAddedSugar = 0;
    double totalPotassium = 0;
    double totalCalcium = 0;
    double totalIron = 0;
    double totalVitaminA = 0;
    double totalVitaminC = 0;
    double totalVitaminD = 0;

    for (var item in _foodItems) {
      final servingSize = item['servingSize'] as double;
      totalCalories += ((item['calories'] as double) * servingSize);
      totalProtein += ((item['protein'] as double) * servingSize);
      totalCarbs += ((item['carbs'] as double) * servingSize);
      totalFat += ((item['fat'] as double) * servingSize);
      totalFiber += ((item['fiber'] as double) * servingSize);
      totalSaturatedFat += ((item['saturatedFat'] as double) * servingSize);
      totalPolyunsaturatedFat +=
      ((item['polyunsaturatedFat'] as double) * servingSize);
      totalMonounsaturatedFat +=
      ((item['monounsaturatedFat'] as double) * servingSize);
      totalTransFat += ((item['transFat'] as double) * servingSize);
      totalCholesterol += ((item['cholesterol'] as double) * servingSize);
      totalSodium += ((item['sodium'] as double) * servingSize);
      totalTotalSugars += ((item['totalSugars'] as double) * servingSize);
      totalAddedSugar += ((item['addedSugar'] as double) * servingSize);
      totalPotassium += ((item['potassium'] as double) * servingSize);
      totalCalcium += ((item['calcium'] as double) * servingSize);
      totalIron += ((item['iron'] as double) * servingSize);
      totalVitaminA += ((item['vitaminA'] as double) * servingSize);
      totalVitaminC += ((item['vitaminC'] as double) * servingSize);
      totalVitaminD += ((item['vitaminD'] as double) * servingSize);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutrition Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Main macros with enhanced display
            Row(
              children: [
                Expanded(
                  child: _buildNutritionItem(
                      'Calories', totalCalories.toStringAsFixed(0), 'cal',
                      AppColors.proteinOrange),
                ),
                Expanded(
                  child: _buildNutritionItem(
                      'Protein', totalProtein.toStringAsFixed(1), 'g',
                      AppColors.fiberGreen),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing12),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionItem(
                      'Carbs', totalCarbs.toStringAsFixed(1), 'g',
                      AppColors.waterBlue),
                ),
                Expanded(
                  child: _buildNutritionItem(
                      'Fat', totalFat.toStringAsFixed(1), 'g',
                      AppColors.activityRed),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing12),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionItem(
                      'Fiber', totalFiber.toStringAsFixed(1), 'g',
                      AppColors.fiberGreen),
                ),
                Expanded(
                  child: _buildNutritionItem(
                      'Sodium', totalSodium.toStringAsFixed(0), 'mg',
                      AppColors.activityRed),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            const Divider(),
            const SizedBox(height: AppConstants.spacing16),

            // Detailed breakdown with better organization
            ExpansionTile(
              title: const Text(
                'Detailed Nutrition Information',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              children: [
                // Carbohydrates Section
                _buildNutritionSection('Carbohydrates', [
                  _buildNutritionRow(
                      'Total Carbohydrates', totalCarbs.toStringAsFixed(1),
                      'g'),
                  _buildNutritionRow(
                      'Dietary Fiber', totalFiber.toStringAsFixed(1), 'g'),
                  _buildNutritionRow(
                      'Total Sugars', totalTotalSugars.toStringAsFixed(1), 'g'),
                  _buildNutritionRow(
                      'Added Sugar', totalAddedSugar.toStringAsFixed(1), 'g'),
                ]),

                // Fats Section
                _buildNutritionSection('Fats', [
                  _buildNutritionRow(
                      'Total Fat', totalFat.toStringAsFixed(1), 'g'),
                  _buildNutritionRow(
                      'Saturated Fat', totalSaturatedFat.toStringAsFixed(1),
                      'g'),
                  _buildNutritionRow('Polyunsaturated Fat',
                      totalPolyunsaturatedFat.toStringAsFixed(1), 'g'),
                  _buildNutritionRow('Monounsaturated Fat',
                      totalMonounsaturatedFat.toStringAsFixed(1), 'g'),
                  _buildNutritionRow(
                      'Trans Fat', totalTransFat.toStringAsFixed(1), 'g'),
                  _buildNutritionRow(
                      'Cholesterol', totalCholesterol.toStringAsFixed(1), 'mg'),
                ]),

                // Minerals Section
                _buildNutritionSection('Minerals', [
                  _buildNutritionRow(
                      'Sodium', totalSodium.toStringAsFixed(0), 'mg'),
                  _buildNutritionRow(
                      'Potassium', totalPotassium.toStringAsFixed(0), 'mg'),
                  _buildNutritionRow(
                      'Calcium', totalCalcium.toStringAsFixed(0), 'mg'),
                  _buildNutritionRow(
                      'Iron', totalIron.toStringAsFixed(1), 'mg'),
                ]),

                // Vitamins Section
                _buildNutritionSection('Vitamins', [
                  _buildNutritionRow(
                      'Vitamin A', totalVitaminA.toStringAsFixed(0), 'mcg'),
                  _buildNutritionRow(
                      'Vitamin C', totalVitaminC.toStringAsFixed(0), 'mg'),
                  _buildNutritionRow(
                      'Vitamin D', totalVitaminD.toStringAsFixed(0), 'mcg'),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing16,
            vertical: AppConstants.spacing8,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: AppConstants.spacing8),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '$value$unit',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing6,
        vertical: AppConstants.spacing2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String unit,
      Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add any notes about your meal...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _notes = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _foodItems.isEmpty ? null : _saveMeal(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
        ),
        child: const Text(
          'Log Meal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970), // Allow historical data entry from 1970
      lastDate: DateTime.now(),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectMealType() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) =>
          AlertDialog(
        title: const Text('Select Meal Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
              children: _mealTypes.map((type) =>
                  ListTile(
            title: Text(type),
            onTap: () => Navigator.pop(context, type),
          )).toList(),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMealType = result;
      });
    }
  }

  void _addFoodItem(Map<String, dynamic> food) {
    setState(() {
      _foodItems.add({
        ...food,
        'servingSize': _servingSize,
      });
      _selectedFood = '';
      _servingSize = 1.0;
    });
  }

  void _showFoodDetails(Map<String, dynamic> food) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(food['name']),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Basic Info
                  _buildDetailSection('Basic Information', [
                    _buildDetailRow('Category', food['category']),
                    _buildDetailRow('Serving Size', food['servingSize']),
                    if (food['brand'] != null && food['brand'] != 'Generic')
                      _buildDetailRow('Brand', food['brand']),
                  ]),

                  // Macronutrients
                  _buildDetailSection('Macronutrients (per 100g)', [
                    _buildDetailRow('Calories', '${food['calories']} cal'),
                    _buildDetailRow('Protein', '${food['protein']}g'),
                    _buildDetailRow('Carbohydrates', '${food['carbs']}g'),
                    _buildDetailRow('Total Fat', '${food['fat']}g'),
                    _buildDetailRow('Dietary Fiber', '${food['fiber']}g'),
                    _buildDetailRow('Total Sugars', '${food['totalSugars']}g'),
                    _buildDetailRow('Added Sugar', '${food['addedSugar']}g'),
                  ]),

                  // Fat Breakdown
                  _buildDetailSection('Fat Breakdown', [
                    _buildDetailRow(
                        'Saturated Fat', '${food['saturatedFat']}g'),
                    _buildDetailRow('Polyunsaturated Fat',
                        '${food['polyunsaturatedFat']}g'),
                    _buildDetailRow('Monounsaturated Fat',
                        '${food['monounsaturatedFat']}g'),
                    _buildDetailRow('Trans Fat', '${food['transFat']}g'),
                    _buildDetailRow('Cholesterol', '${food['cholesterol']}mg'),
                  ]),

                  // Minerals
                  _buildDetailSection('Minerals', [
                    _buildDetailRow('Sodium', '${food['sodium']}mg'),
                    _buildDetailRow('Potassium', '${food['potassium']}mg'),
                    _buildDetailRow('Calcium', '${food['calcium']}mg'),
                    _buildDetailRow('Iron', '${food['iron']}mg'),
                  ]),

                  // Vitamins
                  _buildDetailSection('Vitamins', [
                    _buildDetailRow('Vitamin A', '${food['vitaminA']}mcg'),
                    _buildDetailRow('Vitamin C', '${food['vitaminC']}mg'),
                    _buildDetailRow('Vitamin D', '${food['vitaminD']}mcg'),
                  ]),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addFoodItem(food);
                },
                child: const Text('Add to Meal'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.spacing16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _removeFoodItem(Map<String, dynamic> item) {
    setState(() {
      _foodItems.remove(item);
    });
  }

  void _scanBarcode() {
    setState(() {
      _isScanning = true;
    });
    
    // Simulate barcode scanning
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isScanning = false;
      });
      
      // Mock barcode result
      final mockBarcode = '123456789';
      final foundFood = _foodDatabase.firstWhere(
        (food) => food['barcode'] == mockBarcode,
        orElse: () => <String, dynamic>{},
      );
      
      if (foundFood.isNotEmpty) {
        _addFoodItem(foundFood);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found: ${foundFood['name']}'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food not found in database'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    });
  }

  Future<void> _captureFoodImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
        
        // Simulate food recognition
        _simulateFoodRecognition();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _simulateFoodRecognition() async {
    if (_capturedImage == null) return;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
        const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppConstants.spacing16),
              Text('Analyzing food image...'),
            ],
          ),
        ),
      );

      // Call AI food recognition service
      print('🔍 Starting AI recognition...');
      final results = await AIFoodRecognitionService.recognizeFoodFromImage(
          _capturedImage!);
      
      // TEMPORARY: Force some test results if empty
      if (results.isEmpty) {
        print('🔧 Adding test results for debugging...');
        final testFood = FoodItem(
          id: 'test_1',
          name: 'Test Food Item',
          calories: 250.0,
          protein: 15.0,
          carbs: 30.0,
          fat: 8.0,
          fiber: 5.0,
          servingSize: '1 serving',
          brand: 'Test Brand',
          category: 'Test Category',
        );
        results.add(FoodRecognitionResult(
          foodItem: testFood,
          confidence: 0.85,
          servingSize: '1 serving',
        ));
      }

      // Close loading dialog
      Navigator.pop(context);

      print('🔍 Recognition results: ${results.length} items found');
      for (int i = 0; i < results.length; i++) {
        print('🔍 Result $i: ${results[i].foodItem.name} (${(results[i].confidence * 100).toInt()}%)');
      }
      
      if (results.isEmpty) {
        print('⚠️ No results found, showing fallback message');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not recognize food in image'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      // Show results dialog
      print('✅ Showing recognition results modal with ${results.length} results');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Food Recognition Results'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                  // Debug info
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Debug: ${results.length} results found',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
              if (_capturedImage != null) ...[
                Container(
                        height: 150,
                        width: double.infinity,
                  decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusSmall),
                    image: DecorationImage(
                      image: FileImage(_capturedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                      const SizedBox(height: AppConstants.spacing16),
                    ],
                    const Text('Recognized foods:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppConstants.spacing12),
                    if (results.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppConstants.spacing16),
                        child: Text(
                          'No food items were recognized in this image. Please try taking another photo.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else ...[
                      // Simple list first to test
                      ...results.map((result) {
                        print('🎯 Result: ${result.foodItem.name} (${(result.confidence * 100).toInt()}%)');
                        return ListTile(
                          title: Text(result.foodItem.name),
                          subtitle: Text('${(result.confidence * 100).toInt()}% confidence'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                                onPressed: () {
                                  _addFoodItemFromResult(result);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                      const Text('Detailed View:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Detailed cards
                      ...results.map((result) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(
                                AppConstants.spacing12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        result.foodItem.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.info_outline,
                                              color: AppColors.primary),
                                          onPressed: () =>
                                              _showFoodDetailsFromResult(
                                                  result),
                                          tooltip: 'View Details',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle,
                                              color: AppColors.primary),
                                          onPressed: () {
                                            _addFoodItemFromResult(result);
                  Navigator.pop(context);
                },
                                          tooltip: 'Add to Meal',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  'Confidence: ${(result.confidence * 100)
                                      .toInt()}%',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacing8),
                                const Divider(),
                                const SizedBox(height: AppConstants.spacing8),
                                // Enhanced nutritional display
                                Wrap(
                                  spacing: AppConstants.spacing8,
                                  runSpacing: AppConstants.spacing4,
                                  children: [
                                    _buildNutritionChip(
                                        '${result.foodItem.calories
                                            .toInt()} cal',
                                        AppColors.proteinOrange),
                                    _buildNutritionChip(
                                        '${result.foodItem.protein}g protein',
                                        AppColors.fiberGreen),
                                    _buildNutritionChip(
                                        '${result.foodItem.carbs}g carbs',
                                        AppColors.waterBlue),
                                    _buildNutritionChip(
                                        '${result.foodItem.fat}g fat',
                                        AppColors.activityRed),
                                    if (result.foodItem.fiber > 0)
                                      _buildNutritionChip(
                                          '${result.foodItem.fiber}g fiber',
                                          AppColors.fiberGreen),
                                    if (result.foodItem.sodium > 0)
                                      _buildNutritionChip(
                                          '${result.foodItem.sodium}mg sodium',
                                          AppColors.activityRed),
                                    if (result.foodItem.saturatedFat > 0)
                                      _buildNutritionChip('${result.foodItem
                                          .saturatedFat}g sat fat',
                                          AppColors.activityRed),
                                    if (result.foodItem.totalSugars > 0)
                                      _buildNutritionChip('${result.foodItem
                                          .totalSugars}g sugar',
                                          AppColors.waterBlue),
                                    if (result.foodItem.cholesterol > 0)
                                      _buildNutritionChip('${result.foodItem
                                          .cholesterol}mg chol',
                                          AppColors.activityRed),
                                    if (result.foodItem.potassium > 0)
                                      _buildNutritionChip(
                                          '${result.foodItem.potassium}mg K',
                                          AppColors.fiberGreen),
                                    if (result.foodItem.calcium > 0)
                                      _buildNutritionChip(
                                          '${result.foodItem.calcium}mg Ca',
                                          AppColors.waterBlue),
                                    if (result.foodItem.iron > 0)
                                      _buildNutritionChip(
                                          '${result.foodItem.iron}mg Fe',
                                          AppColors.proteinOrange),
                                    if (result.foodItem.vitaminA > 0)
                                      _buildNutritionChip(
                                          '${result.foodItem.vitaminA}mcg A',
                                          AppColors.fiberGreen),
                                    if (result.foodItem.vitaminC > 0)
                                      _buildNutritionChip(
                                          '${result.foodItem.vitaminC}mg C',
                                          AppColors.waterBlue),
                                    if (result.foodItem.vitaminD > 0)
                                      _buildNutritionChip(
                                          '${result.foodItem.vitaminD}mcg D',
                                          AppColors.proteinOrange),
                                  ],
                                ),
                                const SizedBox(height: AppConstants.spacing12),
                                Text(
                                  'Serving Size: ${result.servingSize}',
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
              // actions: [
              //   TextButton(
              //     onPressed: () => Navigator.pop(context),
              //     child: const Text('Cancel'),
              //   ),
              // ],
            ),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing food: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildNutrientInfo(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value + unit,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _addFoodItemFromResult(FoodRecognitionResult result) {
    final foodItem = {
      'name': result.foodItem.name,
      'calories': result.foodItem.calories,
      'protein': result.foodItem.protein,
      'carbs': result.foodItem.carbs,
      'fat': result.foodItem.fat,
      'fiber': result.foodItem.fiber,
      'category': result.foodItem.category,
      'servingSize': _servingSize,
      // Additional nutritional information
      'saturatedFat': result.foodItem.saturatedFat,
      'polyunsaturatedFat': result.foodItem.polyunsaturatedFat,
      'monounsaturatedFat': result.foodItem.monounsaturatedFat,
      'transFat': result.foodItem.transFat,
      'cholesterol': result.foodItem.cholesterol,
      'sodium': result.foodItem.sodium,
      'totalSugars': result.foodItem.totalSugars,
      'addedSugar': result.foodItem.addedSugar,
      'potassium': result.foodItem.potassium,
      'calcium': result.foodItem.calcium,
      'iron': result.foodItem.iron,
      'vitaminA': result.foodItem.vitaminA,
      'vitaminC': result.foodItem.vitaminC,
      'vitaminD': result.foodItem.vitaminD,
    };

    setState(() {
      _foodItems.add(foodItem);
      _servingSize = 1.0;
    });
  }

  void _showFoodDetailsFromResult(FoodRecognitionResult result) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(result.foodItem.name),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Basic Info
                  _buildDetailSection('Basic Information', [
                    _buildDetailRow('Category', result.foodItem.category),
                    _buildDetailRow('Serving Size', result.servingSize!),
                    _buildDetailRow(
                        'Confidence', '${(result.confidence * 100).toInt()}%'),
                    if (result.foodItem.brand != null &&
                        result.foodItem.brand != 'Generic')
                      _buildDetailRow('Brand', result.foodItem.brand!),
                  ]),

                  // Macronutrients
                  _buildDetailSection('Macronutrients (per 100g)', [
                    _buildDetailRow(
                        'Calories', '${result.foodItem.calories} cal'),
                    _buildDetailRow('Protein', '${result.foodItem.protein}g'),
                    _buildDetailRow(
                        'Carbohydrates', '${result.foodItem.carbs}g'),
                    _buildDetailRow('Total Fat', '${result.foodItem.fat}g'),
                    _buildDetailRow(
                        'Dietary Fiber', '${result.foodItem.fiber}g'),
                    _buildDetailRow(
                        'Total Sugars', '${result.foodItem.totalSugars}g'),
                    _buildDetailRow(
                        'Added Sugar', '${result.foodItem.addedSugar}g'),
                  ]),

                  // Fat Breakdown
                  _buildDetailSection('Fat Breakdown', [
                    _buildDetailRow(
                        'Saturated Fat', '${result.foodItem.saturatedFat}g'),
                    _buildDetailRow('Polyunsaturated Fat',
                        '${result.foodItem.polyunsaturatedFat}g'),
                    _buildDetailRow('Monounsaturated Fat',
                        '${result.foodItem.monounsaturatedFat}g'),
                    _buildDetailRow(
                        'Trans Fat', '${result.foodItem.transFat}g'),
                    _buildDetailRow(
                        'Cholesterol', '${result.foodItem.cholesterol}mg'),
                  ]),

                  // Minerals
                  _buildDetailSection('Minerals', [
                    _buildDetailRow('Sodium', '${result.foodItem.sodium}mg'),
                    _buildDetailRow(
                        'Potassium', '${result.foodItem.potassium}mg'),
                    _buildDetailRow('Calcium', '${result.foodItem.calcium}mg'),
                    _buildDetailRow('Iron', '${result.foodItem.iron}mg'),
                  ]),

                  // Vitamins
                  _buildDetailSection('Vitamins', [
                    _buildDetailRow(
                        'Vitamin A', '${result.foodItem.vitaminA}mcg'),
                    _buildDetailRow(
                        'Vitamin C', '${result.foodItem.vitaminC}mg'),
                    _buildDetailRow(
                        'Vitamin D', '${result.foodItem.vitaminD}mcg'),
                  ]),
                ],
              ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addFoodItemFromResult(result);
                },
                child: const Text('Add to Meal'),
            ),
          ],
        ),
      );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Protein':
        return AppColors.proteinOrange;
      case 'Dairy':
        return AppColors.waterBlue;
      case 'Grains':
        return AppColors.fiberGreen;
      case 'Vegetables':
        return AppColors.success;
      case 'Fruits':
        return AppColors.warning;
      case 'Nuts':
        return AppColors.activityRed;
      case 'Oils':
        return AppColors.textPrimary;
      case 'Meal':
        return AppColors.primary;
      case 'Beverage':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Protein':
        return Icons.restaurant;
      case 'Dairy':
        return Icons.local_drink;
      case 'Grains':
        return Icons.grain;
      case 'Vegetables':
        return Icons.eco;
      case 'Fruits':
        return Icons.apple;
      case 'Nuts':
        return Icons.circle;
      case 'Oils':
        return Icons.opacity;
      case 'Meal':
        return Icons.restaurant_menu;
      case 'Beverage':
        return Icons.local_cafe;
      default:
        return Icons.fastfood;
    }
  }

  _saveMeal(context) {
    // TODO: Save meal data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal logged successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  // TEMPORARY: Test method for debugging recognition dialog
  void _testRecognitionDialog() {
    final testResults = [
      FoodRecognitionResult(
        foodItem: FoodItem(
          id: 'test_1',
          name: 'Pav Bhaji',
          calories: 523.0,
          protein: 14.0,
          carbs: 91.0,
          fat: 14.0,
          fiber: 11.0,
          servingSize: '1 plate',
          brand: 'Homemade',
          category: 'Indian Main Course',
          saturatedFat: 3.0,
          polyunsaturatedFat: 2.0,
          monounsaturatedFat: 4.0,
          transFat: 0.0,
          cholesterol: 0.0,
          sodium: 806.0,
          totalSugars: 8.0,
          addedSugar: 0.0,
          potassium: 860.0,
          calcium: 76.0,
          iron: 3.0,
          vitaminA: 500.0,
          vitaminC: 42.0,
          vitaminD: 0.0,
        ),
        confidence: 0.85,
        servingSize: '1 plate',
      ),
      FoodRecognitionResult(
        foodItem: FoodItem(
          id: 'test_2',
          name: 'Chicken Biryani',
          calories: 320.0,
          protein: 18.0,
          carbs: 45.0,
          fat: 8.0,
          fiber: 2.5,
          servingSize: '1 plate',
          brand: 'Homemade',
          category: 'Indian Main Course',
          saturatedFat: 2.8,
          polyunsaturatedFat: 1.5,
          monounsaturatedFat: 2.0,
          transFat: 0.0,
          cholesterol: 60.0,
          sodium: 520.0,
          totalSugars: 3.5,
          addedSugar: 0.0,
          potassium: 380.0,
          calcium: 65.0,
          iron: 2.2,
          vitaminA: 85.0,
          vitaminC: 12.0,
          vitaminD: 0.0,
        ),
        confidence: 0.72,
        servingSize: '1 plate',
      ),
    ];

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Food Recognition Results'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Debug info
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Test Mode: ${testResults.length} results found',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
                  const Text('Recognized foods:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppConstants.spacing12),
                  ...testResults.map((result) {
                    print('🎯 Test Result: ${result.foodItem.name} (${(result.confidence * 100).toInt()}%)');
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacing12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    result.foodItem.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.info_outline,
                                          color: AppColors.primary),
                                      onPressed: () =>
                                          _showFoodDetailsFromResult(result),
                                      tooltip: 'View Details',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle,
                                          color: AppColors.primary),
                                      onPressed: () {
                                        _addFoodItemFromResult(result);
                                        Navigator.pop(context);
                                      },
                                      tooltip: 'Add to Meal',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              'Confidence: ${(result.confidence * 100).toInt()}%',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacing8),
                            const Divider(),
                            const SizedBox(height: AppConstants.spacing8),
                            // Enhanced nutritional display
                            Wrap(
                              spacing: AppConstants.spacing8,
                              runSpacing: AppConstants.spacing4,
                              children: [
                                _buildNutritionChip(
                                    '${result.foodItem.calories.toInt()} cal',
                                    AppColors.proteinOrange),
                                _buildNutritionChip(
                                    '${result.foodItem.protein}g protein',
                                    AppColors.fiberGreen),
                                _buildNutritionChip(
                                    '${result.foodItem.carbs}g carbs',
                                    AppColors.waterBlue),
                                _buildNutritionChip(
                                    '${result.foodItem.fat}g fat',
                                    AppColors.activityRed),
                                if (result.foodItem.fiber > 0)
                                  _buildNutritionChip(
                                      '${result.foodItem.fiber}g fiber',
                                      AppColors.fiberGreen),
                                if (result.foodItem.sodium > 0)
                                  _buildNutritionChip(
                                      '${result.foodItem.sodium}mg sodium',
                                      AppColors.activityRed),
                                if (result.foodItem.saturatedFat > 0)
                                  _buildNutritionChip('${result.foodItem.saturatedFat}g sat fat',
                                      AppColors.activityRed),
                                if (result.foodItem.totalSugars > 0)
                                  _buildNutritionChip('${result.foodItem.totalSugars}g sugar',
                                      AppColors.waterBlue),
                                if (result.foodItem.cholesterol > 0)
                                  _buildNutritionChip('${result.foodItem.cholesterol}mg chol',
                                      AppColors.activityRed),
                                if (result.foodItem.potassium > 0)
                                  _buildNutritionChip(
                                      '${result.foodItem.potassium}mg K',
                                      AppColors.fiberGreen),
                                if (result.foodItem.calcium > 0)
                                  _buildNutritionChip(
                                      '${result.foodItem.calcium}mg Ca',
                                      AppColors.waterBlue),
                                if (result.foodItem.iron > 0)
                                  _buildNutritionChip(
                                      '${result.foodItem.iron}mg Fe',
                                      AppColors.proteinOrange),
                                if (result.foodItem.vitaminA > 0)
                                  _buildNutritionChip(
                                      '${result.foodItem.vitaminA}mcg A',
                                      AppColors.fiberGreen),
                                if (result.foodItem.vitaminC > 0)
                                  _buildNutritionChip(
                                      '${result.foodItem.vitaminC}mg C',
                                      AppColors.waterBlue),
                                if (result.foodItem.vitaminD > 0)
                                  _buildNutritionChip(
                                      '${result.foodItem.vitaminD}mcg D',
                                      AppColors.proteinOrange),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacing12),
                            Text(
                              'Serving Size: ${result.servingSize}',
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  // Simple test dialog
  void _simpleTestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simple Test'),
        content: const Text('This is a simple test dialog. If you can see this, the dialog system is working.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
