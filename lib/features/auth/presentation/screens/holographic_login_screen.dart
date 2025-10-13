import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../navigation/presentation/screens/main_navigation_screen.dart';
import 'auth_welcome_screen.dart';
import 'dart:math' as math;

class HolographicLoginScreen extends StatefulWidget {
  const HolographicLoginScreen({super.key});

  @override
  State<HolographicLoginScreen> createState() => _HolographicLoginScreenState();
}

class _HolographicLoginScreenState extends State<HolographicLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Holographic Background
          _buildHolographicBackground(),
          
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.16),
                    
                    // App Branding
                    _buildAppBranding(),
                    
                    const SizedBox(height: 40),
                    
                    // Login Form Card
                    _buildLoginForm(),
                    
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolographicBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Stack(
        children: [
            Image.asset('assets/images/login_bg.png')
        ],
      ),
    );
  }

  Widget _buildMedicalScene() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Stack(
        children: [
          // Desk surface
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
            ),
          ),
          
          // Blood pressure cuff (patient's arm)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          // Doctor's hands with blood pressure bulb
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: MediaQuery.of(context).size.width * 0.15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          
          // Clipboard
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              width: 40,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          // Stethoscope
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: MediaQuery.of(context).size.width * 0.08,
            child: Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          // Pills
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            left: MediaQuery.of(context).size.width * 0.3,
            child: Container(
              width: 30,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                )),
              ),
            ),
          ),
          
          // Tablet/Phone
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              width: 25,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHexagons() {
    return Stack(
      children: [
        // ECG Waveform Hexagon - positioned over patient's wrist
        Positioned(
          top: MediaQuery.of(context).size.height * 0.32,
          left: MediaQuery.of(context).size.width * 0.15,
          child: _buildHexagon(
            child: Container(
              width: 50,
              height: 25,
              child: CustomPaint(
                painter: ECGWaveformPainter(),
                size: const Size(50, 25),
              ),
            ),
          ),
        ),
        
        // Medical Cross Hexagon - near doctor's hands
        Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          right: MediaQuery.of(context).size.width * 0.2,
          child: _buildHexagon(
            child: const Icon(
              Icons.add,
              color: Color(0xFF00D4FF),
              size: 20,
            ),
          ),
        ),
        
        // DNA/Chromosome Hexagon - near patient's elbow
        Positioned(
          top: MediaQuery.of(context).size.height * 0.38,
          left: MediaQuery.of(context).size.width * 0.05,
          child: _buildHexagon(
            child: const Icon(
              Icons.science,
              color: Color(0xFF00D4FF),
              size: 18,
            ),
          ),
        ),
        
        // Heart Icon Hexagon - center area
        Positioned(
          top: MediaQuery.of(context).size.height * 0.42,
          left: MediaQuery.of(context).size.width * 0.5,
          child: _buildHexagon(
            child: const Icon(
              Icons.favorite,
              color: Color(0xFF00D4FF),
              size: 18,
            ),
          ),
        ),
        
        // Pulse Chart Hexagon - near doctor's thumb area
        Positioned(
          top: MediaQuery.of(context).size.height * 0.45,
          right: MediaQuery.of(context).size.width * 0.25,
          child: _buildHexagon(
            child: Container(
              width: 35,
              height: 18,
              child: CustomPaint(
                painter: PulseChartPainter(),
                size: const Size(35, 18),
              ),
            ),
          ),
        ),
        
        // Background hexagon patterns - scattered around
        ...List.generate(6, (index) {
          final positions = [
            Offset(MediaQuery.of(context).size.width * 0.1, MediaQuery.of(context).size.height * 0.25),
            Offset(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.height * 0.28),
            Offset(MediaQuery.of(context).size.width * 0.15, MediaQuery.of(context).size.height * 0.52),
            Offset(MediaQuery.of(context).size.width * 0.75, MediaQuery.of(context).size.height * 0.48),
            Offset(MediaQuery.of(context).size.width * 0.3, MediaQuery.of(context).size.height * 0.58),
            Offset(MediaQuery.of(context).size.width * 0.65, MediaQuery.of(context).size.height * 0.55),
          ];
          
          return Positioned(
            top: positions[index].dy,
            left: positions[index].dx,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4FF).withOpacity(0.15 + (_animation.value * 0.1)),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHexagon({required Widget child}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF00D4FF).withOpacity(0.15 + (_animation.value * 0.1)),
            borderRadius: BorderRadius.circular(12), // More curved
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.8 + (_animation.value * 0.2)),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.4 + (_animation.value * 0.3)),
                blurRadius: 12,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(child: child),
        );
      },
    );
  }

  Widget _buildAppBranding() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16), // Curved corners
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.health_and_safety_outlined,
            size: 40,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // App Title
        const Text(
          'Sema Sync',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Welcome Message
        const Text(
          'Welcome back! Please sign in \nto continue.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
    //   padding: const EdgeInsets.symmetric(32),
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     borderRadius: BorderRadius.circular(20), // Curved corners
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.black.withOpacity(0.1),
    //         blurRadius: 30,
    //         offset: const Offset(0, 15),
    //       ),
    //       BoxShadow(
    //         color: AppColors.primary.withOpacity(0.05),
    //         blurRadius: 40,
    //         offset: const Offset(0, 20),
    //       ),
    //     ],
    //   ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error Message Display
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.errorMessage != null) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Email Field
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                final authProvider = context.read<AuthProvider>();
                if (authProvider.errorMessage != null) {
                  authProvider.clearError();
                }
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
          ),

          // Password Field
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: (value) {
                final authProvider = context.read<AuthProvider>();
                if (authProvider.errorMessage != null) {
                  authProvider.clearError();
                }
              },
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.lock_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),

          // Forgot Password Link
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: TextButton(
          //     onPressed: () {
          //       // TODO: Implement forgot password functionality
          //     },
          //     child: const Text(
          //       'Forgot Password?',
          //       style: TextStyle(
          //         color: AppColors.primary,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ),

          const SizedBox(height: 24),

          // Sign In Button
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12), // Curved corners
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: const RoundedRectangleBorder(),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // OR Divider
          Row(
            children: [
              const Expanded(
                child: Divider(
                  color: Color(0xFFE5E7EB),
                  thickness: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(
                  color: Color(0xFFE5E7EB),
                  thickness: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Create Account Button
          SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthWelcomeScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painters for medical visualizations
class ECGWaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    
    // Create ECG-like waveform
    for (double x = 0; x < width; x += 2) {
      double y;
      if (x < width * 0.2) {
        y = height * 0.5 + math.sin(x * 0.1) * 5;
      } else if (x < width * 0.4) {
        y = height * 0.2 + math.sin(x * 0.3) * 3;
      } else if (x < width * 0.6) {
        y = height * 0.5 + math.sin(x * 0.1) * 5;
      } else if (x < width * 0.8) {
        y = height * 0.8 + math.sin(x * 0.2) * 4;
      } else {
        y = height * 0.5 + math.sin(x * 0.1) * 5;
      }
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PulseChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    
    // Create pulse-like waveform
    for (double x = 0; x < width; x += 1) {
      double y = height * 0.5 + math.sin(x * 0.5) * 3 + math.sin(x * 0.2) * 2;
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
