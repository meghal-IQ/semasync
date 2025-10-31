import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../logging/presentation/screens/shot_logging_screen_updated.dart';
import '../../../logging/presentation/screens/simple_photo_logging_screen.dart';
import '../../../logging/presentation/screens/weight_logging_screen.dart';
import '../../../logging/presentation/screens/activity_logging_screen.dart';
import '../../../treatment/presentation/screens/side_effect_logging_screen.dart';

class QuickActionFAB extends StatefulWidget {
  const QuickActionFAB({super.key});

  @override
  State<QuickActionFAB> createState() => _QuickActionFABState();
}

class _QuickActionFABState extends State<QuickActionFAB> {
  void _showOverlayMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => _buildOverlayMenu(context),
    );
  }

  Widget _buildOverlayMenu(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildGridAction(
                context,
                icon: Icons.vaccines,
                label: 'Log a Shot',
                iconColor: const Color(0xFF00BCD4), // Cyan
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShotLoggingScreenUpdated()),
                  );
                },
              ),
              _buildGridAction(
                context,
                icon: Icons.add_a_photo,
                label: 'Log Photos',
                iconColor: const Color(0xFFFF9800), // Orange
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SimplePhotoLoggingScreen()),
                  );
                },
              ),
              _buildGridAction(
                context,
                icon: Icons.monitor_weight,
                label: 'Log Weight',
                iconColor: const Color(0xFFE91E63), // Pink
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WeightLoggingScreen()),
                  );
                },
              ),
              _buildGridAction(
                context,
                icon: Icons.directions_run,
                label: 'Log Activity',
                iconColor: const Color(0xFFFF9800), // Orange
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActivityLoggingScreen()),
                  );
                },
              ),
              _buildGridAction(
                context,
                icon: Icons.sick,
                label: 'Log Side Effect',
                iconColor: const Color(0xFFAED581), // Light green
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SideEffectLoggingScreen()),
                  );
                },
              ),
              _buildGridAction(
                context,
                icon: Icons.mic,
                label: 'Log Voice',
                iconColor: const Color(0xFF26A69A), // Teal
                onTap: () {
                  // TODO: Implement voice logging screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voice logging coming soon!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A), // Dark gray button
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showOverlayMenu,
          child: const Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
