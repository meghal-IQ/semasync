import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/barcode_scanner_service.dart';
import '../../../../core/services/food_database_service.dart';
import '../../../../core/services/food_recognition_service.dart';
import '../../../logging/presentation/screens/meal_logging_screen.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  const Text(
                    'Scan Food Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Text(
                    'Use barcode scanning or take a photo to identify food items and automatically log nutrition information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.spacing24),
            
            // Scanning Options
            Expanded(
              child: Column(
                children: [
                  // Barcode Scanner Option
                  _buildScanOption(
                    icon: Icons.qr_code_scanner,
                    title: 'Scan Barcode',
                    subtitle: 'Scan product barcodes for instant nutrition data',
                    color: AppColors.primary,
                    onTap: _scanBarcode,
                  ),
                  
                  const SizedBox(height: AppConstants.spacing16),
                  
                  // Food Recognition Option
                  _buildScanOption(
                    icon: Icons.camera_alt,
                    title: 'Take Photo',
                    subtitle: 'Take a photo of your food for AI recognition',
                    color: AppColors.secondary,
                    onTap: _captureFoodImage,
                  ),
                  
                  const SizedBox(height: AppConstants.spacing16),
                  
                  // Manual Entry Option
                  _buildScanOption(
                    icon: Icons.search,
                    title: 'Search Food',
                    subtitle: 'Manually search and add food items',
                    color: AppColors.accent,
                    onTap: _openManualSearch,
                  ),
                  
                  const SizedBox(height: AppConstants.spacing16),
                  
                  // Test Button
                  _buildScanOption(
                    icon: Icons.bug_report,
                    title: 'Test Recognition Modal',
                    subtitle: 'Test the recognition results modal with sample data',
                    color: Colors.orange,
                    onTap: _testRecognitionModal,
                  ),
                ],
              ),
            ),
            
            // Error Message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacing12),
                margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: AppConstants.spacing8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: AppColors.error, fontSize: 14),
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

  Widget _buildScanOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final barcode = await BarcodeScannerService.scanBarcode(context);
      
      if (barcode != null) {
        final foodItem = await FoodDatabaseService.getFoodByBarcode(barcode);
        
        if (foodItem != null) {
          _navigateToMealLogging(foodItem);
        } else {
          setState(() {
            _errorMessage = 'Food not found in database. Try manual search instead.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to scan barcode. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _captureFoodImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📸 Starting image capture...');
      final image = await FoodRecognitionService.captureFoodImage();
      
      if (image != null) {
        print('📸 Image captured successfully: ${image.path}');
        print('🔍 Starting food recognition...');
        final results = await FoodRecognitionService.recognizeFoodFromImage(image);
        
        print('🔍 Recognition results: ${results.length} items found');
        if (results.isNotEmpty) {
          print('✅ Showing recognition results modal');
          _showRecognitionResults(results);
        } else {
          print('❌ No recognition results');
          setState(() {
            _errorMessage = 'Could not identify food in the image. Try manual search instead.';
          });
        }
      } else {
        print('❌ No image captured');
        setState(() {
          _errorMessage = 'No image was captured. Please try again.';
        });
      }
    } catch (e) {
      print('❌ Error in _captureFoodImage: $e');
      setState(() {
        _errorMessage = 'Failed to capture image. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openManualSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MealLoggingScreen(),
      ),
    );
  }

  void _navigateToMealLogging(FoodItem foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealLoggingScreen(
          preselectedFood: foodItem,
        ),
      ),
    );
  }

  void _testRecognitionModal() {
    // Create test results
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

    print('🧪 Testing recognition modal with ${testResults.length} test results');
    _showRecognitionResults(testResults);
  }

  void _showRecognitionResults(List<FoodRecognitionResult> results) {
    print('🎯 _showRecognitionResults: Showing modal with ${results.length} results');
    print('🎯 Results list type: ${results.runtimeType}');
    print('🎯 Results isEmpty: ${results.isEmpty}');
    
    for (int i = 0; i < results.length; i++) {
      print('🎯 Result $i: ${results[i].foodItem.name} (${(results[i].confidence * 100).toInt()}%)');
      print('🎯 Result $i foodItem: ${results[i].foodItem.runtimeType}');
      print('🎯 Result $i confidence: ${results[i].confidence}');
    }
    
    // TEMPORARY: Force test results if empty for debugging
    if (results.isEmpty) {
      print('🔧 Adding test results for debugging...');
      results = [
        FoodRecognitionResult(
          foodItem: FoodItem(
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
            saturatedFat: 5.0, polyunsaturatedFat: 2.0, monounsaturatedFat: 1.0, transFat: 0.0, cholesterol: 20.0, sodium: 300.0, totalSugars: 10.0, addedSugar: 5.0, potassium: 150.0, calcium: 50.0, iron: 2.0, vitaminA: 100.0, vitaminC: 15.0, vitaminD: 0.0,
          ),
          confidence: 0.85,
          servingSize: '1 serving',
        ),
      ];
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Food Recognition Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Debug info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                'Found ${results.length} food items',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results
            Expanded(
              child: results.isEmpty 
                ? const Center(
                    child: Text(
                      'No food items detected',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      print('🎯 ListView.builder called for index $index of ${results.length}');
                      print('🎯 Building result item $index: ${results[index].foodItem.name}');
                      final result = results[index];
                      return Column(
                        children: [
                          // Debug counter
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Text(
                              'Item ${index + 1} of ${results.length}: ${result.foodItem.name}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          _buildRecognitionResult(result),
                          const SizedBox(height: 16), // Add spacing between items
                        ],
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecognitionResult(FoodRecognitionResult result) {
    print('🎯 _buildRecognitionResult: Building card for ${result.foodItem.name}');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            '${(result.confidence * 100).toInt()}%',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          result.foodItem.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${result.foodItem.calories.toInt()} cal • ${result.foodItem.protein.toInt()}g protein'),
            if (result.servingSize != null)
              Text('Serving: ${result.servingSize}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            print('🎯 Add button pressed for ${result.foodItem.name}');
            Navigator.pop(context);
            _navigateToMealLogging(result.foodItem);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Add'),
        ),
      ),
    );
  }
}
