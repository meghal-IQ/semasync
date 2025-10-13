import 'dart:io';
import 'dart:math';
import 'food_database_service.dart';

/// Mock food API service for testing when real APIs are unavailable
/// This provides realistic nutritional data for common foods
class MockFoodApiService {
  static final Random _random = Random();
  
  /// Mock food database with realistic nutritional values per 100g
  static final Map<String, Map<String, dynamic>> _mockFoodDatabase = {
    // Indian Foods
    'pav bhaji': {
      'name': 'Pav Bhaji',
      'calories': 150.0,
      'protein': 4.5,
      'carbs': 20.0,
      'fat': 6.0,
      'fiber': 3.2,
      'category': 'Indian Street Food',
      'saturatedFat': 2.1,
      'sodium': 450.0,
      'potassium': 280.0,
      'calcium': 45.0,
      'iron': 1.8,
      'vitaminA': 120.0,
      'vitaminC': 25.0,
      'totalSugars': 4.5,
    },
    'bread': {
      'name': 'Bread (White)',
      'calories': 265.0,
      'protein': 9.0,
      'carbs': 49.0,
      'fat': 3.2,
      'fiber': 2.7,
      'category': 'Bakery',
      'saturatedFat': 0.8,
      'sodium': 491.0,
      'potassium': 115.0,
      'calcium': 149.0,
      'iron': 3.6,
      'vitaminA': 0.0,
      'vitaminC': 0.0,
      'totalSugars': 5.0,
    },
    'rice': {
      'name': 'Cooked White Rice',
      'calories': 130.0,
      'protein': 2.7,
      'carbs': 28.0,
      'fat': 0.3,
      'fiber': 0.4,
      'category': 'Grains',
      'saturatedFat': 0.1,
      'sodium': 1.0,
      'potassium': 35.0,
      'calcium': 10.0,
      'iron': 0.2,
      'vitaminA': 0.0,
      'vitaminC': 0.0,
      'totalSugars': 0.1,
    },
    'chicken': {
      'name': 'Chicken Breast (Cooked)',
      'calories': 165.0,
      'protein': 31.0,
      'carbs': 0.0,
      'fat': 3.6,
      'fiber': 0.0,
      'category': 'Meat',
      'saturatedFat': 1.0,
      'sodium': 74.0,
      'potassium': 256.0,
      'calcium': 15.0,
      'iron': 0.9,
      'vitaminA': 21.0,
      'vitaminC': 0.0,
      'totalSugars': 0.0,
    },
    'apple': {
      'name': 'Apple (with skin)',
      'calories': 52.0,
      'protein': 0.3,
      'carbs': 14.0,
      'fat': 0.2,
      'fiber': 2.4,
      'category': 'Fruits',
      'saturatedFat': 0.0,
      'sodium': 1.0,
      'potassium': 107.0,
      'calcium': 6.0,
      'iron': 0.1,
      'vitaminA': 3.0,
      'vitaminC': 4.6,
      'totalSugars': 10.4,
    },
    'banana': {
      'name': 'Banana',
      'calories': 89.0,
      'protein': 1.1,
      'carbs': 23.0,
      'fat': 0.3,
      'fiber': 2.6,
      'category': 'Fruits',
      'saturatedFat': 0.1,
      'sodium': 1.0,
      'potassium': 358.0,
      'calcium': 5.0,
      'iron': 0.3,
      'vitaminA': 3.0,
      'vitaminC': 8.7,
      'totalSugars': 12.2,
    },
    'pizza': {
      'name': 'Pizza (Margherita)',
      'calories': 266.0,
      'protein': 11.0,
      'carbs': 33.0,
      'fat': 10.0,
      'fiber': 2.3,
      'category': 'Fast Food',
      'saturatedFat': 4.9,
      'sodium': 598.0,
      'potassium': 172.0,
      'calcium': 144.0,
      'iron': 2.5,
      'vitaminA': 84.0,
      'vitaminC': 2.0,
      'totalSugars': 3.8,
    },
    'pasta': {
      'name': 'Cooked Pasta',
      'calories': 131.0,
      'protein': 5.0,
      'carbs': 25.0,
      'fat': 1.1,
      'fiber': 1.8,
      'category': 'Grains',
      'saturatedFat': 0.2,
      'sodium': 1.0,
      'potassium': 44.0,
      'calcium': 7.0,
      'iron': 0.9,
      'vitaminA': 0.0,
      'vitaminC': 0.0,
      'totalSugars': 0.8,
    },
    'salad': {
      'name': 'Mixed Green Salad',
      'calories': 20.0,
      'protein': 1.4,
      'carbs': 3.6,
      'fat': 0.2,
      'fiber': 1.8,
      'category': 'Vegetables',
      'saturatedFat': 0.0,
      'sodium': 10.0,
      'potassium': 194.0,
      'calcium': 36.0,
      'iron': 0.9,
      'vitaminA': 148.0,
      'vitaminC': 9.2,
      'totalSugars': 2.3,
    },
    'sandwich': {
      'name': 'Sandwich (Turkey & Cheese)',
      'calories': 250.0,
      'protein': 15.0,
      'carbs': 28.0,
      'fat': 9.0,
      'fiber': 3.0,
      'category': 'Fast Food',
      'saturatedFat': 3.2,
      'sodium': 680.0,
      'potassium': 220.0,
      'calcium': 120.0,
      'iron': 2.1,
      'vitaminA': 45.0,
      'vitaminC': 2.5,
      'totalSugars': 4.2,
    },
    // More Indian Foods
    'biryani': {
      'name': 'Chicken Biryani',
      'calories': 320.0,
      'protein': 18.0,
      'carbs': 45.0,
      'fat': 8.0,
      'fiber': 2.5,
      'category': 'Indian Main Course',
      'saturatedFat': 2.8,
      'sodium': 520.0,
      'potassium': 380.0,
      'calcium': 65.0,
      'iron': 2.2,
      'vitaminA': 85.0,
      'vitaminC': 12.0,
      'totalSugars': 3.5,
    },
    'dal': {
      'name': 'Dal (Lentil Curry)',
      'calories': 120.0,
      'protein': 8.0,
      'carbs': 18.0,
      'fat': 2.5,
      'fiber': 6.0,
      'category': 'Indian Curry',
      'saturatedFat': 0.8,
      'sodium': 380.0,
      'potassium': 450.0,
      'calcium': 35.0,
      'iron': 3.2,
      'vitaminA': 25.0,
      'vitaminC': 8.0,
      'totalSugars': 2.8,
    },
    'samosa': {
      'name': 'Samosa (Fried Pastry)',
      'calories': 280.0,
      'protein': 6.0,
      'carbs': 32.0,
      'fat': 14.0,
      'fiber': 3.5,
      'category': 'Indian Snack',
      'saturatedFat': 4.2,
      'sodium': 450.0,
      'potassium': 180.0,
      'calcium': 25.0,
      'iron': 1.8,
      'vitaminA': 15.0,
      'vitaminC': 5.0,
      'totalSugars': 2.5,
    },
    'curry': {
      'name': 'Vegetable Curry',
      'calories': 95.0,
      'protein': 4.0,
      'carbs': 12.0,
      'fat': 3.5,
      'fiber': 4.0,
      'category': 'Indian Curry',
      'saturatedFat': 1.2,
      'sodium': 420.0,
      'potassium': 320.0,
      'calcium': 45.0,
      'iron': 1.5,
      'vitaminA': 180.0,
      'vitaminC': 35.0,
      'totalSugars': 4.2,
    },
    'naan': {
      'name': 'Naan Bread',
      'calories': 310.0,
      'protein': 8.0,
      'carbs': 50.0,
      'fat': 8.0,
      'fiber': 2.0,
      'category': 'Indian Bread',
      'saturatedFat': 2.5,
      'sodium': 380.0,
      'potassium': 120.0,
      'calcium': 85.0,
      'iron': 2.8,
      'vitaminA': 0.0,
      'vitaminC': 0.0,
      'totalSugars': 3.5,
    },
  };
  
