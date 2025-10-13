import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../navigation/presentation/screens/main_navigation_screen.dart';
import 'auth_welcome_screen.dart';
import 'medication_selection_screen.dart';
import 'dose_selection_screen.dart';
import 'frequency_selection_screen.dart';
import 'birthday_input_screen.dart';
import 'height_weight_screen.dart';
import 'motivation_selection_screen.dart';
import 'concerns_selection_screen.dart';
import 'auth_loading_screen.dart';
import 'auth_complete_screen.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _quickLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      'testdose@example.com',
      'password123',
    );

    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${authProvider.errorMessage}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Test Screens'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: ListView(
          children: [
            const Text(
              'Select a screen to test:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: AppConstants.spacing24),
            
            // Quick Login Button
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _quickLogin,
                icon: const Icon(Icons.login),
                label: const Text('Quick Login (testdose@example.com)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.spacing24),
            
            // Main App
            _buildTestButton(
              context: context,
              title: 'Main App (Dashboard)',
              description: 'Go to the main dashboard',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
              ),
            ),
            
            const SizedBox(height: AppConstants.spacing16),
            
            // Auth Flow Screens
            _buildTestButton(
              context: context,
              title: 'Auth Welcome',
              description: 'Start of authentication flow',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthWelcomeScreen()),
              ),
            ),
            
            _buildTestButton(
              context: context,
              title: 'Medication Selection',
              description: 'Select GLP-1 medication',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MedicationSelectionScreen()),
              ),
            ),
            
            _buildTestButton(
              context: context,
              title: 'Dose Selection',
              description: 'Select starting dose',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DoseSelectionScreen()),
              ),
            ),
            
            _buildTestButton(
              context: context,
              title: 'Frequency Selection',
              description: 'Select injection frequency',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FrequencySelectionScreen()),
              ),
            ),
            
            _buildTestButton(
              context: context,
              title: 'Birthday Input',
              description: 'Date picker for birthday',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BirthdayInputScreen()),
              ),
            ),
            
            _buildTestButton(
              context: context,
              title: 'Height & Weight',
              description: 'Height and weight input with pickers',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HeightWeightScreen()),
              ),
            ),
            
            _buildTestButton(
              context: context,
              title: 'Motivation Selection',
              description: 'Select motivation for goals',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MotivationSelectionScreen()),
              ),
            ),
            
            _buildTestButton(
              context: context,
              title: 'Concerns Selection',
              description: 'Select side effect concerns',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConcernsSelectionScreen()),
              ),
            ),
            
            _buildTestButton(
              context: context,
              title: 'Loading Screen',
              description: 'Animated loading with steps',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthLoadingScreen()),
              ),
            ),
            
            _buildTestButton(
              context: context,
              title: 'Auth Complete',
              description: 'Final completion screen with plan summary',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthCompleteScreen()),
              ),
            ),
            
            const SizedBox(height: AppConstants.spacing32),
            
            // Full Flow Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthWelcomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
                child: const Text(
                  'Start Full Auth Flow',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required BuildContext context,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
