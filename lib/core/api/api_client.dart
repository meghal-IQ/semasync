import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'models/api_response.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  String? _accessToken;

  Dio get dio => _dio;

  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
      validateStatus: (status) {
        // Don't throw on any status code, handle them in the response
        return true;
      },
    ));

    // Add interceptors
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_loggingInterceptor());
    _dio.interceptors.add(_errorInterceptor());

    // Load stored token
    await _loadStoredToken();
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final options = error.requestOptions;
            options.headers['Authorization'] = 'Bearer $_accessToken';
            final response = await _dio.fetch(options);
            handler.resolve(response);
            return;
          }
        }
        handler.next(error);
      },
    );
  }

  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (ApiConfig.debugMode) {
          print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
          print('Headers: ${options.headers}');
          if (options.data != null) {
            print('Data: ${options.data}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (ApiConfig.debugMode) {
          print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          print('Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (ApiConfig.debugMode) {
          print('❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          print('Message: ${error.message}');
          if (error.response?.data != null) {
            print('Error Data: ${error.response?.data}');
          }
        }
        handler.next(error);
      },
    );
  }

  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          // Handle timeout errors
          final timeoutError = DioException(
            requestOptions: error.requestOptions,
            error: 'Connection timeout. Please check your internet connection.',
            type: error.type,
          );
          handler.next(timeoutError);
          return;
        }

        if (error.type == DioExceptionType.connectionError) {
          // Handle connection errors
          final connectionError = DioException(
            requestOptions: error.requestOptions,
            error: 'No internet connection. Please check your network.',
            type: error.type,
          );
          handler.next(connectionError);
          return;
        }

        handler.next(error);
      },
    );
  }

  Future<void> _loadStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    if (_accessToken != null) {
      print('✅ Token loaded from storage');
    } else {
      print('⚠️ No token found in storage');
    }
  }

  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    print('✅ Token set and stored: ${token.substring(0, 20)}...');
  }

  Future<void> clearAccessToken() async {
    _accessToken = null;
    print('🗑️ Token cleared from ApiClient');
  }

  Future<void> _storeTokens(ApiResponse response) async {
    if (response.data != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data['tokens'] != null) {
        final tokens = data['tokens'] as Map<String, dynamic>;
        final accessToken = tokens['accessToken'] as String?;
        final refreshToken = tokens['refreshToken'] as String?;
        
        if (accessToken != null) {
          _accessToken = accessToken;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
        }
        
        if (refreshToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('refresh_token', refreshToken);
        }
      }
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, null);
        await _storeTokens(apiResponse);
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
      await logout();
    }
    return false;
  }

  Future<void> logout() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<bool> isAuthenticated() async {
    return _accessToken != null;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        if (statusCode == 401) {
          return Exception('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          return Exception('Forbidden. You do not have permission to access this resource.');
        } else if (statusCode == 404) {
          return Exception('Resource not found.');
        } else if (statusCode == 422) {
          return Exception('Validation failed. Please check your input.');
        } else if (statusCode == 500) {
          return Exception('Server error. Please try again later.');
        } else {
          return Exception(data?['message'] ?? 'An error occurred. Please try again.');
        }
      
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      
      case DioExceptionType.unknown:
      default:
        return Exception('An unexpected error occurred. Please try again.');
    }
  }
}
