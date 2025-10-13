import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SupportSectionCard extends StatelessWidget {
  const SupportSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support & Help',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            _buildSupportItem(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'Find answers to common questions',
              onTap: () {
                // TODO: Open help center
              },
            ),
            _buildSupportItem(
              icon: Icons.chat_bubble_outline,
              title: 'Contact Support',
              subtitle: 'Get help from our team',
              onTap: () {
                // TODO: Contact support
              },
            ),
            _buildSupportItem(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Share your thoughts with us',
              onTap: () {
                // TODO: Send feedback
              },
            ),
            _buildSupportItem(
              icon: Icons.star_outline,
              title: 'Rate App',
              subtitle: 'Rate us on the App Store',
              onTap: () {
                // TODO: Rate app
              },
            ),
            _buildSupportItem(
              icon: Icons.share_outlined,
              title: 'Share App',
              subtitle: 'Tell friends about SemaSync',
              onTap: () {
                // TODO: Share app
              },
            ),
            const SizedBox(height: AppConstants.spacing20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  const Text(
                    'Thank you for using SemaSync!',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    'We\'re here to support your health journey every step of the way.',
                    style: TextStyle(
                      color: AppColors.primary.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}




