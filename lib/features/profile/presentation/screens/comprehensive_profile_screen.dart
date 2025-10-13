import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/dashboard_provider.dart';

class ComprehensiveProfileScreen extends StatefulWidget {
  const ComprehensiveProfileScreen({super.key});

  @override
  State<ComprehensiveProfileScreen> createState() => _ComprehensiveProfileScreenState();
}

class _ComprehensiveProfileScreenState extends State<ComprehensiveProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _medicationController;
  late TextEditingController _startingDoseController;
  late TextEditingController _frequencyController;
  late TextEditingController _motivationController;
  late TextEditingController _targetWeightController;
  late TextEditingController _primaryGoalController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final provider = context.read<DashboardProvider>();
    final user = provider.user;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _heightController = TextEditingController(text: user?.height?.toString() ?? '');
    _weightController = TextEditingController(text: user?.weight?.toString() ?? '');
    _medicationController = TextEditingController(text: user?.glp1Journey.medication ?? '');
    _startingDoseController = TextEditingController(text: user?.glp1Journey.startingDose ?? '');
    _frequencyController = TextEditingController(text: user?.glp1Journey.frequency ?? '');
    _motivationController = TextEditingController(text: user?.motivation ?? '');
    _targetWeightController = TextEditingController(text: user?.goals.targetWeight?.toString() ?? '');
    _primaryGoalController = TextEditingController(text: user?.goals.primaryGoal ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _medicationController.dispose();
    _startingDoseController.dispose();
    _frequencyController.dispose();
    _motivationController.dispose();
    _targetWeightController.dispose();
    _primaryGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEdit,
            ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => provider.loadDashboardData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = provider.user;
          if (user == null) {
            return const Center(child: Text('No user data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information Section
                _buildSectionHeader('Personal Information'),
                _buildPersonalInfoCard(user),
                
                const SizedBox(height: AppConstants.spacing24),
                
                // Physical Information Section
                _buildSectionHeader('Physical Information'),
                _buildPhysicalInfoCard(user),
                
                const SizedBox(height: AppConstants.spacing24),
                
                // GLP-1 Journey Section
                _buildSectionHeader('GLP-1 Journey'),
                _buildGlp1JourneyCard(user),
                
                const SizedBox(height: AppConstants.spacing24),
                
                // Goals Section
                _buildSectionHeader('Goals & Motivation'),
                _buildGoalsCard(user),
                
                const SizedBox(height: AppConstants.spacing24),
                
                // Concerns Section
                _buildSectionHeader('Concerns'),
                _buildConcernsCard(user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            _buildInfoRow('First Name', _firstNameController, 'firstName'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Last Name', _lastNameController, 'lastName'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Email', _emailController, 'email'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Date of Birth', 
              TextEditingController(text: user.dateOfBirth != null 
                ? '${user.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}'
                : 'Not set'), 'dateOfBirth'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Gender', 
              TextEditingController(text: user.gender ?? 'Not set'), 'gender'),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalInfoCard(dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            _buildInfoRow('Height', 
              TextEditingController(text: '${user.height ?? 0} ${user.preferredUnits?.height ?? 'cm'}'), 'height'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Weight', 
              TextEditingController(text: '${user.weight ?? 0} ${user.preferredUnits?.weight ?? 'kg'}'), 'weight'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Weight Unit', 
              TextEditingController(text: user.preferredUnits?.weight ?? 'kg'), 'weightUnit'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Height Unit', 
              TextEditingController(text: user.preferredUnits?.height ?? 'cm'), 'heightUnit'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Distance Unit', 
              TextEditingController(text: user.preferredUnits?.distance ?? 'km'), 'distanceUnit'),
          ],
        ),
      ),
    );
  }

  Widget _buildGlp1JourneyCard(dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            _buildInfoRow('Medication', _medicationController, 'medication'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Starting Dose', _startingDoseController, 'startingDose'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Current Dose', 
              TextEditingController(text: user.glp1Journey.currentDose ?? 'Not set'), 'currentDose'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Frequency', _frequencyController, 'frequency'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Injection Days', 
              TextEditingController(text: user.glp1Journey.injectionDays.join(', ')), 'injectionDays'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Start Date', 
              TextEditingController(text: user.glp1Journey.startDate != null 
                ? '${user.glp1Journey.startDate!.day}/${user.glp1Journey.startDate!.month}/${user.glp1Journey.startDate!.year}'
                : 'Not set'), 'startDate'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Is Active', 
              TextEditingController(text: user.glp1Journey.isActive ? 'Yes' : 'No'), 'isActive'),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsCard(dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            _buildInfoRow('Target Weight', 
              TextEditingController(text: '${user.goals.targetWeight ?? 0} ${user.preferredUnits?.weight ?? 'kg'}'), 'targetWeight'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Target Date', 
              TextEditingController(text: user.goals.targetDate != null 
                ? '${user.goals.targetDate!.day}/${user.goals.targetDate!.month}/${user.goals.targetDate!.year}'
                : 'Not set'), 'targetDate'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Primary Goal', _primaryGoalController, 'primaryGoal'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Secondary Goals', 
              TextEditingController(text: user.goals.secondaryGoals.join(', ')), 'secondaryGoals'),
            const SizedBox(height: AppConstants.spacing12),
            _buildInfoRow('Motivation', _motivationController, 'motivation', maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildConcernsCard(dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Concerns',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            if (user.concerns.isNotEmpty)
              Wrap(
                spacing: AppConstants.spacing8,
                runSpacing: AppConstants.spacing8,
                children: user.concerns.map((concern) => Chip(
                  label: Text(concern),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.primary),
                )).toList(),
              )
            else
              const Text(
                'No concerns listed',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, TextEditingController controller, String fieldKey, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacing16),
        Expanded(
          child: _isEditing && _isEditableField(fieldKey)
              ? TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing12,
                      vertical: AppConstants.spacing8,
                    ),
                  ),
                )
              : Text(
                  controller.text.isEmpty ? 'Not set' : controller.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
      ],
    );
  }

  bool _isEditableField(String fieldKey) {
    // Define which fields can be edited
    const editableFields = {
      'firstName', 'lastName', 'height', 'weight', 'medication', 
      'startingDose', 'frequency', 'motivation', 'targetWeight', 'primaryGoal'
    };
    return editableFields.contains(fieldKey);
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _initializeControllers(); // Reset to original values
    });
  }

  void _saveChanges() async {
    final provider = context.read<DashboardProvider>();
    
    // Here you would implement the API call to update the user profile
    // For now, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    
    setState(() {
      _isEditing = false;
    });
    
    // Reload data to get updated values
    await provider.loadDashboardData();
  }
}



