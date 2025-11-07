import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_text_styles.dart';

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
              title: Text('Unsaved Changes'),
              content: Text('Do you want to save your changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Discard'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text('Save'),
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
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Units',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.title(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (_hasChanges)
                      TextButton(
                        onPressed: _isLoading ? null : _saveSettings,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'Save',
                                style: AppTextStyles.title(
                                  color: Color(0xFF6A34D7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      )
                    else
                      const SizedBox(width: 64), // Placeholder for centering
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
            _buildSectionHeader('Settings'),
            _buildSegmentedControl(
              option1: 'Pounds (lbs)',
              option2: 'Kilogram (kg)',
              value1: 'lbs',
              value2: 'kg',
              currentValue: _weightUnit,
              onChanged: (val) {
                setState(() {
                  _weightUnit = val;
                  _hasChanges = true;
                });
              },
            ),
            
            const SizedBox(height: AppConstants.spacing24),
            _buildSectionHeader('Height'),
            _buildSegmentedControl(
              option1: 'Feet/Inches (ft/in)',
              option2: 'Centimeter (cm)',
              value1: 'ft',
              value2: 'cm',
              currentValue: _heightUnit,
              onChanged: (val) {
                setState(() {
                  _heightUnit = val;
                  _hasChanges = true;
                });
              },
            ),
            
            const SizedBox(height: AppConstants.spacing24),
            _buildSectionHeader('Water'),
            _buildSegmentedControl(
              option1: 'Ounces (oz)',
              option2: 'Millilitre (ml)',
              value1: 'oz',
              value2: 'ml',
              currentValue: _waterUnit,
              onChanged: (val) {
                setState(() {
                  _waterUnit = val;
                  _hasChanges = true;
                });
              },
            ),
          ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacing12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl({
    required String option1,
    required String option2,
    required String value1,
    required String value2,
    required String currentValue,
    required Function(String) onChanged,
  }) {
    final isFirstSelected = currentValue == value1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6A34D7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isFirstSelected ? const Color(0xFF6A34D7) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    bottomLeft: Radius.circular(11),
                  ),
                ),
                child: Center(
                  child: Text(
                    option1,
                    style: AppTextStyles.title(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isFirstSelected ? Colors.white : const Color(0xFF6A34D7),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isFirstSelected ? const Color(0xFF6A34D7) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(11),
                    bottomRight: Radius.circular(11),
                  ),
                ),
                child: Center(
                  child: Text(
                    option2,
                    style: AppTextStyles.title(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: !isFirstSelected ? Colors.white : const Color(0xFF6A34D7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