  /// Search for food items by query
  static Future<List<FoodItem>> searchFood(String query) async {
    try {
      print('🔍 MockAPI: Searching for "$query"');
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final queryLower = query.toLowerCase();
      final List<FoodItem> results = [];
      
      // Find exact matches first
      for (final entry in _mockFoodDatabase.entries) {
        if (entry.key.contains(queryLower) || queryLower.contains(entry.key)) {
          final foodItem = _createFoodItemFromData(entry.key, entry.value);
          results.add(foodItem);
        }
      }
      
      // If no exact matches, find partial matches
      if (results.isEmpty) {
        for (final entry in _mockFoodDatabase.entries) {
          final words = queryLower.split(' ');
          final keyWords = entry.key.split(' ');
          
          bool hasMatch = false;
          for (final word in words) {
            if (word.length > 2) { // Only consider words longer than 2 characters
              for (final keyWord in keyWords) {
                if (keyWord.contains(word) || word.contains(keyWord)) {
                  hasMatch = true;
                  break;
                }
              }
            }
          }
          
          if (hasMatch) {
            final foodItem = _createFoodItemFromData(entry.key, entry.value);
            results.add(foodItem);
          }
        }
      }
      
      // If still no matches, return diverse foods based on query context
      if (results.isEmpty) {
        print('ℹ️ MockAPI: No specific matches, returning contextual foods');
        
        // Return different foods based on query context
        List<String> contextualKeys = [];
        
        if (queryLower.contains('fast') || queryLower.contains('food')) {
          contextualKeys = ['pizza', 'sandwich', 'pav bhaji', 'samosa'];
        } else if (queryLower.contains('cuisine') || queryLower.contains('dish')) {
          contextualKeys = ['pav bhaji', 'biryani', 'dal', 'curry'];
        } else if (queryLower.contains('bread') || queryLower.contains('bakery')) {
          contextualKeys = ['bread', 'naan', 'sandwich', 'pizza'];
        } else if (queryLower.contains('pizza')) {
          contextualKeys = ['pizza', 'sandwich', 'pav bhaji'];
        } else if (queryLower.contains('rice') || queryLower.contains('grain')) {
          contextualKeys = ['rice', 'biryani', 'pav bhaji', 'dal'];
        } else if (queryLower.contains('chicken') || queryLower.contains('meat')) {
          contextualKeys = ['chicken', 'biryani', 'pizza', 'sandwich'];
        } else if (queryLower.contains('vegetable') || queryLower.contains('veg')) {
          contextualKeys = ['curry', 'dal', 'pav bhaji', 'samosa'];
        } else if (queryLower.contains('indian') || queryLower.contains('spicy')) {
          contextualKeys = ['pav bhaji', 'biryani', 'dal', 'curry', 'samosa', 'naan'];
        } else {
          // Default diverse selection with Indian foods
          contextualKeys = ['pav bhaji', 'biryani', 'chicken', 'rice', 'dal'];
        }
        
        for (final key in contextualKeys) {
          if (_mockFoodDatabase.containsKey(key)) {
            final foodItem = _createFoodItemFromData(key, _mockFoodDatabase[key]!);
            results.add(foodItem);
          }
        }
      }
      
      // Limit to 3 results for better accuracy
      final limitedResults = results.take(3).toList();
      
      print('✅ MockAPI: Found ${limitedResults.length} results for "$query"');
      return limitedResults;
      
    } catch (e) {
      print('❌ MockAPI search error: $e');
      return [];
    }
  }
  
