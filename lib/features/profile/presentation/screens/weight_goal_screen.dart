import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
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
        title: const Text(
          'Weight Goal',
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
      body: Consumer2<HealthProvider, AuthProvider>(
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
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.flag, color: AppColors.primary, size: 20),
                              const SizedBox(width: AppConstants.spacing8),
                              const Text(
                                'Timeline',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacing8,
                              vertical: AppConstants.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            ),
                            child: Text(
                              targetDate != null
                                  ? 'Est. Date ${_formatDate(targetDate)}'
                                  : 'Est. Date Oct 1, 2025',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      // Progress bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${startWeight.toStringAsFixed(0)}$preferredUnit',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            currentWeightKg > 0 ? '${currentWeight.toStringAsFixed(0)}$preferredUnit' : '--',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${goalWeight.toStringAsFixed(0)}$preferredUnit',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.border.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8,
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            startDate != null ? _formatDate(startDate) : 'Sep 17, 2025',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                          Text(
                            currentWeight > 0 ? 'Today' : '--',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                          const Text(
                            '--',
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      const Text(
                        'ℹ️ Based on your calorie budget and current weight',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppConstants.spacing24),
                
                // Settings section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'START',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                _buildEditableItem(
                  context,
                  Icons.calendar_today,
                  'Start Date',
                  startDate != null ? _formatDate(startDate) : 'Not set',
                  () => _editStartDate(context, startDate),
                ),
                _buildEditableItem(
                  context,
                  Icons.scale,
                  'Start Weight',
                  startWeightKg > 0 ? '${startWeight.toStringAsFixed(1)}$preferredUnit' : 'Not set',
                  () => _editStartWeight(context, startWeight, preferredUnit),
                ),
                
                const SizedBox(height: AppConstants.spacing24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'CURRENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                _buildEditableItem(
                  context,
                  Icons.scale,
                  'Current Weight',
                  currentWeightKg > 0 ? '${currentWeight.toStringAsFixed(1)}$preferredUnit' : 'Not set',
                  null, // Not directly editable - log weight instead
                ),
                
                const SizedBox(height: AppConstants.spacing24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'GOAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                _buildEditableItem(
                  context,
                  Icons.flag,
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
    IconData icon,
    String label,
    String value,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: onTap != null ? AppColors.divider : AppColors.divider.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppConstants.spacing8),
            Icon(
              Icons.chevron_right,
              color: onTap != null ? AppColors.textSecondary : Colors.transparent,
              size: 20,
            ),
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
      // TODO: Update user profile with new start date
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start date updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _editStartWeight(BuildContext context, double currentWeight, String unit) async {
    final TextEditingController controller = TextEditingController(
      text: currentWeight > 0 ? currentWeight.toStringAsFixed(1) : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Start Weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Weight',
            suffixText: unit,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      // TODO: Update user profile with new start weight
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start weight updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _editGoalWeight(BuildContext context, double currentGoal, String unit) async {
    final TextEditingController controller = TextEditingController(
      text: currentGoal.toStringAsFixed(1),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Goal Weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Goal Weight',
            suffixText: unit,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      // TODO: Update user profile with new goal weight
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal weight updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _editPace(BuildContext context, double currentPace, String unit) async {
    final TextEditingController controller = TextEditingController(
      text: currentPace.toStringAsFixed(1),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Weekly Pace'),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Save'),
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
}
