import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/treatment_provider.dart';

class InjectionSiteCard extends StatelessWidget {
  const InjectionSiteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TreatmentProvider>(
      builder: (context, treatmentProvider, child) {
        final lastShot = treatmentProvider.latestShot;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    const Text(
                      'Injection',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing12),
                if (lastShot != null) ...[
                  Text(
                    _getInjectionSiteDisplay(lastShot.injectionSite),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBodyDiagram(lastShot.injectionSite),
                      ),
                    ],
                  ),
                ] else ...[
                  const Text(
                    'No data',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  const Text(
                    'Log your first shot',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getInjectionSiteDisplay(String injectionSite) {
    // Parse the injection site to get the main area
    if (injectionSite.toLowerCase().contains('thigh')) {
      return 'Thigh';
    } else if (injectionSite.toLowerCase().contains('stomach') || injectionSite.toLowerCase().contains('abdomen')) {
      return 'Stomach';
    } else if (injectionSite.toLowerCase().contains('arm')) {
      return 'Arm';
    } else if (injectionSite.toLowerCase().contains('buttock')) {
      return 'Buttock';
    }
    return injectionSite.split(' ').first;
  }

  Widget _buildBodyDiagram(String injectionSite) {
    return Container(
      height: 120,
      child: Stack(
        children: [
          // Body outline
          Center(
            child: Container(
              width: 60,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  // Head
                  Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Body
                  Expanded(
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.border,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Injection site highlight
          _buildInjectionSiteHighlight(injectionSite),
        ],
      ),
    );
  }

  Widget _buildInjectionSiteHighlight(String injectionSite) {
    // Determine position based on injection site
    Offset position;
    if (injectionSite.toLowerCase().contains('thigh')) {
      if (injectionSite.toLowerCase().contains('left')) {
        position = const Offset(20, 80); // Left thigh
      } else {
        position = const Offset(100, 80); // Right thigh
      }
    } else if (injectionSite.toLowerCase().contains('stomach') || injectionSite.toLowerCase().contains('abdomen')) {
      if (injectionSite.toLowerCase().contains('left')) {
        position = const Offset(20, 50); // Left stomach
      } else {
        position = const Offset(100, 50); // Right stomach
      }
    } else if (injectionSite.toLowerCase().contains('arm')) {
      if (injectionSite.toLowerCase().contains('left')) {
        position = const Offset(20, 40); // Left arm
      } else {
        position = const Offset(100, 40); // Right arm
      }
    } else {
      position = const Offset(60, 50); // Default center
    }

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.location_on,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}