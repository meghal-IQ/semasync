import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semasync_new/core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/unit_converter.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Personal Details',
          style: AppTextStyles.title(
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
          
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          debugPrint('🔍 Personal Details - User: $user');
          if (user != null) {
            debugPrint('🔍 Personal Details - Weight: ${user.weight}, Height: ${user.height}, Gender: ${user.gender}');
          }
          
          final preferredWeightUnit = user?.preferredUnits.weight ?? 'kg';
          final displayWeight = user != null && user.weight > 0 
              ? UnitConverter.formatWeight(user.weight, preferredWeightUnit)
              : '--';
          
          return ListView(
            children: [
              _buildDetailItem(
                icon: Icons.scale_outlined,
                label: 'Current Weight',
                value: displayWeight,
                onTap: () => _showWeightEditDialog(context, user, preferredWeightUnit),
              ),
              _buildDetailItem(
                icon: Icons.height,
                label: 'Height',
                value: user != null ? _formatHeight(user.height) : '--',
                onTap: () => _showHeightEditDialog(context, user),
              ),
              _buildDetailItem(
                icon: Icons.calendar_today_outlined,
                label: 'Birthday',
                value: user != null ? _formatDate(user.dateOfBirth) : '--',
                onTap: () => _showDatePicker(context, user),
              ),
              _buildDetailItem(
                icon: Icons.person_2_outlined,
                label: 'Gender',
                value: user != null ? _capitalize(user.gender) : '--',
                onTap: () => _showGenderPicker(context, user),
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
        decoration: BoxDecoration(
            color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12)
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing12,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing6,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 18),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.title(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    value,
                    style: AppTextStyles.title(
                      fontSize: 16,
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

  Future<void> _showWeightEditDialog(BuildContext context, user, String preferredUnit) async {
    final currentWeight = user?.weight ?? 0.0;
    final displayWeight = currentWeight > 0 
        ? UnitConverter.convertWeight(currentWeight, preferredUnit)
        : 0.0;
    
    final controller = TextEditingController(
      text: displayWeight > 0 ? displayWeight.toStringAsFixed(1) : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Current Weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Weight',
            suffixText: preferredUnit,
            border: const OutlineInputBorder(),
            helperText: 'Weight is stored in kg in the database',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Save', style: AppTextStyles.title(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      
      // Convert to kg for API
      final weightInKg = UnitConverter.convertWeightToKg(result, preferredUnit);
      
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.updateProfile({'weight': weightInKg});
      
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weight updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to update weight'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showHeightEditDialog(BuildContext context, user) async {
    final currentHeightCm = user?.height ?? 0.0;
    final totalInches = currentHeightCm > 0 ? currentHeightCm * 0.393701 : 0.0;
    final feet = totalInches > 0 ? (totalInches ~/ 12) : 0;
    final inches = totalInches > 0 ? ((totalInches % 12).round()) : 0;
    
    final feetController = TextEditingController(text: feet > 0 ? feet.toString() : '');
    final inchesController = TextEditingController(text: inches > 0 ? inches.toString() : '');

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Height'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: feetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Feet',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: inchesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Inches',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Height is stored in cm in the database',
              style: AppTextStyles.title(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final feetValue = int.tryParse(feetController.text);
              final inchesValue = int.tryParse(inchesController.text);
              if (feetValue != null && inchesValue != null && feetValue >= 0 && inchesValue >= 0 && inchesValue < 12) {
                Navigator.pop(context, {'feet': feetValue, 'inches': inchesValue});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Save', style: AppTextStyles.title(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      
      // Convert feet and inches to cm
      final totalInches = (result['feet']! * 12) + result['inches']!;
      final heightInCm = totalInches * 2.54;
      
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.updateProfile({'height': heightInCm});
      
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Height updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to update height'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDatePicker(BuildContext context, user) async {
    final currentDate = user?.dateOfBirth ?? DateTime.now();
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _isLoading = true);
      
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.updateProfile({
        'dateOfBirth': picked.toIso8601String(),
      });
      
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Date of birth updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to update date of birth'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showGenderPicker(BuildContext context, user) async {
    final currentGender = user?.gender ?? 'male';
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Male'),
              leading: Radio<String>(
                value: 'male',
                groupValue: currentGender,
                onChanged: (value) => Navigator.pop(context, value),
              ),
              onTap: () => Navigator.pop(context, 'male'),
            ),
            ListTile(
              title: Text('Female'),
              leading: Radio<String>(
                value: 'female',
                groupValue: currentGender,
                onChanged: (value) => Navigator.pop(context, value),
              ),
              onTap: () => Navigator.pop(context, 'female'),
            ),
            ListTile(
              title: Text('Other'),
              leading: Radio<String>(
                value: 'other',
                groupValue: currentGender,
                onChanged: (value) => Navigator.pop(context, value),
              ),
              onTap: () => Navigator.pop(context, 'other'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.updateProfile({'gender': result});
      
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gender updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to update gender'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

