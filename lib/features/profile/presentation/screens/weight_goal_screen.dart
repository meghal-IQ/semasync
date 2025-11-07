import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/unit_converter.dart';

class WeightGoalScreen extends StatefulWidget {
  const WeightGoalScreen({super.key});

  @override
  State<WeightGoalScreen> createState() => _WeightGoalScreenState();
}

class _WeightGoalScreenState extends State<WeightGoalScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadWeightData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Weight Goal',
          style: AppTextStyles.title(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: () {
              // Add new entry
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer2<HealthProvider, AuthProvider>(
              builder: (context, healthProvider, authProvider, child) {
                final stats = healthProvider.weightStats;
                final user = authProvider.user;
                final preferredUnit = user?.preferredUnits.weight ?? 'kg';
          
          // Backend data in kg
          final startWeightKg = user?.weight ?? stats?.startingWeight ?? 0;
          final currentWeightKg = stats?.currentWeight ?? 0;
          final goalWeightKg = user?.goals.targetWeight ?? 91.3;
          final targetDate = user?.goals.targetDate;
          final startDate = user?.glp1Journey.startDate ?? stats?.firstEntryDate;
          
          // Convert to preferred unit for display
          final startWeight = UnitConverter.convertWeight(startWeightKg, preferredUnit);
          final currentWeight = UnitConverter.convertWeight(currentWeightKg, preferredUnit);
          final goalWeight = UnitConverter.convertWeight(goalWeightKg, preferredUnit);
          
          double progress = 0.0;
          if (startWeightKg > 0 && goalWeightKg > 0 && currentWeightKg > 0) {
            final totalChange = (goalWeightKg - startWeightKg).abs();
            final currentChange = (currentWeightKg - startWeightKg).abs();
            progress = totalChange > 0 ? (currentChange / totalChange).clamp(0, 1) : 0;
          }

          // Calculate weekly pace - convert to preferred unit
          final weeklyPaceKg = _calculateWeeklyPace(stats?.weekChange ?? 0);
          final weeklyPace = UnitConverter.convertWeight(weeklyPaceKg, preferredUnit);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              children: [
                // Timeline Card
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/injection_site.png',
                                width: 20,
                                height: 20,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: AppConstants.spacing8),
                              Text(
                                'TimeLine',
                                style: AppTextStyles.title(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                            ),
                            child: Text(
                              targetDate != null
                                  ? 'Est. Date ${_formatDateForTimeline(targetDate)}'
                                  : 'Est. Date Oct 14, 2025',
                              style: AppTextStyles.text(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      // Progress bar with weight labels
                      Stack(
                        children: [
                          // Weight labels above progress bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${startWeight.toStringAsFixed(1)}$preferredUnit',
                                style: AppTextStyles.text(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                currentWeightKg > 0 ? '${currentWeight.toStringAsFixed(1)}$preferredUnit' : '--',
                                style: AppTextStyles.title(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${goalWeight.toStringAsFixed(1)}$preferredUnit',
                                style: AppTextStyles.text(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.lightGrey,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A34D7)),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            startDate != null ? _formatDateForTimeline(startDate) : 'Sep 17, 2025',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                          ),
                          Text(
                            currentWeight > 0 ? 'Today, 6:18 PM' : 'Today',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppConstants.spacing24),
                
                // Start section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Start',
                    style: AppTextStyles.subtitle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                _buildEditableItem(
                  context,
                  'assets/images/calender.png',
                  'Starting Date',
                  startDate != null ? _formatDate(startDate) : 'Not set',
                  () => _editStartDate(context, startDate),
                ),
                const SizedBox(height: AppConstants.spacing8),
                _buildEditableItem(
                  context,
                  'assets/images/calender.png',
                  'Start Weight',
                  startWeightKg > 0 ? '${startWeight.toStringAsFixed(1)}$preferredUnit' : 'Not set',
                  () => _editStartWeight(context, startWeight, preferredUnit),
                ),
                
                const SizedBox(height: AppConstants.spacing24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Current',
                    style: AppTextStyles.subtitle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                _buildEditableItem(
                  context,
                  'assets/images/calender.png',
                  'Current Weight',
                  currentWeightKg > 0 ? '${currentWeight.toStringAsFixed(1)}$preferredUnit' : 'Not set',
                  null, // Not directly editable - log weight instead
                ),
                
                const SizedBox(height: AppConstants.spacing24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Goal',
                    style: AppTextStyles.subtitle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                _buildEditableItem(
                  context,
                  'assets/images/calender.png',
                  'Goal Weight',
                  '${goalWeight.toStringAsFixed(1)}$preferredUnit',
                  () => _editGoalWeight(context, goalWeight, preferredUnit),
                ),
                // _buildEditableItem(
                //   context,
                //   Icons.directions_walk,
                //   'Pace',
                //   '${weeklyPace.toStringAsFixed(1)}$preferredUnit',
                //   () => _editPace(context, weeklyPace, preferredUnit),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditableItem(
    BuildContext context,
    String imagePath,
    String label,
    String value,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 20,
              height: 20,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.text(
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.title(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppConstants.spacing8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _editStartDate(BuildContext context, DateTime? currentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
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
      final user = authProvider.user;
      
      if (user != null) {
        // Update glp1Journey.startDate
        final success = await authProvider.updateProfile({
          'glp1Journey': {
            ...user.glp1Journey.toJson(),
            'startDate': picked.toIso8601String(),
          },
        });
        
        setState(() => _isLoading = false);
        
        if (success && mounted) {
          // Refresh health data to get updated stats
          await context.read<HealthProvider>().loadWeightData();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Start date updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Failed to update start date'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editStartWeight(BuildContext context, double currentWeight, String unit) async {
    final TextEditingController controller = TextEditingController(
      text: currentWeight > 0 ? currentWeight.toStringAsFixed(1) : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Start Weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Weight',
            suffixText: unit,
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
            child: Text('Save', style: AppTextStyles.title(color: AppColors.surface),),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      
      // Convert to kg for API
      final weightInKg = UnitConverter.convertWeightToKg(result, unit);
      
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.updateProfile({'weight': weightInKg});
      
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        // Refresh health data to get updated stats
        await context.read<HealthProvider>().loadWeightData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Start weight updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to update start weight'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editGoalWeight(BuildContext context, double currentGoal, String unit) async {
    final TextEditingController controller = TextEditingController(
      text: currentGoal.toStringAsFixed(1),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Goal Weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Goal Weight',
            suffixText: unit,
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
              backgroundColor: AppColors.primary
            ),
            child: Text('Save', style: AppTextStyles.title(color: AppColors.surface),),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      
      // Convert to kg for API
      final weightInKg = UnitConverter.convertWeightToKg(result, unit);
      
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      
      if (user != null) {
        // Update goals.targetWeight
        final success = await authProvider.updateProfile({
          'goals': {
            ...user.goals.toJson(),
            'targetWeight': weightInKg,
          },
        });
        
        setState(() => _isLoading = false);
        
        if (success && mounted) {
          // Refresh health data to get updated stats
          await context.read<HealthProvider>().loadWeightData();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Goal weight updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Failed to update goal weight'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editPace(BuildContext context, double currentPace, String unit) async {
    final TextEditingController controller = TextEditingController(
      text: currentPace.toStringAsFixed(1),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Weekly Pace'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Weekly Target',
            suffixText: '$unit/week',
            border: const OutlineInputBorder(),
            helperText: 'How much weight do you want to lose per week?',
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
              Navigator.pop(context, value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      // TODO: Update user profile with new pace
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pace updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  double _calculateWeeklyPace(double weekChange) {
    // If we have weekly change data, use the absolute value
    if (weekChange.abs() > 0) {
      return weekChange.abs();
    }
    // Default to 1.6kg per week
    return 1.6;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return '$month/$day/$year';
  }

  String _formatDateForTimeline(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