  /// Recognize food from image (mock implementation)
  static Future<List<FoodItem>> recognizeFoodFromImage(File imageFile) async {
    try {
      print('🔍 MockAPI: Analyzing food image...');
      
      // Simulate image processing delay
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Return some random foods from our database
      final keys = _mockFoodDatabase.keys.toList();
      keys.shuffle(_random);
      
      final List<FoodItem> results = [];
      final numResults = _random.nextInt(3) + 1; // 1-3 results
      
      for (int i = 0; i < numResults && i < keys.length; i++) {
        final key = keys[i];
        final data = _mockFoodDatabase[key]!;
        final foodItem = _createFoodItemFromData(key, data);
        results.add(foodItem);
      }
      
      print('✅ MockAPI: Recognized ${results.length} food items from image');
      return results;
      
    } catch (e) {
      print('❌ MockAPI image recognition error: $e');
      return [];
    }
  }
  
  /// Create FoodItem from mock data
  static FoodItem _createFoodItemFromData(String key, Map<String, dynamic> data) {
    return FoodItem(
      id: 'mock_${key.replaceAll(' ', '_')}',
      name: data['name'] ?? key,
      barcode: null,
      calories: (data['calories'] ?? 0).toDouble(),
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fat: (data['fat'] ?? 0).toDouble(),
      fiber: (data['fiber'] ?? 0).toDouble(),
      servingSize: '100g',
      brand: 'Generic',
      category: data['category'] ?? 'Food',
      saturatedFat: (data['saturatedFat'] ?? 0).toDouble(),
      polyunsaturatedFat: (data['polyunsaturatedFat'] ?? 0).toDouble(),
      monounsaturatedFat: (data['monounsaturatedFat'] ?? 0).toDouble(),
      transFat: (data['transFat'] ?? 0).toDouble(),
      cholesterol: (data['cholesterol'] ?? 0).toDouble(),
      sodium: (data['sodium'] ?? 0).toDouble(),
      totalSugars: (data['totalSugars'] ?? 0).toDouble(),
      addedSugar: (data['addedSugar'] ?? 0).toDouble(),
      potassium: (data['potassium'] ?? 0).toDouble(),
      calcium: (data['calcium'] ?? 0).toDouble(),
      iron: (data['iron'] ?? 0).toDouble(),
      vitaminA: (data['vitaminA'] ?? 0).toDouble(),
      vitaminC: (data['vitaminC'] ?? 0).toDouble(),
      vitaminD: (data['vitaminD'] ?? 0).toDouble(),
    );
  }
}
