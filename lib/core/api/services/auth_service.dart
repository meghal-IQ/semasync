import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_client.dart';
import '../api_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import '../models/auth_models.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Register a new user
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/register',
        data: request.toJson(),
      );

      // Check if the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
        );

        // Store tokens if registration is successful
        if (apiResponse.success && apiResponse.data != null) {
          await _storeTokens(apiResponse.data!.tokens);
        }

        return apiResponse;
      } else {
        // Handle error responses (4xx, 5xx)
        final errorData = response.data as Map<String, dynamic>?;
        return ApiResponse<AuthResponse>(
          success: false,
          message: errorData?['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Login user
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/login',
        data: request.toJson(),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
        );

        // Store tokens if login is successful
        if (apiResponse.success && apiResponse.data != null) {
          await _storeTokens(apiResponse.data!.tokens);
        }

        return apiResponse;
      } else {
        // Handle error responses (4xx, 5xx)
        final errorData = response.data as Map<String, dynamic>?;
        return ApiResponse<AuthResponse>(
          success: false,
          message: errorData?['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get current user profile
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/api/auth/me');

      // Extract user from nested structure: data.user
      return ApiResponse.fromJson(
        response.data,
        (data) {
          final userData = (data as Map<String, dynamic>)['user'];
          return UserModel.fromJson(userData as Map<String, dynamic>);
        },
      );
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Refresh access token
  Future<ApiResponse<AuthTokens>> refreshToken() async {
    try {
      // Get refresh token from storage
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _apiClient.post(
        '/api/auth/refresh',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => AuthTokens.fromJson(data as Map<String, dynamic>),
      );

      // Store new tokens if refresh is successful
      if (apiResponse.success && apiResponse.data != null) {
        await _storeTokens(apiResponse.data!);
      }

      return apiResponse;
    } catch (e) {
      return ApiResponse<AuthTokens>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Logout user
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiClient.post('/api/auth/logout');
      
      // Clear stored tokens regardless of API response
      await _clearTokens();

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      // Clear tokens even if logout request fails
      await _clearTokens();
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Forgot password
  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _apiClient.post(
        '/api/auth/forgot-password',
        data: request.toJson(),
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Reset password
  Future<ApiResponse<void>> resetPassword(String token, String newPassword) async {
    try {
      final request = ResetPasswordRequest(token: token, newPassword: newPassword);
      final response = await _apiClient.post(
        '/api/auth/reset-password',
        data: request.toJson(),
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Change password
  Future<ApiResponse<void>> changePassword(String currentPassword, String newPassword) async {
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      final response = await _apiClient.post(
        '/api/auth/change-password',
        data: request.toJson(),
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Verify email
  Future<ApiResponse<void>> verifyEmail(String token) async {
    try {
      final request = VerifyEmailRequest(token: token);
      final response = await _apiClient.post(
        '/api/auth/verify-email',
        data: request.toJson(),
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Update user profile
  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put(
        '/api/auth/profile',
        data: updates,
      );

      // Extract user from nested structure: data.user
      return ApiResponse.fromJson(
        response.data,
        (data) {
          final userData = (data as Map<String, dynamic>)['user'];
          return UserModel.fromJson(userData as Map<String, dynamic>);
        },
      );
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }

  /// Store authentication tokens
  Future<void> _storeTokens(AuthTokens tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', tokens.accessToken);
    await prefs.setString('refresh_token', tokens.refreshToken);
    
    // Update the ApiClient's token so it's available immediately
    await _apiClient.setAccessToken(tokens.accessToken);
  }

  /// Clear stored tokens
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    
    // Also clear from ApiClient
    await _apiClient.clearAccessToken();
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }
}
