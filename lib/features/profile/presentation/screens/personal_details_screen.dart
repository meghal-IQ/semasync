import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';

class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Personal Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          debugPrint('🔍 Personal Details - User: $user');
          if (user != null) {
            debugPrint('🔍 Personal Details - Weight: ${user.weight}, Height: ${user.height}, Gender: ${user.gender}');
          }
          
          return ListView(
            children: [
              _buildDetailItem(
                icon: Icons.scale,
                label: 'Current Weight',
                value: user != null && user.weight > 0 ? '${user.weight.toStringAsFixed(1)}kg' : '--',
                onTap: () => _showEditDialog(context, 'Current Weight', 'weight'),
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.height,
                label: 'Height',
                value: user != null ? _formatHeight(user.height) : '--',
                onTap: () => _showEditDialog(context, 'Height', 'height'),
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.calendar_today,
                label: 'Birthday',
                value: user != null ? _formatDate(user.dateOfBirth) : '--',
                onTap: () => _showDatePicker(context),
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.person,
                label: 'Gender',
                value: user != null ? _capitalize(user.gender) : '--',
                onTap: () => _showGenderPicker(context),
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.directions_run,
                label: 'Activity Level',
                value: 'Sedentary', // TODO: Add activity level to UserModel
                onTap: () => _showActivityLevelPicker(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing20,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      height: 1,
      color: AppColors.border,
    );
  }

  String _formatHeight(double height) {
    if (height == 0.0) return '--';
    // Height is stored in cm, convert to feet/inches
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
    // Already on this screen
  }

  void _showEditDialog(BuildContext context, String field, String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          decoration: InputDecoration(
            labelText: field,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Save feature coming soon!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Date picker coming soon!')),
    );
  }

  void _showGenderPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Male'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Female'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Other'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityLevelPicker(BuildContext context) {
    final levels = ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Activity Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: levels.map((level) => ListTile(
            title: Text(level),
            onTap: () => Navigator.pop(context),
          )).toList(),
        ),
      ),
    );
  }
}

