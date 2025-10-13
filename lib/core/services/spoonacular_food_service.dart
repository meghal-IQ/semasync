import 'dart:convert';
import 'package:http/http.dart' as http;
import 'food_database_service.dart';
import '../config/api_keys.dart';

class SpoonacularFoodService {
  static const String _baseUrl = 'https://api.spoonacular.com/food';
  static const String _apiKey = ApiKeys.spoonacular; // Free tier: 150 requests/day
  
  /// Check if API key is configured
  static bool get isConfigured => _apiKey != 'YOUR_SPOONACULAR_API_KEY_HERE';
  
  /// Search for food items using Spoonacular API
  static Future<List<FoodItem>> searchFood(String query) async {
    try {
      print('🔍 Spoonacular: Searching for "$query"');
      
      final url = Uri.parse('$_baseUrl/ingredients/search').replace(queryParameters: {
        'apiKey': _apiKey,
        'query': query,
        'number': '10',
        'metaInformation': 'true',
      });
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<FoodItem> foods = [];
        
        if (data['results'] != null && data['results'] is List) {
          final results = data['results'] as List;
          print('✅ Spoonacular: Found ${results.length} results');
          
          for (var result in results) {
            final foodItem = await _getIngredientNutrition(result['id'], result['name']);
            if (foodItem != null) {
              foods.add(foodItem);
            }
          }
        }
        
        return foods;
      } else {
        print('❌ Spoonacular API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Spoonacular search error: $e');
      return [];
    }
  }
  
  /// Get nutrition information for a specific ingredient
  static Future<FoodItem?> _getIngredientNutrition(int ingredientId, String name) async {
    try {
      print('🔍 Spoonacular: Getting nutrition for "$name" (ID: $ingredientId)');
      
      final url = Uri.parse('$_baseUrl/ingredients/$ingredientId/information').replace(queryParameters: {
        'apiKey': _apiKey,
        'amount': '100',
        'unit': 'grams',
      });
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Spoonacular: Got nutrition data for "$name"');
        return _convertToFoodItem(data);
      } else {
        print('❌ Spoonacular nutrition API error for "$name": ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Spoonacular nutrition error for "$name": $e');
      return null;
    }
  }
  
  /// Search for food using the food search endpoint (more comprehensive)
  static Future<List<FoodItem>> searchFoodProducts(String query) async {
    try {
      print('🔍 Spoonacular: Searching food products for "$query"');
      
      final url = Uri.parse('$_baseUrl/products/search').replace(queryParameters: {
        'apiKey': _apiKey,
        'query': query,
        'number': '10',
      });
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<FoodItem> foods = [];
        
        if (data['products'] != null && data['products'] is List) {
          final products = data['products'] as List;
          print('✅ Spoonacular: Found ${products.length} food products');
          
          for (var product in products.take(5)) { // Limit to 5 to avoid API rate limits
            final foodItem = await _getProductNutrition(product['id'], product['title']);
            if (foodItem != null) {
              foods.add(foodItem);
            }
          }
        }
        
        return foods;
      } else {
        print('❌ Spoonacular products API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Spoonacular products search error: $e');
      return [];
    }
  }
  
  /// Get nutrition information for a specific food product
  static Future<FoodItem?> _getProductNutrition(int productId, String name) async {
    try {
      print('🔍 Spoonacular: Getting product nutrition for "$name" (ID: $productId)');
      
      final url = Uri.parse('$_baseUrl/products/$productId').replace(queryParameters: {
        'apiKey': _apiKey,
      });
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Spoonacular: Got product nutrition data for "$name"');
        return _convertProductToFoodItem(data);
      } else {
        print('❌ Spoonacular product nutrition API error for "$name": ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Spoonacular product nutrition error for "$name": $e');
      return null;
    }
  }
  
