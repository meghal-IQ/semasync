import 'dart:convert';
import 'package:http/http.dart' as http;
import 'food_database_service.dart';

class EdamamFoodService {
  static const String _baseUrl = 'https://api.edamam.com/api/food-database/v2';
  static const String _appId = 'YOUR_EDAMAM_APP_ID'; // You'll need to get this from Edamam
  static const String _appKey = 'YOUR_EDAMAM_APP_KEY'; // You'll need to get this from Edamam
  
  /// Search for food items using Edamam Food Database API
  static Future<List<FoodItem>> searchFood(String query) async {
    try {
      print('🔍 Edamam: Searching for "$query"');
      
      final url = Uri.parse('$_baseUrl/parser').replace(queryParameters: {
        'app_id': _appId,
        'app_key': _appKey,
        'ingr': query,
        'nutrition-type': 'cooking',
      });
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<FoodItem> foods = [];
        
        if (data['hints'] != null && data['hints'] is List) {
          final hints = data['hints'] as List;
          print('✅ Edamam: Found ${hints.length} results');
          
          for (var hint in hints.take(10)) { // Take first 10 results
            final foodItem = _convertToFoodItem(hint);
            if (foodItem != null) {
              foods.add(foodItem);
            }
          }
        }
        
        return foods;
      } else {
        print('❌ Edamam API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Edamam search error: $e');
      return [];
    }
  }
  
  /// Get detailed nutritional information for a specific food
  static Future<FoodItem?> getFoodDetails(String foodId) async {
    try {
      print('🔍 Edamam: Getting details for food ID "$foodId"');
      
      final url = Uri.parse('$_baseUrl/nutrients').replace(queryParameters: {
        'app_id': _appId,
        'app_key': _appKey,
      });
      
      final requestBody = {
        'ingredients': [
          {
            'quantity': 100,
            'measureURI': 'http://www.edamam.com/ontologies/edamam.owl#Measure_gram',
            'foodId': foodId,
          }
        ]
      };
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Edamam: Got detailed nutritional data');
        return _convertNutritionToFoodItem(data, foodId);
      } else {
        print('❌ Edamam nutrition API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Edamam nutrition error: $e');
      return null;
    }
  }
  
  /// Convert Edamam search result to FoodItem
  static FoodItem? _convertToFoodItem(Map<String, dynamic> hint) {
    try {
      final food = hint['food'];
      if (food == null) return null;
      
      final nutrients = food['nutrients'] ?? {};
      
      return FoodItem(
        id: 'edamam_${food['foodId'] ?? ''}',
        name: food['label'] ?? 'Unknown Food',
        barcode: null,
        calories: (nutrients['ENERC_KCAL'] ?? 0).toDouble(),
        protein: (nutrients['PROCNT'] ?? 0).toDouble(),
        carbs: (nutrients['CHOCDF'] ?? 0).toDouble(),
        fat: (nutrients['FAT'] ?? 0).toDouble(),
        fiber: (nutrients['FIBTG'] ?? 0).toDouble(),
        servingSize: '100g',
        brand: food['brand'] ?? 'Generic',
        category: food['category'] ?? 'Food',
        saturatedFat: (nutrients['FASAT'] ?? 0).toDouble(),
        polyunsaturatedFat: (nutrients['FAPU'] ?? 0).toDouble(),
        monounsaturatedFat: (nutrients['FAMS'] ?? 0).toDouble(),
        transFat: (nutrients['FATRN'] ?? 0).toDouble(),
        cholesterol: (nutrients['CHOLE'] ?? 0).toDouble(),
        sodium: (nutrients['NA'] ?? 0).toDouble(),
        totalSugars: (nutrients['SUGAR'] ?? 0).toDouble(),
        addedSugar: (nutrients['SUGAR.added'] ?? 0).toDouble(),
        potassium: (nutrients['K'] ?? 0).toDouble(),
        calcium: (nutrients['CA'] ?? 0).toDouble(),
        iron: (nutrients['FE'] ?? 0).toDouble(),
        vitaminA: (nutrients['VITA_RAE'] ?? 0).toDouble(),
        vitaminC: (nutrients['VITC'] ?? 0).toDouble(),
        vitaminD: (nutrients['VITD'] ?? 0).toDouble(),
      );
    } catch (e) {
      print('❌ Error converting Edamam food item: $e');
      return null;
    }
  }
  
  /// Convert detailed nutrition response to FoodItem
  static FoodItem? _convertNutritionToFoodItem(Map<String, dynamic> data, String foodId) {
    try {
      final totalNutrients = data['totalNutrients'] ?? {};
      final ingredients = data['ingredients'] as List? ?? [];
      
      String name = 'Unknown Food';
      String brand = 'Generic';
      String category = 'Food';
      
      if (ingredients.isNotEmpty) {
        final ingredient = ingredients.first;
        name = ingredient['parsed']?[0]?['food'] ?? name;
        brand = ingredient['parsed']?[0]?['brand'] ?? brand;
        category = ingredient['parsed']?[0]?['category'] ?? category;
      }
      
      return FoodItem(
        id: 'edamam_$foodId',
        name: name,
        barcode: null,
        calories: _extractNutrientValue(totalNutrients['ENERC_KCAL']),
        protein: _extractNutrientValue(totalNutrients['PROCNT']),
        carbs: _extractNutrientValue(totalNutrients['CHOCDF']),
        fat: _extractNutrientValue(totalNutrients['FAT']),
        fiber: _extractNutrientValue(totalNutrients['FIBTG']),
        servingSize: '100g',
        brand: brand,
        category: category,
        saturatedFat: _extractNutrientValue(totalNutrients['FASAT']),
        polyunsaturatedFat: _extractNutrientValue(totalNutrients['FAPU']),
        monounsaturatedFat: _extractNutrientValue(totalNutrients['FAMS']),
        transFat: _extractNutrientValue(totalNutrients['FATRN']),
        cholesterol: _extractNutrientValue(totalNutrients['CHOLE']),
        sodium: _extractNutrientValue(totalNutrients['NA']),
        totalSugars: _extractNutrientValue(totalNutrients['SUGAR']),
        addedSugar: _extractNutrientValue(totalNutrients['SUGAR.added']),
        potassium: _extractNutrientValue(totalNutrients['K']),
        calcium: _extractNutrientValue(totalNutrients['CA']),
        iron: _extractNutrientValue(totalNutrients['FE']),
        vitaminA: _extractNutrientValue(totalNutrients['VITA_RAE']),
        vitaminC: _extractNutrientValue(totalNutrients['VITC']),
        vitaminD: _extractNutrientValue(totalNutrients['VITD']),
      );
    } catch (e) {
      print('❌ Error converting Edamam nutrition data: $e');
      return null;
    }
  }
  
  /// Extract nutrient value from Edamam nutrient object
  static double _extractNutrientValue(Map<String, dynamic>? nutrient) {
    if (nutrient == null) return 0.0;
    final quantity = nutrient['quantity'];
    if (quantity is num) return quantity.toDouble();
    return 0.0;
  }
}

