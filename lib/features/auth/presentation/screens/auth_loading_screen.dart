import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/api/helpers/registration_helper.dart';
import '../../data/auth_data.dart';
import 'auth_complete_screen.dart';

class AuthLoadingScreen extends StatefulWidget {
  const AuthLoadingScreen({super.key});

  @override
  State<AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends State<AuthLoadingScreen> 
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  
  int _currentStep = 0;
  final List<String> _loadingSteps = [
    'Creating your account...',
    'Setting up your SemaSync Plan',
    'Tailoring exercises to your lifestyle and goals...',
    'Creating daily nutrition goals...',
    'Personalizing your daily water intake...',
  ];
  
  bool _registrationCompleted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _rotationController.repeat();
    
    // Start registration after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRegistration();
    });
  }

  Future<void> _startRegistration() async {
    try {
      // First step: Create account
      await _registerUser();
      
      if (mounted) {
        setState(() {
          _currentStep = 1;
          _registrationCompleted = true;
        });
        
        // Continue with other loading steps
        _startLoadingSteps();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Registration failed: $e';
        });
      }
    }
  }

  Future<void> _registerUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Validate that all required data has been collected from the auth screens
    if (authData.email == null || authData.email!.isEmpty) {
      throw Exception('Email is required - please complete the auth flow');
    }
    
    if (authData.password == null || authData.password!.isEmpty) {
      throw Exception('Password is required - please complete the auth flow');
    }
    
    // Check for other required fields
    final missingFields = <String>[];
    if (authData.firstName == null || authData.firstName!.isEmpty) missingFields.add('First Name');
    if (authData.lastName == null || authData.lastName!.isEmpty) missingFields.add('Last Name');
    if (authData.dateOfBirth == null) missingFields.add('Date of Birth');
    if (authData.gender == null || authData.gender!.isEmpty) missingFields.add('Gender');
    if (authData.height == null) missingFields.add('Height');
    if (authData.weight == null) missingFields.add('Weight');
    if (authData.medication == null || authData.medication!.isEmpty) missingFields.add('Medication');
    if (authData.startingDose == null || authData.startingDose!.isEmpty) missingFields.add('Starting Dose');
    if (authData.frequency == null || authData.frequency!.isEmpty) missingFields.add('Frequency');
    if (authData.motivation == null || authData.motivation!.isEmpty) missingFields.add('Motivation');
    
    if (missingFields.isNotEmpty) {
      throw Exception('Missing required fields: ${missingFields.join(', ')}. Please complete the auth flow.');
    }
    
    // Set default values for optional fields if not already set
    authData.targetWeight ??= authData.weight! * 0.9; // 10% weight loss goal
    authData.targetDate ??= DateTime.now().add(const Duration(days: 365)); // 1 year goal
    authData.primaryGoal ??= 'Weight loss';
    authData.secondaryGoals = authData.secondaryGoals.isEmpty ? ['Improved energy'] : authData.secondaryGoals;
    authData.distanceUnit ??= authData.weightUnit == 'lbs' ? 'miles' : 'km';
    
    final request = RegistrationHelper.buildRegisterRequest(
      email: authData.email!,
      password: authData.password!,
      firstName: authData.firstName!,
      lastName: authData.lastName!,
      dateOfBirth: authData.dateOfBirth!,
      gender: authData.gender!,
      height: authData.height!,
      weight: authData.weight!,
      medication: authData.medication!,
      startingDose: authData.startingDose!,
      frequency: authData.frequency!,
      injectionDays: authData.injectionDays,
      startDate: authData.startDate,
      motivation: authData.motivation!,
      concerns: authData.concerns,
      targetWeight: authData.targetWeight,
      targetDate: authData.targetDate,
      primaryGoal: authData.primaryGoal,
      secondaryGoals: authData.secondaryGoals,
      weightUnit: authData.weightUnit,
      heightUnit: authData.heightUnit,
      distanceUnit: authData.distanceUnit,
    );

    final success = await authProvider.register(request);
    
    if (!success) {
      throw Exception(authProvider.errorMessage ?? 'Registration failed');
    }
  }

  void _startLoadingSteps() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _currentStep < _loadingSteps.length - 1) {
        setState(() {
          _currentStep++;
        });
        _startLoadingSteps();
      } else if (mounted) {
        // Navigate to completion screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthCompleteScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  Text(
                    'Registration Failed',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _currentStep = 0;
                      });
                      _startRegistration();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading Animation
              _buildLoadingAnimation(),
              
              const SizedBox(height: AppConstants.spacing32),
              
              // Loading Text
              Text(
                _loadingSteps[_currentStep],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppConstants.spacing8),
              
              // Subtitle based on current step
              Text(
                _getSubtitle(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppConstants.spacing32),
              
              // Progress Indicator
              _buildProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    if (_currentStep == 0) {
      // User icon for registration step
      return RotationTransition(
        turns: _rotationAnimation,
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
            size: 30,
          ),
        ),
      );
    } else if (_currentStep == 1) {
      // Weightlifting emoji for exercise step
      return const Text(
        '🏋️',
        style: TextStyle(fontSize: 64),
      );
    } else if (_currentStep == 2) {
      // Water drop for water intake step
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.waterBlue,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.water_drop,
          color: Colors.white,
          size: 40,
        ),
      );
    } else {
      // Default spinning loader
      return RotationTransition(
        turns: _rotationAnimation,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 4,
            ),
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }
  }

  String _getSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Setting up your account with all your information...';
      case 1:
        return 'Tailoring exercises to your lifestyle and goals...';
      case 2:
        return 'Creating daily nutrition goals...';
      case 3:
        return 'Personalizing your daily water intake...';
      case 4:
        return 'Finalizing your personalized plan...';
      default:
        return 'Almost ready...';
    }
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_loadingSteps.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentStep 
                ? AppColors.primary 
                : AppColors.divider,
          ),
        );
      }),
    );
  }
}
