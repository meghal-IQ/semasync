import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semasync_new/core/theme/app_text_styles.dart';
import '../../../../core/api/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/unit_converter.dart';
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
      floatingActionButton: FloatingActionButton(
        heroTag: "account_fab",
        onPressed: () {
          // Add action
        },
        backgroundColor: const Color(0xFF6A34D7),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildContent(UserModel? user) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                 Text(
                  'Account',
                  style: AppTextStyles.title(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F36),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: [
              // Quick stats cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.scale,
                      label: 'Weight',
                      value: user != null && user.weight > 0 
                          ? _formatWeight(user) 
                          : '--',
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
               Padding(
                padding: EdgeInsets.symmetric(vertical: AppConstants.spacing8),
                child: Text(
                  'Settings',
                  style: AppTextStyles.title(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return InkWell(
      onTap: () => _handleSignOut(context),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          border: Border.all(color: Color(0xFFDC2626)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign Out',
              style: AppTextStyles.title(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
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
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Sign Out', style: AppTextStyles.title(color: AppColors.surface),),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      // Perform logout - the main app will handle loading state
      await context.read<AuthProvider>().logout();

      // Navigation will be handled automatically by the main app
      // based on AuthProvider status change to unauthenticated
      if (context.mounted) {
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
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/dosage.png'),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
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
        padding: const EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 18),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
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
            Icon(Icons.chevron_right, color: const Color(0xFF6A34D7), size: 20),
          ],
        ),
      ),
    );
  }

  String _formatWeight(UserModel user) {
    final preferredUnit = user.preferredUnits.weight.toLowerCase();
    final weightInPreferredUnit = UnitConverter.convertWeight(user.weight, preferredUnit);
    return '${weightInPreferredUnit.toStringAsFixed(2)}${preferredUnit.toLowerCase()}';
  }

  String _formatHeight(double height) {
    if (height == 0.0) return '--';
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

