import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'food_database_service.dart';

class CalorieMamaFoodService {
  static const String _baseUrl = 'https://api-2445582032290.production.gw.apicast.io/v1';
  static const String _apiKey = 'demo_key'; // Using demo key for testing
  
  /// Recognize food from image using CalorieMama API
  static Future<List<FoodItem>> recognizeFoodFromImage(File imageFile) async {
    try {
      print('🔍 CalorieMama: Starting food recognition...');
      
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final url = Uri.parse('$_baseUrl/foodrecognition');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'user_key=$_apiKey',
        },
        body: jsonEncode({
          'image': base64Image,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ CalorieMama: Recognition successful');
        
        final List<FoodItem> foods = [];
        
        if (data['results'] != null && data['results'] is List) {
          final results = data['results'] as List;
          
          for (var result in results) {
            final foodItem = _convertToFoodItem(result);
            if (foodItem != null) {
              foods.add(foodItem);
            }
          }
        }
        
        return foods;
      } else {
        print('❌ CalorieMama API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ CalorieMama recognition error: $e');
      return [];
    }
  }
  
  /// Search for food items by name
  static Future<List<FoodItem>> searchFood(String query) async {
    try {
      print('🔍 CalorieMama: Searching for "$query"');
      
      // CalorieMama doesn't have a direct search API in the demo
      // For now, return empty list and let other APIs handle search
      print('ℹ️ CalorieMama: Search not available in demo version');
      return [];
      
    } catch (e) {
      print('❌ CalorieMama search error: $e');
      return [];
    }
  }
  
  /// Convert CalorieMama result to FoodItem
  static FoodItem? _convertToFoodItem(Map<String, dynamic> result) {
    try {
      final food = result['food'];
      if (food == null) return null;
      
      final nutrition = food['nutrition'] ?? {};
      
      return FoodItem(
        id: 'caloriemama_${food['food_id'] ?? DateTime.now().millisecondsSinceEpoch}',
        name: food['name'] ?? 'Unknown Food',
        barcode: null,
        calories: (nutrition['calories'] ?? 0).toDouble(),
        protein: (nutrition['protein'] ?? 0).toDouble(),
        carbs: (nutrition['carbs'] ?? 0).toDouble(),
        fat: (nutrition['fat'] ?? 0).toDouble(),
        fiber: (nutrition['fiber'] ?? 0).toDouble(),
        servingSize: food['serving_size'] ?? '100g',
        brand: 'Generic',
        category: food['category'] ?? 'Food',
        saturatedFat: (nutrition['saturated_fat'] ?? 0).toDouble(),
        polyunsaturatedFat: (nutrition['polyunsaturated_fat'] ?? 0).toDouble(),
        monounsaturatedFat: (nutrition['monounsaturated_fat'] ?? 0).toDouble(),
        transFat: (nutrition['trans_fat'] ?? 0).toDouble(),
        cholesterol: (nutrition['cholesterol'] ?? 0).toDouble(),
        sodium: (nutrition['sodium'] ?? 0).toDouble(),
        totalSugars: (nutrition['sugars'] ?? 0).toDouble(),
        addedSugar: (nutrition['added_sugars'] ?? 0).toDouble(),
        potassium: (nutrition['potassium'] ?? 0).toDouble(),
        calcium: (nutrition['calcium'] ?? 0).toDouble(),
        iron: (nutrition['iron'] ?? 0).toDouble(),
        vitaminA: (nutrition['vitamin_a'] ?? 0).toDouble(),
        vitaminC: (nutrition['vitamin_c'] ?? 0).toDouble(),
        vitaminD: (nutrition['vitamin_d'] ?? 0).toDouble(),
      );
    } catch (e) {
      print('❌ Error converting CalorieMama result: $e');
      return null;
    }
  }
}

