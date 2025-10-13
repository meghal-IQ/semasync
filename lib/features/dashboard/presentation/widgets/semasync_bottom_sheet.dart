import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../logging/presentation/screens/shot_logging_screen.dart';
import '../../../logging/presentation/screens/photo_logging_screen.dart';
import '../../../logging/presentation/screens/weight_logging_screen.dart';
import '../../../logging/presentation/screens/activity_logging_screen.dart';
import '../../../logging/presentation/screens/side_effect_logging_screen.dart';
import '../../../logging/presentation/screens/meal_logging_screen.dart';
import '../../../treatment/presentation/screens/side_effect_logging_screen.dart';

class SemaSyncBottomSheet extends StatelessWidget {
  const SemaSyncBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppConstants.spacing12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          
          const SizedBox(height: AppConstants.spacing24),
          
          // Main action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.medical_services,
                  label: 'Log a Shot',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShotLoggingScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: AppConstants.spacing16),
                
                _buildActionButton(
                  icon: Icons.camera_alt,
                  label: 'Log Photos',
                  color: Colors.amber,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PhotoLoggingScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: AppConstants.spacing16),
                
                _buildActionButton(
                  icon: Icons.monitor_weight,
                  label: 'Log Weight',
                  color: Colors.pink,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WeightLoggingScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: AppConstants.spacing16),
                
                _buildActionButton(
                  icon: Icons.directions_run,
                  label: 'Log Activity',
                  color: AppColors.activityRed,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ActivityLoggingScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: AppConstants.spacing16),
                
                _buildActionButton(
                  icon: Icons.warning,
                  label: 'Log Side Effect',
                  color: Colors.lightGreen,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SideEffectLoggingScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.spacing24),
          
          // Bottom row actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
            child: Row(
              children: [
                Expanded(
                  child: _buildBottomAction(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan Food',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement food scanning
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: _buildBottomAction(
                    icon: Icons.search,
                    label: 'Search Food',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MealLoggingScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: _buildBottomAction(
                    icon: Icons.mic,
                    label: 'Voice Log',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement voice logging
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.spacing32),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.spacing16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
