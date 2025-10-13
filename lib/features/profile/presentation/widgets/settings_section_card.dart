import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage your reminders',
              onTap: () {
                // TODO: Open notifications settings
              },
            ),
            _buildSettingsItem(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              subtitle: 'Theme and display options',
              onTap: () {
                // TODO: Open appearance settings
              },
            ),
            _buildSettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy & Security',
              subtitle: 'Data protection and privacy',
              onTap: () {
                // TODO: Open privacy settings
              },
            ),
            _buildSettingsItem(
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Download your health data',
              onTap: () {
                // TODO: Export data
              },
            ),
            _buildSettingsItem(
              icon: Icons.backup_outlined,
              title: 'Backup & Sync',
              subtitle: 'Cloud backup settings',
              onTap: () {
                // TODO: Open backup settings
              },
            ),
            _buildSettingsItem(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English',
              onTap: () {
                // TODO: Change language
              },
            ),
            _buildSettingsItem(
              icon: Icons.straighten_outlined,
              title: 'Units',
              subtitle: 'Metric (kg, cm)',
              onTap: () {
                // TODO: Change units
              },
            ),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and info',
              onTap: () {
                // TODO: Show about dialog
              },
            ),
            _buildSettingsItem(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              onTap: () {
                // TODO: Sign out
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}




