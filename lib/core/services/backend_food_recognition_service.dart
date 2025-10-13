import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'food_database_service.dart';
import 'food_recognition_service.dart';

class BackendFoodRecognitionService {
  // Backend API configuration
//   static const String _baseUrl = 'http://localhost:3000/api/food-recognition';
  // For mobile devices, use your computer's IP address
  static const String _baseUrl = 'http://192.168.1.36:3000/api/food-recognition';
  
  /// Recognize food items from image URL using backend API
  static Future<List<FoodRecognitionResult>> recognizeFoodFromImageUrl(String imageUrl) async {
    try {
      print('🌐 Backend: Starting food recognition from URL...');
      print('🌐 Backend: Image URL: $imageUrl');

      final response = await http.post(
        Uri.parse('$_baseUrl/recognize'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'imageUrl': imageUrl,
        }),
      );

      print('🌐 Backend: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final concepts = data['data']['concepts'] as List;
          print('✅ Backend: Found ${concepts.length} food concepts');
          
          return _convertConceptsToResults(concepts);
        } else {
          print('❌ Backend: API returned error: ${data['error']}');
          return [];
        }
      } else {
        print('❌ Backend: HTTP error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Backend: Error calling food recognition API: $e');
      return [];
    }
  }

  /// Recognize food items from base64 image data using backend API
  static Future<List<FoodRecognitionResult>> recognizeFoodFromBase64(String base64Image) async {
    try {
      print('🌐 Backend: Starting food recognition from base64...');

      final response = await http.post(
        Uri.parse('$_baseUrl/recognize-base64'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'imageData': base64Image,
        }),
      );

      print('🌐 Backend: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final concepts = data['data']['concepts'] as List;
          print('✅ Backend: Found ${concepts.length} food concepts');
          
          return _convertConceptsToResults(concepts);
        } else {
          print('❌ Backend: API returned error: ${data['error']}');
          return [];
        }
      } else {
        print('❌ Backend: HTTP error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Backend: Error calling food recognition API: $e');
      return [];
    }
  }

  /// Test the backend food recognition service
  static Future<void> testBackendService() async {
    try {
      print('🧪 Testing backend food recognition service...');

      final response = await http.get(
        Uri.parse('$_baseUrl/test'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🧪 Backend Test: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          print('✅ Backend Test: Service is working!');
          print('📊 Backend Test: ${data['data']['totalConcepts']} total concepts found');
          print('🍽️ Backend Test: Sample concepts:');
          
          final sampleConcepts = data['data']['sampleConcepts'] as List;
          for (var concept in sampleConcepts) {
            print('  - ${concept['name']}: ${(concept['confidence'] * 100).toStringAsFixed(1)}%');
          }
        } else {
          print('❌ Backend Test: Service error: ${data['error']}');
        }
      } else {
        print('❌ Backend Test: HTTP error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Backend Test: Error: $e');
    }
  }

  /// Convert Clarifai concepts to FoodRecognitionResult objects
  static List<FoodRecognitionResult> _convertConceptsToResults(List<dynamic> concepts) {
    final List<FoodRecognitionResult> results = [];

    for (var concept in concepts) {
      final name = concept['name'] as String;
      final confidence = (concept['confidence'] as num).toDouble();

      // Find matching food item in local database
      final foodItem = _findMatchingFoodItem(name);
      if (foodItem != null) {
        results.add(FoodRecognitionResult(
          foodItem: foodItem,
          confidence: confidence,
          servingSize: _getSuggestedServingSize(foodItem),
        ));
        
        print('✅ Backend: Added food item - $name (${(confidence * 100).toStringAsFixed(1)}%)');
      }
    }

    // Sort by confidence and limit to top 5
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results.take(5).toList();
  }

  /// Find matching food item in local database
  static FoodItem? _findMatchingFoodItem(String conceptName) {
    // This is a simplified matching - in a real app, you'd have a more sophisticated matching algorithm
    final conceptLower = conceptName.toLowerCase();
    
    // Map specific food concepts to food items
    if (conceptLower == 'corn') {
      return _createFoodItem(
        'Corn (Sweet)',
        86.0, 3.2, 19.0, 1.2, 2.7,
        '1 ear', 'Generic', 'Vegetable',
        0.2, 0.3, 0.3, 0, 0, 15.0, 6.3, 0, 0, 270.0, 0.5, 0.1, 0, 0
      );
    } else if (conceptLower == 'olive') {
      return _createFoodItem(
        'Olives (Black)',
        115.0, 0.8, 6.0, 10.7, 3.2,
        '10 olives', 'Generic', 'Vegetable',
        1.4, 0.8, 7.7, 0, 0, 735.0, 0.0, 0, 0, 8.0, 0.5, 0.0, 0, 0
      );
    } else if (conceptLower == 'cake') {
      return _createFoodItem(
        'Cake (Chocolate)',
        371.0, 4.9, 51.0, 16.0, 2.3,
        '1 slice', 'Generic', 'Dessert',
        4.9, 0.8, 9.8, 0, 58.0, 339.0, 40.0, 0, 0, 200.0, 2.0, 0.1, 0, 0
      );
    } else if (conceptLower == 'cookie') {
      return _createFoodItem(
        'Cookie (Chocolate Chip)',
        488.0, 5.9, 68.0, 22.0, 2.4,
        '1 cookie', 'Generic', 'Dessert',
        10.0, 0.0, 0.0, 0, 0, 386.0, 31.0, 0, 0, 100.0, 1.0, 0.1, 0, 0
      );
    } else if (conceptLower == 'pastry') {
      return _createFoodItem(
        'Pastry (Croissant)',
        406.0, 8.2, 45.0, 21.0, 2.6,
        '1 croissant', 'Generic', 'Bakery',
        12.0, 0.0, 0.0, 0, 0, 400.0, 11.0, 0, 0, 100.0, 1.0, 0.1, 0, 0
      );
    } else if (conceptLower == 'cheese') {
      return _createFoodItem(
        'Cheese (Cheddar)',
        403.0, 25.0, 1.3, 33.0, 0.0,
        '1 oz', 'Generic', 'Dairy',
        21.0, 0.0, 0.0, 0, 105.0, 621.0, 0.5, 0, 0, 200.0, 0.2, 0.0, 0, 0
      );
    } else if (conceptLower == 'chocolate') {
      return _createFoodItem(
        'Chocolate (Dark)',
        546.0, 7.8, 45.9, 31.3, 10.9,
        '1 oz', 'Generic', 'Dessert',
        18.5, 0.0, 0.0, 0, 0, 6.0, 24.2, 0, 0, 200.0, 3.4, 0.0, 0, 0
      );
    } else if (conceptLower == 'bread') {
      return _createFoodItem(
        'Bread (White)',
        265.0, 9.0, 49.0, 3.2, 2.7,
        '100g', 'Generic', 'Bakery',
        0.7, 1.3, 0.6, 0, 0, 494.0, 5.5, 3.0, 0, 100.0, 100.0, 3.6, 0, 0
      );
    } else if (conceptLower == 'rice') {
      return _createFoodItem(
        'Rice (White, Cooked)',
        130.0, 2.7, 28.0, 0.3, 0.4,
        '1 cup', 'Generic', 'Grain',
        0.1, 0.1, 0.1, 0, 0, 1.0, 0.1, 0, 0, 35.0, 0.8, 0.0, 0, 0
      );
    } else if (conceptLower == 'chicken') {
      return _createFoodItem(
        'Chicken Breast (Cooked)',
        165.0, 31.0, 0.0, 3.6, 0.0,
        '100g', 'Generic', 'Meat',
        1.0, 0.8, 1.1, 0, 85.0, 74.0, 0, 0, 0, 255.0, 11.0, 1.0, 0, 0
      );
    } else if (conceptLower == 'apple') {
      return _createFoodItem(
        'Apple (Red)',
        52.0, 0.3, 14.0, 0.2, 2.4,
        '1 medium', 'Generic', 'Fruit',
        0.0, 0.0, 0.0, 0, 0, 1.0, 10.4, 0, 0, 107.0, 0.1, 0.0, 0, 0
      );
    } else if (conceptLower == 'banana') {
      return _createFoodItem(
        'Banana',
        89.0, 1.1, 23.0, 0.3, 2.6,
        '1 medium', 'Generic', 'Fruit',
        0.1, 0.0, 0.0, 0, 0, 1.0, 12.2, 0, 0, 358.0, 0.3, 0.0, 0, 0
      );
    } else if (conceptLower == 'tomato') {
      return _createFoodItem(
        'Tomato',
        18.0, 0.9, 3.9, 0.2, 1.2,
        '1 medium', 'Generic', 'Vegetable',
        0.0, 0.0, 0.0, 0, 0, 5.0, 2.6, 0, 0, 237.0, 0.5, 0.0, 0, 0
      );
    } else if (conceptLower.contains('pizza')) {
      return _createFoodItem(
        'Pizza (Margherita)',
        266.0, 11.0, 33.0, 10.0, 2.5,
        '1 slice', 'Generic', 'Fast Food',
        4.5, 0, 0, 0, 0, 590.0, 0, 0, 0, 150.0, 180.0, 1.8, 148.0, 9.2
      );
    } else if (conceptLower.contains('burger') || conceptLower.contains('sandwich')) {
      return _createFoodItem(
        'Sandwich (Turkey & Cheese)',
        250.0, 15.0, 28.0, 9.0, 3.0,
        '1 sandwich', 'Generic', 'Fast Food',
        3.2, 2.0, 3.0, 0, 40.0, 680.0, 4.2, 1.0, 0, 220.0, 120.0, 2.1, 45.0, 2.5
      );
    } else if (conceptLower.contains('rice') || conceptLower.contains('biryani')) {
      return _createFoodItem(
        'Chicken Biryani',
        320.0, 18.0, 45.0, 8.0, 2.5,
        '1 plate', 'Homemade', 'Indian Main Course',
        2.8, 1.5, 2.0, 0, 60.0, 520.0, 3.5, 0, 0, 380.0, 65.0, 2.2, 85.0, 12.0
      );
    } else if (conceptLower.contains('chicken')) {
      return _createFoodItem(
        'Chicken Breast (Cooked)',
        165.0, 31.0, 0.0, 3.6, 0.0,
        '100g', 'Generic', 'Meat',
        1.0, 0.8, 1.1, 0, 85.0, 74.0, 0, 0, 0, 255.0, 11.0, 1.0, 0, 0
      );
    } else if (conceptLower.contains('bread')) {
      return _createFoodItem(
        'Bread (White)',
        265.0, 9.0, 49.0, 3.2, 2.7,
        '100g', 'Generic', 'Bakery',
        0.7, 1.3, 0.6, 0, 0, 494.0, 5.5, 3.0, 0, 100.0, 100.0, 3.6, 0, 0
      );
    } else if (conceptLower.contains('pasta') || conceptLower.contains('spaghetti')) {
      return _createFoodItem(
        'Pasta with Tomato Sauce',
        220.0, 8.0, 44.0, 2.0, 3.0,
        '1 cup', 'Generic', 'Italian',
        0.3, 0.2, 0.8, 0, 0, 400.0, 8.0, 0, 0, 200.0, 20.0, 1.5, 15.0, 5.0
      );
    } else if (conceptLower.contains('salad')) {
      return _createFoodItem(
        'Mixed Green Salad',
        25.0, 2.0, 5.0, 0.5, 2.0,
        '1 cup', 'Generic', 'Vegetables',
        0.1, 0.1, 0.2, 0, 0, 20.0, 3.0, 0, 0, 200.0, 30.0, 1.0, 60.0, 15.0
      );
    } else if (conceptLower.contains('soup')) {
      return _createFoodItem(
        'Vegetable Soup',
        50.0, 2.0, 8.0, 1.0, 2.0,
        '1 cup', 'Generic', 'Soup',
        0.2, 0.1, 0.3, 0, 0, 300.0, 4.0, 0, 0, 150.0, 20.0, 0.8, 25.0, 8.0
      );
    } else if (conceptLower.contains('fruit') || conceptLower.contains('apple')) {
      return _createFoodItem(
        'Apple',
        52.0, 0.3, 14.0, 0.2, 2.4,
        '1 medium', 'Generic', 'Fruit',
        0.1, 0.1, 0.0, 0, 0, 1.0, 10.4, 0, 0, 107.0, 6.0, 0.1, 4.6, 4.0
      );
    } else if (conceptLower.contains('vegetable') || conceptLower.contains('carrot')) {
      return _createFoodItem(
        'Carrot',
        41.0, 0.9, 10.0, 0.2, 2.8,
        '1 medium', 'Generic', 'Vegetables',
        0.0, 0.0, 0.1, 0, 0, 69.0, 4.7, 0, 0, 320.0, 33.0, 0.3, 835.0, 5.9
      );
    }
    
    // Generic fallback for other food items
    return _createFoodItem(
      'Generic Food Item',
      200.0, 10.0, 25.0, 8.0, 3.0,
      '1 serving', 'Generic', 'Mixed',
      2.0, 1.0, 2.0, 0, 30.0, 400.0, 5.0, 2.0, 0, 200.0, 50.0, 1.5, 50.0, 10.0
    );
  }

  /// Create a FoodItem with all nutritional data
  static FoodItem _createFoodItem(
    String name,
    double calories,
    double protein,
    double carbs,
    double fat,
    double fiber,
    String servingSize,
    String brand,
    String category,
    double saturatedFat,
    double polyunsaturatedFat,
    double monounsaturatedFat,
    double transFat,
    double cholesterol,
    double sodium,
    double totalSugars,
    double addedSugar,
    double potassium,
    double calcium,
    double iron,
    double vitaminA,
    double vitaminC,
    double vitaminD,
  ) {
    return FoodItem(
      id: 'backend_${name.toLowerCase().replaceAll(' ', '_')}',
      name: name,
      barcode: null,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      servingSize: servingSize,
      brand: brand,
      category: category,
      saturatedFat: saturatedFat,
      polyunsaturatedFat: polyunsaturatedFat,
      monounsaturatedFat: monounsaturatedFat,
      transFat: transFat,
      cholesterol: cholesterol,
      sodium: sodium,
      totalSugars: totalSugars,
      addedSugar: addedSugar,
      potassium: potassium,
      calcium: calcium,
      iron: iron,
      vitaminA: vitaminA,
      vitaminC: vitaminC,
      vitaminD: vitaminD,
    );
  }

  /// Get suggested serving size based on food type
  static String _getSuggestedServingSize(FoodItem food) {
    final servingSizes = {
      'Fast Food': '1 serving',
      'Indian Main Course': '1 plate',
      'Meat': '100g',
      'Bakery': '1 slice',
      'Italian': '1 cup',
      'Vegetables': '1 cup',
      'Soup': '1 cup',
      'Fruit': '1 medium',
      'Mixed': '1 serving',
    };
    
    return servingSizes[food.category] ?? '1 serving';
  }
}
