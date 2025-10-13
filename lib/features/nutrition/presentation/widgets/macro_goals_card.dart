import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class MacroGoalsCard extends StatelessWidget {
  const MacroGoalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Macro Goals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Today',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      color: AppColors.proteinOrange,
                      value: 35,
                      title: '35%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppColors.fiberGreen,
                      value: 45,
                      title: '45%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppColors.waterBlue,
                      value: 20,
                      title: '20%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              children: [
                Expanded(
                  child: _buildMacroItem(
                    label: 'Protein',
                    value: '89g',
                    target: '120g',
                    color: AppColors.proteinOrange,
                    progress: 0.74,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: _buildMacroItem(
                    label: 'Carbs',
                    value: '156g',
                    target: '200g',
                    color: AppColors.fiberGreen,
                    progress: 0.78,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              children: [
                Expanded(
                  child: _buildMacroItem(
                    label: 'Fat',
                    value: '42g',
                    target: '60g',
                    color: AppColors.waterBlue,
                    progress: 0.70,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: _buildMacroItem(
                    label: 'Fiber',
                    value: '18g',
                    target: '25g',
                    color: AppColors.success,
                    progress: 0.72,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  const Expanded(
                    child: Text(
                      'Try adding lean protein sources like chicken breast or Greek yogurt.',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem({
    required String label,
    required String value,
    required String target,
    required Color color,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '$value / $target',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}




