import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../logging/presentation/screens/shot_logging_screen.dart';
import '../../../logging/presentation/screens/shot_logging_screen_updated.dart';
import '../../../logging/presentation/screens/simple_photo_logging_screen.dart';
import '../../../logging/presentation/screens/weight_logging_screen.dart';
import '../../../logging/presentation/screens/meal_logging_screen.dart';
import '../../../logging/presentation/screens/activity_logging_screen.dart';
import '../../../logging/presentation/screens/step_logging_screen.dart';
import '../../../logging/presentation/screens/water_logging_screen.dart';
import '../../../logging/presentation/screens/side_effect_logging_screen.dart';
import '../../../treatment/presentation/screens/side_effect_logging_screen.dart';
import '../../../food_scanning/presentation/screens/food_scanner_screen.dart';
import '../../../food_scanning/presentation/screens/barcode_scanner_screen.dart';

class QuickActionFAB extends StatefulWidget {
  const QuickActionFAB({super.key});

  @override
  State<QuickActionFAB> createState() => _QuickActionFABState();
}

class _QuickActionFABState extends State<QuickActionFAB> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _showOverlayMenu() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => _buildOverlayMenu(context),
    );
  }

  Widget _buildOverlayMenu(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay covering bottom half
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.6 - 50,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Menu items
                    _buildMenuAction(
                      context,
                      icon: '💉',
                      label: 'Log a Shot',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ShotLoggingScreenUpdated()),
                        );
                      },
                    ),
                    
                    _buildMenuAction(
                      context,
                      icon: '📸',
                      label: 'Log Photos',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SimplePhotoLoggingScreen()),
                        );
                      },
                    ),
                    
                    _buildMenuAction(
                      context,
                      icon: '⚖️',
                      label: 'Log Weight',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WeightLoggingScreen()),
                        );
                      },
                    ),
                    
                    _buildMenuAction(
                      context,
                      icon: '🏃',
                      label: 'Log Activity',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ActivityLoggingScreen()),
                        );
                      },
                    ),
                    
                    _buildMenuAction(
                      context,
                      icon: '🤢',
                      label: 'Log Side Effect',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SideEffectLoggingScreen()),
                        );
                      },
                    ),
                    
                    _buildMenuAction(
                      context,
                      icon: '🍽️',
                      label: 'Scan Food',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FoodScannerScreen()),
                        );
                      },
                    ),
                    
                    _buildMenuAction(
                      context,
                      icon: '📱',
                      label: 'Scan Barcode',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
                        );
                      },
                    ),
                    
                    // const SizedBox(height: 24),
                    
                    // Bottom buttons row
                   /* Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBottomButton(
                            context,
                            icon: '🥕',
                            label: 'Scan Food',
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Implement scan food
                            },
                          ),
                          _buildBottomButton(
                            context,
                            icon: '🍴',
                            label: 'Search Food',
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Implement search food
                            },
                          ),
                          _buildBottomButton(
                            context,
                            icon: '🎤',
                            label: 'Voice Log',
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Implement voice log
                            },
                          ),
                        ],
                      ),
                    ),*/
                    
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuAction(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
