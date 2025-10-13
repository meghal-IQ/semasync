import 'package:flutter/foundation.dart';
import '../api/models/user_model.dart';
import '../api/models/auth_models.dart';
import '../api/services/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  /// Initialize authentication state
  Future<void> initialize() async {
    print('🚀 AuthProvider: Initializing...');
    _setStatus(AuthStatus.loading);
    
    try {
      final isAuth = await _authService.isAuthenticated();
      print('🔐 AuthProvider: isAuthenticated = $isAuth');
      
      if (isAuth) {
        final response = await _authService.getCurrentUser();
        if (response.success && response.data != null) {
          _user = response.data;
          print('✅ AuthProvider: User loaded successfully');
          print('   Email: ${_user?.email}');
          print('   Weight: ${_user?.weight}, Height: ${_user?.height}');
          _setStatus(AuthStatus.authenticated);
        } else {
          print('❌ AuthProvider: Failed to get current user: ${response.message}');
          _setStatus(AuthStatus.unauthenticated);
        }
      } else {
        print('ℹ️ AuthProvider: User not authenticated');
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      print('❌ AuthProvider: Initialization error: $e');
      _setError('Failed to initialize authentication: $e');
    }
  }

  /// Register a new user
  Future<bool> register(RegisterRequest request) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      final response = await _authService.register(request);
      
      if (response.success && response.data != null) {
        _user = response.data!.user;
        _setStatus(AuthStatus.authenticated);
        return true;
      } else {
        _setError(response.message);
        _setStatus(AuthStatus.error);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);
      
      print('🔍 AuthProvider: Response success: ${response.success}, message: ${response.message}');
      
      if (response.success && response.data != null) {
        _user = response.data!.user;
        _setStatus(AuthStatus.authenticated);
        return true;
      } else {
        print('🔍 AuthProvider: Login failed - ${response.message}');
        _setError(response.message);
        _setStatus(AuthStatus.error);
        return false;
      }
    } catch (e) {
      print('🔍 AuthProvider: Exception - $e');
      _setError('Login failed: $e');
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _setStatus(AuthStatus.loading);

    try {
      await _authService.logout();
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      // Even if logout fails on server, clear local state
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    if (_status != AuthStatus.authenticated) {
      print('⚠️ Cannot refresh user: Not authenticated (status: $_status)');
      return;
    }

    try {
      print('🔄 Refreshing user data...');
      final response = await _authService.getCurrentUser();
      if (response.success && response.data != null) {
        _user = response.data;
        print('✅ User data refreshed: ${_user?.email}');
        print('   Weight: ${_user?.weight}, Height: ${_user?.height}');
        notifyListeners();
      } else {
        print('❌ Failed to refresh user data: ${response.message}');
        // If we get an auth error, log out the user
        if (response.message.contains('401') || response.message.contains('token')) {
          print('🔒 Token invalid, logging out...');
          await logout();
        }
      }
    } catch (e) {
      print('❌ Exception while refreshing user data: $e');
      // Check if it's an authentication error
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        print('🔒 Authentication error, logging out...');
        await logout();
      }
    }
  }

  /// Load current user (alias for refreshUser)
  Future<void> loadCurrentUser() async {
    await refreshUser();
  }

  /// Forgot password
  Future<bool> forgotPassword(String email) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      final response = await _authService.forgotPassword(email);
      
      if (response.success) {
        _setStatus(AuthStatus.unauthenticated);
        return true;
      } else {
        _setError(response.message);
        _setStatus(AuthStatus.error);
        return false;
      }
    } catch (e) {
      _setError('Failed to send reset email: $e');
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      final response = await _authService.changePassword(currentPassword, newPassword);
      
      if (response.success) {
        _setStatus(AuthStatus.authenticated);
        return true;
      } else {
        _setError(response.message);
        _setStatus(AuthStatus.error);
        return false;
      }
    } catch (e) {
      _setError('Failed to change password: $e');
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  /// Verify email
  Future<bool> verifyEmail(String token) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      final response = await _authService.verifyEmail(token);
      
      if (response.success) {
        // Refresh user data to get updated verification status
        await refreshUser();
        return true;
      } else {
        _setError(response.message);
        _setStatus(AuthStatus.error);
        return false;
      }
    } catch (e) {
      _setError('Email verification failed: $e');
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _authService.updateProfile(updates);
      
      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setStatus(AuthStatus.error);
  }

  void _clearError() {
    _errorMessage = null;
  }
}
