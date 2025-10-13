import '../api_client.dart';
import '../models/api_response.dart';
import '../models/nutrition_log_model.dart';
import '../models/todays_log_model.dart';

class NutritionService {
  final ApiClient _apiClient = ApiClient();

  // ============================================================================
  // MEAL TRACKING
  // ============================================================================

  Future<ApiResponse<MealLog>> logMeal(MealLogRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/nutrition/meals',
        data: request.toJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final mealLog = MealLog.fromJson(response.data['data']);
        return ApiResponse<MealLog>(
          success: true,
          message: response.data['message'] ?? 'Meal logged successfully',
          data: mealLog,
        );
      }

      return ApiResponse<MealLog>(
        success: false,
        message: response.data['message'] ?? 'Failed to log meal',
      );
    } catch (e) {
      return ApiResponse<MealLog>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<MealLog>>> getMealHistory({
    int limit = 30,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/nutrition/meals',
        queryParameters: {
          'limit': limit.toString(),
          'page': page.toString(),
        },
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final meals = (response.data['data']['meals'] as List)
            .map((e) => MealLog.fromJson(e))
            .toList();
        return ApiResponse<List<MealLog>>(
          success: true,
          message: 'Meals retrieved',
          data: meals,
        );
      }

      return ApiResponse<List<MealLog>>(
        success: false,
        message: response.data['message'] ?? 'Failed to get meals',
      );
    } catch (e) {
      return ApiResponse<List<MealLog>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<DailyNutritionSummary>> getDailySummary({String? date}) async {
    try {
      final queryParams = date != null ? {'date': date} : <String, dynamic>{};
      
      final response = await _apiClient.get(
        '/api/nutrition/daily-summary',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final summary = DailyNutritionSummary.fromJson(response.data['data']);
        return ApiResponse<DailyNutritionSummary>(
          success: true,
          message: 'Summary retrieved',
          data: summary,
        );
      }

      return ApiResponse<DailyNutritionSummary>(
        success: false,
        message: response.data['message'] ?? 'Failed to get summary',
      );
    } catch (e) {
      return ApiResponse<DailyNutritionSummary>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // ============================================================================
  // WATER TRACKING
  // ============================================================================

  Future<ApiResponse<WaterLog>> logWater(WaterLogRequest request) async {
    print('=== NutritionService.logWater START ===');
    // print('Request data:'+ request.toJson());
    
    try {
      final response = await _apiClient.post(
        '/api/nutrition/water',
        data: request.toJson(),
      );

      print('API response status:'+ response.statusCode.toString());
      print('API response data:' + response.data.toString());

      if (response.data['success'] == true && response.data['data'] != null) {
        final waterLog = WaterLog.fromJson(response.data['data']);
        print('Water log created successfully');
        return ApiResponse<WaterLog>(
          success: true,
          message: response.data['message'] ?? 'Water logged successfully',
          data: waterLog,
        );
      }

      // print('API call failed:', response.data['message']);
      return ApiResponse<WaterLog>(
        success: false,
        message: response.data['message'] ?? 'Failed to log water',
      );
    } catch (e) {
      // print('Exception in NutritionService.logWater:', e);
      return ApiResponse<WaterLog>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<WaterLog>>> getWaterHistory({
    int limit = 30,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/nutrition/water',
        queryParameters: {
          'limit': limit.toString(),
          'page': page.toString(),
        },
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final logs = (response.data['data']['water'] as List)
            .map((e) => WaterLog.fromJson(e))
            .toList();
        return ApiResponse<List<WaterLog>>(
          success: true,
          message: 'Water history retrieved',
          data: logs,
        );
      }

      return ApiResponse<List<WaterLog>>(
        success: false,
        message: response.data['message'] ?? 'Failed to get water history',
      );
    } catch (e) {
      return ApiResponse<List<WaterLog>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // ============================================================================
  // TODAY'S LOG
  // ============================================================================

  Future<ApiResponse<TodaysLogResponse>> getTodaysLog() async {
    try {
      final response = await _apiClient.get('/api/nutrition/todays-log');

      if (response.data['success'] == true && response.data['data'] != null) {
        final todaysLog = TodaysLogResponse.fromJson(response.data['data']);
        return ApiResponse<TodaysLogResponse>(
          success: true,
          message: response.data['message'] ?? 'Today\'s log retrieved successfully',
          data: todaysLog,
        );
      }

      return ApiResponse<TodaysLogResponse>(
        success: false,
        message: response.data['message'] ?? 'Failed to retrieve today\'s log',
      );
    } catch (e) {
      return ApiResponse<TodaysLogResponse>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
