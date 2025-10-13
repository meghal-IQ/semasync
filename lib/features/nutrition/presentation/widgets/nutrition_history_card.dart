import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class NutritionHistoryCard extends StatelessWidget {
  const NutritionHistoryCard({super.key});

  List<FlSpot> _generateCalorieData() {
    return [
      const FlSpot(0, 1.8),
      const FlSpot(1, 1.6),
      const FlSpot(2, 1.9),
      const FlSpot(3, 1.7),
      const FlSpot(4, 2.1),
      const FlSpot(5, 1.5),
      const FlSpot(6, 1.2),
    ];
  }

  List<FlSpot> _generateProteinData() {
    return [
      const FlSpot(0, 0.12),
      const FlSpot(1, 0.11),
      const FlSpot(2, 0.13),
      const FlSpot(3, 0.10),
      const FlSpot(4, 0.14),
      const FlSpot(5, 0.09),
      const FlSpot(6, 0.08),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final calorieSpots = _generateCalorieData();
    final proteinSpots = _generateProteinData();

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
                  'Nutrition Trends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Last 7 days',
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
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.divider,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.5,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}k',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 2.5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: calorieSpots,
                      isCurved: true,
                      color: AppColors.proteinOrange,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.proteinOrange.withOpacity(0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: proteinSpots,
                      isCurved: true,
                      color: AppColors.fiberGreen,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.fiberGreen.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              children: [
                _buildLegendItem(
                  color: AppColors.proteinOrange,
                  label: 'Calories (k)',
                ),
                const SizedBox(width: AppConstants.spacing24),
                _buildLegendItem(
                  color: AppColors.fiberGreen,
                  label: 'Protein (g)',
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'Avg Calories',
                    value: '1,700',
                    color: AppColors.proteinOrange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    label: 'Avg Protein',
                    value: '110g',
                    color: AppColors.fiberGreen,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    label: 'Goal Days',
                    value: '5/7',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppConstants.spacing8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppConstants.spacing4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}




