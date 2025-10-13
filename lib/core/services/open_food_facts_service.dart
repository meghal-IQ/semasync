import 'dart:convert';
import 'package:http/http.dart' as http;

import 'food_database_service.dart';

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const String _userAgent = 'SemaSync - Flutter - Version 1.0.0';

  /// Search for food by name
  static Future<Map<String, dynamic>?> searchFood(String query) async {
    try {
      print('🔍 OpenFoodFacts: Searching for "$query"');
      
      // Skip generic terms that won't return useful results
      if (['food', 'cuisine', 'dish', 'meal'].contains(query.toLowerCase())) {
        print('⚠️ Skipping generic search term: $query');
        return null;
      }
      
      final url = Uri.parse('$_baseUrl/search?search_terms=${Uri.encodeComponent(query)}&fields=product_name,nutriments,serving_size,ingredients_text,categories_tags,brands,code&page_size=5&sort_by=popularity');
      
      final response = await http.get(
        url,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ OpenFoodFacts: Found ${data['count']} results');
        return data;
      } else {
        print('❌ OpenFoodFacts API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ OpenFoodFacts error: $e');
      return null;
    }
  }

  /// Get food details by barcode
  static Future<Map<String, dynamic>?> getFoodByBarcode(String barcode) async {
    try {
      print('🔍 OpenFoodFacts: Looking up barcode "$barcode"');
      
      final url = Uri.parse('$_baseUrl/product/$barcode');
      
      final response = await http.get(
        url,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ OpenFoodFacts: Found product details');
        return data;
      } else {
        print('❌ OpenFoodFacts API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ OpenFoodFacts error: $e');
      return null;
    }
  }

  /// Convert OpenFoodFacts data to FoodItem
  static FoodItem? convertToFoodItem(Map<String, dynamic> data) {
    try {
      // Handle search results (products array)
      if (data.containsKey('products') && data['products'] is List) {
        final products = data['products'] as List;
        print('🔍 OpenFoodFacts: Found ${products.length} products, checking first few...');
        
        // Try the first few products to find one with nutriments
        for (int i = 0; i < 5 && i < products.length; i++) {
          final product = products[i] as Map<String, dynamic>;
          print('🔍 OpenFoodFacts: Checking product $i: ${product['product_name']}');
          
          if (product.containsKey('nutriments') && product['nutriments'] != null) {
            print('✅ OpenFoodFacts: Found product with nutriments at index $i');
            return _convertProductToFoodItem(product);
          }
        }
        
        print('❌ OpenFoodFacts: No products with nutriments found in first 5 results');
      }
      
      // Handle single product result
      if (data.containsKey('product')) {
        final product = data['product'] as Map<String, dynamic>;
        return _convertProductToFoodItem(product);
      }

      print('❌ No valid product data found in OpenFoodFacts response');
      return null;
    } catch (e) {
      print('❌ Error converting OpenFoodFacts data: $e');
      return null;
    }
  }

  /// Convert a single product to FoodItem
  static FoodItem? _convertProductToFoodItem(Map<String, dynamic> product) {
    try {
      // Check if we have nutriments
      if (!product.containsKey('nutriments')) {
        print('❌ No nutriments field in product data');
        return null;
      }

      final nutriments = product['nutriments'];
      if (nutriments == null) {
        print('❌ Nutriments is null in product data');
        return null;
      }

      // Get category from categories_tags or categories
      String category = 'Unknown';
      if (product['categories_tags'] != null && (product['categories_tags'] as List).isNotEmpty) {
        category = (product['categories_tags'] as List).first;
      } else if (product['categories'] != null) {
        category = product['categories'];
      }

      return FoodItem(
        id: product['_id'] ?? product['code'] ?? '',
        name: product['product_name'] ?? 'Unknown Food',
        barcode: product['code'],
        calories: (nutriments['energy-kcal_100g'] ?? 0).toDouble(),
        protein: (nutriments['proteins_100g'] ?? 0).toDouble(),
        carbs: (nutriments['carbohydrates_100g'] ?? 0).toDouble(),
        fat: (nutriments['fat_100g'] ?? 0).toDouble(),
        fiber: (nutriments['fiber_100g'] ?? 0).toDouble(),
        servingSize: product['serving_size'] ?? '100g',
        brand: product['brands'],
        category: category,
        saturatedFat: (nutriments['saturated-fat_100g'] ?? 0).toDouble(),
        polyunsaturatedFat: (nutriments['polyunsaturated-fat_100g'] ?? 0).toDouble(),
        monounsaturatedFat: (nutriments['monounsaturated-fat_100g'] ?? 0).toDouble(),
        transFat: (nutriments['trans-fat_100g'] ?? 0).toDouble(),
        cholesterol: (nutriments['cholesterol_100g'] ?? 0).toDouble(),
        sodium: (nutriments['sodium_100g'] ?? 0).toDouble(),
        totalSugars: (nutriments['sugars_100g'] ?? 0).toDouble(),
        addedSugar: (nutriments['added-sugars_100g'] ?? 0).toDouble(),
        potassium: (nutriments['potassium_100g'] ?? 0).toDouble(),
        calcium: (nutriments['calcium_100g'] ?? 0).toDouble(),
        iron: (nutriments['iron_100g'] ?? 0).toDouble(),
        vitaminA: (nutriments['vitamin-a_100g'] ?? 0).toDouble(),
        vitaminC: (nutriments['vitamin-c_100g'] ?? 0).toDouble(),
        vitaminD: (nutriments['vitamin-d_100g'] ?? 0).toDouble(),
      );
    } catch (e) {
      print('❌ Error converting product to FoodItem: $e');
      return null;
    }
  }
}