  /// Convert Spoonacular ingredient data to FoodItem
  static FoodItem? _convertToFoodItem(Map<String, dynamic> data) {
    try {
      final nutrition = data['nutrition'];
      if (nutrition == null) return null;
      
      final nutrients = nutrition['nutrients'] as List? ?? [];
      final caloricBreakdown = nutrition['caloricBreakdown'] ?? {};
      
      // Extract nutrients by name
      final nutrientMap = <String, double>{};
      for (var nutrient in nutrients) {
        final name = nutrient['name']?.toString().toLowerCase() ?? '';
        final amount = (nutrient['amount'] ?? 0).toDouble();
        nutrientMap[name] = amount;
      }
      
      return FoodItem(
        id: 'spoonacular_${data['id']}',
        name: data['name'] ?? 'Unknown Food',
        barcode: null,
        calories: nutrientMap['calories'] ?? 0.0,
        protein: nutrientMap['protein'] ?? 0.0,
        carbs: nutrientMap['carbohydrates'] ?? 0.0,
        fat: nutrientMap['fat'] ?? 0.0,
        fiber: nutrientMap['fiber'] ?? 0.0,
        servingSize: '100g',
        brand: 'Generic',
        category: data['categoryPath']?.join(' > ') ?? 'Food',
        saturatedFat: nutrientMap['saturated fat'] ?? 0.0,
        polyunsaturatedFat: nutrientMap['poly unsaturated fat'] ?? 0.0,
        monounsaturatedFat: nutrientMap['mono unsaturated fat'] ?? 0.0,
        transFat: nutrientMap['trans fat'] ?? 0.0,
        cholesterol: nutrientMap['cholesterol'] ?? 0.0,
        sodium: nutrientMap['sodium'] ?? 0.0,
        totalSugars: nutrientMap['sugar'] ?? 0.0,
        addedSugar: 0.0, // Not commonly available
        potassium: nutrientMap['potassium'] ?? 0.0,
        calcium: nutrientMap['calcium'] ?? 0.0,
        iron: nutrientMap['iron'] ?? 0.0,
        vitaminA: nutrientMap['vitamin a'] ?? 0.0,
        vitaminC: nutrientMap['vitamin c'] ?? 0.0,
        vitaminD: nutrientMap['vitamin d'] ?? 0.0,
      );
    } catch (e) {
      print('❌ Error converting Spoonacular ingredient: $e');
      return null;
    }
  }
  
  /// Convert Spoonacular product data to FoodItem
  static FoodItem? _convertProductToFoodItem(Map<String, dynamic> data) {
    try {
      final nutrition = data['nutrition'];
      if (nutrition == null) return null;
      
      final nutrients = nutrition['nutrients'] as List? ?? [];
      
      // Extract nutrients by name
      final nutrientMap = <String, double>{};
      for (var nutrient in nutrients) {
        final name = nutrient['name']?.toString().toLowerCase() ?? '';
        final amount = (nutrient['amount'] ?? 0).toDouble();
        nutrientMap[name] = amount;
      }
      
      return FoodItem(
        id: 'spoonacular_product_${data['id']}',
        name: data['title'] ?? 'Unknown Food',
        barcode: data['upc'],
        calories: nutrientMap['calories'] ?? 0.0,
        protein: nutrientMap['protein'] ?? 0.0,
        carbs: nutrientMap['carbohydrates'] ?? 0.0,
        fat: nutrientMap['fat'] ?? 0.0,
        fiber: nutrientMap['fiber'] ?? 0.0,
        servingSize: '100g',
        brand: data['brand'] ?? 'Generic',
        category: data['breadcrumbs'] ?? 'Food',
        saturatedFat: nutrientMap['saturated fat'] ?? 0.0,
        polyunsaturatedFat: nutrientMap['poly unsaturated fat'] ?? 0.0,
        monounsaturatedFat: nutrientMap['mono unsaturated fat'] ?? 0.0,
        transFat: nutrientMap['trans fat'] ?? 0.0,
        cholesterol: nutrientMap['cholesterol'] ?? 0.0,
        sodium: nutrientMap['sodium'] ?? 0.0,
        totalSugars: nutrientMap['sugar'] ?? 0.0,
        addedSugar: 0.0, // Not commonly available
        potassium: nutrientMap['potassium'] ?? 0.0,
        calcium: nutrientMap['calcium'] ?? 0.0,
        iron: nutrientMap['iron'] ?? 0.0,
        vitaminA: nutrientMap['vitamin a'] ?? 0.0,
        vitaminC: nutrientMap['vitamin c'] ?? 0.0,
        vitaminD: nutrientMap['vitamin d'] ?? 0.0,
      );
    } catch (e) {
      print('❌ Error converting Spoonacular product: $e');
      return null;
    }
  }
}
