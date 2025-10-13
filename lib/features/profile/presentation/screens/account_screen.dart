import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../auth/presentation/screens/holographic_login_screen.dart';
import 'personal_details_screen.dart';
import 'units_settings_screen.dart';
import 'weight_goal_screen.dart';
import 'daily_lifestyle_goals_screen.dart';
import '../../../treatment/presentation/screens/treatment_settings_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Refresh user data when screen loads
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    if (!mounted) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    await context.read<AuthProvider>().refreshUser();
    
    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshUserData,
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          debugPrint('🔍 Account Screen - User: $user');
          debugPrint('🔍 Account Screen - Auth Status: ${authProvider.status}');
          if (user != null) {
            debugPrint('🔍 Account Screen - Weight: ${user.weight}, Height: ${user.height}, Gender: ${user.gender}');
          } else {
            debugPrint('⚠️ Account Screen - User is NULL!');
          }

          // Show loading overlay if refreshing
          if (_isRefreshing) {
            return Stack(
              children: [
                _buildContent(user),
                Container(
                  color: Colors.black12,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            );
          }
          
          return _buildContent(user);
        },
      ),
    );
  }

  Widget _buildContent(UserModel? user) {
    return ListView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            children: [
              // Quick stats cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.scale,
                      label: 'Weight',
                      value: user != null && user.weight > 0 ? '${user.weight.toStringAsFixed(1)}kg' : '--',
                      onTap: () => _navigateToWeightGoal(context),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.height,
                      label: 'Height',
                      value: user != null ? _formatHeight(user.height) : '--',
                      onTap: () => _navigateToPersonalDetails(context),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.spacing12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Birthday',
                      value: user != null ? _formatDate(user.dateOfBirth) : '--',
                      onTap: () => _navigateToPersonalDetails(context),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.person,
                      label: 'Gender',
                      value: user != null ? _capitalize(user.gender) : '--',
                      onTap: () => _navigateToPersonalDetails(context),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.spacing24),
              
              // Personal Details Section
              _buildNavigationItem(
                context,
                icon: Icons.person_outline,
                title: 'Personal Details',
                onTap: () => _navigateToPersonalDetails(context),
              ),
              
              const SizedBox(height: AppConstants.spacing16),
              
              // Settings Section Header
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppConstants.spacing8),
                child: Text(
                  'SETTINGS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              _buildNavigationItem(
                context,
                icon: Icons.medical_services_outlined,
                title: 'Treatment',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TreatmentSettingsScreen()),
                  );
                },
              ),
              
              _buildNavigationItem(
                context,
                icon: Icons.flash_on_outlined,
                title: 'Daily Lifestyle Goals',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DailyLifestyleGoalsScreen()),
                  );
                },
              ),
              
              _buildNavigationItem(
                context,
                icon: Icons.flag_outlined,
                title: 'Weight Goals',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WeightGoalScreen()),
                  );
                },
              ),
              
              _buildNavigationItem(
                context,
                icon: Icons.straighten_outlined,
                title: 'Units',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UnitsSettingsScreen()),
                  );
                },
              ),
              
              const SizedBox(height: AppConstants.spacing24),
              
              // Sign Out Button
              _buildSignOutButton(context),
              
              const SizedBox(height: AppConstants.spacing24),
            ],
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return InkWell(
      onTap: () => _handleSignOut(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppColors.error, size: 24),
            const SizedBox(width: AppConstants.spacing12),
            const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Perform logout
      await context.read<AuthProvider>().logout();

      if (context.mounted) {
        // Close loading dialog
        Navigator.pop(context);
        
        // Navigate to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HolographicLoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: AppColors.textPrimary),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 24),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing8,
                  vertical: AppConstants.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing8),
            ],
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatHeight(double height) {
    if (height == 0.0) return '--';
    // Assuming height is in cm, convert to feet/inches
    final totalInches = height * 0.393701;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return '$feet\'$inches"';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _navigateToPersonalDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PersonalDetailsScreen()),
    );
  }

  void _navigateToWeightGoal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeightGoalScreen()),
    );
  }
}

