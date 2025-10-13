import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';

class UnitsSettingsScreen extends StatefulWidget {
  const UnitsSettingsScreen({super.key});

  @override
  State<UnitsSettingsScreen> createState() => _UnitsSettingsScreenState();
}

class _UnitsSettingsScreenState extends State<UnitsSettingsScreen> {
  String _weightUnit = 'kg';
  String _heightUnit = 'ft';
  String _waterUnit = 'ml';
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    // Use addPostFrameCallback to access context safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null && mounted) {
        setState(() {
          _weightUnit = user.preferredUnits.weight;
          _heightUnit = user.preferredUnits.height;
          // Water unit is derived from distance preference
          _waterUnit = 'ml'; // Default for now
        });
      }
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      
      // Update user profile with new units
      final updates = {
        'preferredUnits': {
          'weight': _weightUnit,
          'height': _heightUnit,
          'distance': _waterUnit == 'ml' ? 'km' : 'miles',
        },
      };

      final success = await authProvider.updateProfile(updates);

      if (success && mounted) {
        setState(() {
          _hasChanges = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Units updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload user data to refresh all screens
        await authProvider.loadCurrentUser();
        
        // Pop back to previous screen
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update units'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          final shouldSave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text('Do you want to save your changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Discard'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          );

          if (shouldSave == true) {
            await _saveSettings();
            return false; // Don't pop, saveSettings will handle it
          }
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Units',
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
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveSettings,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
          ],
        ),
        body: ListView(
          children: [
            _buildSectionHeader('WEIGHT'),
            _buildUnitOption('Pounds (lbs)', 'lbs', _weightUnit, (val) {
              setState(() {
                _weightUnit = val;
                _hasChanges = true;
              });
            }),
            _buildUnitOption('Kilogram (kg)', 'kg', _weightUnit, (val) {
              setState(() {
                _weightUnit = val;
                _hasChanges = true;
              });
            }),
            
            const SizedBox(height: AppConstants.spacing24),
            _buildSectionHeader('HEIGHT'),
            _buildUnitOption('Feet/Inches (ft/in)', 'ft', _heightUnit, (val) {
              setState(() {
                _heightUnit = val;
                _hasChanges = true;
              });
            }),
            _buildUnitOption('Centimeter (cm)', 'cm', _heightUnit, (val) {
              setState(() {
                _heightUnit = val;
                _hasChanges = true;
              });
            }),
            
            const SizedBox(height: AppConstants.spacing24),
            _buildSectionHeader('WATER'),
            _buildUnitOption('Ounces (oz)', 'oz', _waterUnit, (val) {
              setState(() {
                _waterUnit = val;
                _hasChanges = true;
              });
            }),
            _buildUnitOption('Millilitre (ml)', 'ml', _waterUnit, (val) {
              setState(() {
                _waterUnit = val;
                _hasChanges = true;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildUnitOption(String title, String value, String currentValue, Function(String) onTap) {
    final isSelected = value == currentValue;
    
    return InkWell(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
