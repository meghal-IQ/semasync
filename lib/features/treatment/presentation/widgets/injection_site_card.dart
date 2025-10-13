import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class InjectionSiteCard extends StatelessWidget {
  const InjectionSiteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Injection Sites',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Last 7 days',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing16),
                const Text(
                  'Recommended next site:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing12,
                        vertical: AppConstants.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          SizedBox(width: AppConstants.spacing4),
                          Text(
                            'Left Thigh',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Stack(
              children: [
                // Body outline would go here
                Center(
                  child: Image.asset(
                    'assets/images/body_outline.png',
                    fit: BoxFit.contain,
                  ),
                ),
                // Injection site markers would be positioned here
                Positioned(
                  left: 120,
                  top: 80,
                  child: _buildInjectionMarker(
                    date: 'Sep 17',
                    isRecommended: true,
                  ),
                ),
                Positioned(
                  right: 100,
                  top: 60,
                  child: _buildInjectionMarker(
                    date: 'Sep 10',
                    isRecommended: false,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  color: AppColors.success,
                  label: 'Available',
                ),
                const SizedBox(width: AppConstants.spacing24),
                _buildLegendItem(
                  color: AppColors.warning,
                  label: 'Recent',
                ),
                const SizedBox(width: AppConstants.spacing24),
                _buildLegendItem(
                  color: AppColors.error,
                  label: 'Unavailable',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInjectionMarker({
    required String date,
    required bool isRecommended,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: isRecommended ? AppColors.success : AppColors.warning,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.circle,
        size: 8,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppConstants.spacing8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}




