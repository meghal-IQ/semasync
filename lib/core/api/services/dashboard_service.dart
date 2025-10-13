import '../api_client.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  /// Get current user's dashboard data
  Future<ApiResponse<UserModel>> getDashboardData() async {
    try {
      final response = await _apiClient.get('/api/auth/me');

      return ApiResponse.fromJson(
        response.data,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Update user's medication level
  Future<ApiResponse<void>> updateMedicationLevel(double level) async {
    try {
      final response = await _apiClient.put(
        '/api/users/medication-level',
        data: {'level': level},
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Update nutrition tracking
  Future<ApiResponse<void>> updateNutrition({
    required double fiber,
    required double water,
    required double protein,
  }) async {
    try {
      final response = await _apiClient.put(
        '/api/users/nutrition',
        data: {
          'fiber': fiber,
          'water': water,
          'protein': protein,
        },
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Update weight
  Future<ApiResponse<void>> updateWeight(double weight) async {
    try {
      final response = await _apiClient.put(
        '/api/users/weight',
        data: {'weight': weight},
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }
}



