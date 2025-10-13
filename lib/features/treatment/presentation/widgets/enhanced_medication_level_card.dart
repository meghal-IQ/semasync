import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/medication_level_provider.dart';

class EnhancedMedicationLevelCard extends StatefulWidget {
  const EnhancedMedicationLevelCard({super.key});

  @override
  State<EnhancedMedicationLevelCard> createState() => _EnhancedMedicationLevelCardState();
}

class _EnhancedMedicationLevelCardState extends State<EnhancedMedicationLevelCard> {
  @override
  void initState() {
    super.initState();
    // Load medication level data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MedicationLevelProvider>(context, listen: false);
      provider.loadCurrentMedicationLevel();
      provider.loadHistoricalData(days: 7, includePredictions: true);
      provider.loadTrends(days: 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationLevelProvider>(
      builder: (context, provider, child) {
        final currentLevel = provider.currentLevelPercentage;
        final status = provider.currentStatus;
        final countdown = provider.countdownString;
        final isOverdue = provider.isOverdue;
        final historicalData = provider.historicalData;
        final trends = provider.trends;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with current level and status
                _buildHeader(currentLevel, status, countdown, isOverdue),
                const SizedBox(height: AppConstants.spacing16),
                
                // Current level indicator
                _buildCurrentLevelIndicator(currentLevel, status),
                const SizedBox(height: AppConstants.spacing16),
                
                // Chart if data is available
                if (historicalData != null && historicalData.historicalLevels.isNotEmpty)
                  _buildChart(historicalData, provider)
                else if (currentLevel > 0)
                  _buildSimpleLevelDisplay(currentLevel, status)
                else
                  _buildNoDataMessage(),
                
                const SizedBox(height: AppConstants.spacing16),
                
                // Analytics summary
                // if (trends != null)
                //   _buildAnalyticsSummary(trends, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double currentLevel, String status, String countdown, bool isOverdue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medication Level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              currentLevel > 0 ? '${currentLevel.toStringAsFixed(1)}%' : 'No Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: currentLevel > 0 ? _getStatusColor(status) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing12,
                vertical: AppConstants.spacing4,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
              ),
              child: Text(
                _getStatusLabel(status),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              countdown,
              style: TextStyle(
                fontSize: 12,
                color: isOverdue ? AppColors.error : AppColors.textSecondary,
                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentLevelIndicator(double currentLevel, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Current Level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${currentLevel.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing8),
        ClipRRect(
          child: LinearProgressIndicator(
            value: currentLevel / 100,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(medicationLevelData, MedicationLevelProvider provider) {
    final chartData = provider.getChartData();
    final shotEvents = provider.getShotEvents();

    if (chartData.isEmpty) return _buildNoDataMessage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '7-Day Trend',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing12),
        SizedBox(
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (chartData.length > value.toInt()) {
                        final date = DateTime.fromMillisecondsSinceEpoch(chartData[value.toInt()]['x']);
                        return Text(
                          DateFormat('M/d').format(date),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (chartData.length - 1).toDouble(),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: chartData.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value['y']);
                  }).toList(),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.3),
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primary.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Shot events as markers
                if (shotEvents.isNotEmpty)
                  LineChartBarData(
                    spots: shotEvents.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), 100);
                    }).toList(),
                    isCurved: false,
                    color: AppColors.error,
                    barWidth: 0,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.error,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSummary(trends, MedicationLevelProvider provider) {
    final analytics = trends.analytics;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getTrendIcon(analytics.trendDirection),
                size: 16,
                color: _getTrendColor(analytics.trendDirection),
              ),
              const SizedBox(width: AppConstants.spacing4),
              Text(
                'Trend: ${_getTrendLabel(analytics.trendDirection)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getTrendColor(analytics.trendDirection),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Avg', '${analytics.averageLevel.toStringAsFixed(1)}%'),
              _buildStatItem('Min', '${analytics.minLevel.toStringAsFixed(1)}%'),
              _buildStatItem('Max', '${analytics.maxLevel.toStringAsFixed(1)}%'),
              _buildStatItem('Stability', '${analytics.levelStability.toStringAsFixed(1)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataMessage() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      decoration: BoxDecoration(
        color: AppColors.surface,
      ),
      child: const Center(
        child: Text(
          'No medication level data available.\nLog your first shot to start tracking.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleLevelDisplay(double currentLevel, String status) {
    return Container(
      // padding: const EdgeInsets.all(AppConstants.spacing24),
      // decoration: BoxDecoration(
      //   color: _getStatusColor(status).withOpacity(0.1),
      //   borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      // ),
      // child: Column(
      //   children: [
      //     Icon(
      //       Icons.medical_services,
      //       size: 48,
      //       color: _getStatusColor(status),
      //     ),
      //     const SizedBox(height: AppConstants.spacing12),
      //     Text(
      //       '${currentLevel.toStringAsFixed(1)}%',
      //       style: TextStyle(
      //         fontSize: 32,
      //         fontWeight: FontWeight.bold,
      //         color: _getStatusColor(status),
      //       ),
      //     ),
      //     const SizedBox(height: AppConstants.spacing8),
      //     const Text(
      //       'Current Medication Level',
      //       style: TextStyle(
      //         fontSize: 14,
      //         fontWeight: FontWeight.w500,
      //         color: AppColors.textPrimary,
      //       ),
      //     ),
      //     const SizedBox(height: AppConstants.spacing4),
      //     const Text(
      //       'Chart will appear after multiple shots',
      //       style: TextStyle(
      //         fontSize: 12,
      //         color: AppColors.textSecondary,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'optimal':
        return AppColors.success;
      case 'declining':
        return AppColors.warning;
      case 'low':
        return AppColors.error;
      case 'overdue':
        return AppColors.error;
      case 'no_data':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'optimal':
        return 'Optimal';
      case 'declining':
        return 'Declining';
      case 'low':
        return 'Low';
      case 'overdue':
        return 'Overdue';
      case 'no_data':
        return 'No Data';
      default:
        return 'Unknown';
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'increasing':
        return Icons.trending_up;
      case 'decreasing':
        return Icons.trending_down;
      case 'stable':
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'increasing':
        return AppColors.success;
      case 'decreasing':
        return AppColors.warning;
      case 'stable':
      default:
        return AppColors.textSecondary;
    }
  }

  String _getTrendLabel(String trend) {
    switch (trend) {
      case 'increasing':
        return 'Rising';
      case 'decreasing':
        return 'Falling';
      case 'stable':
      default:
        return 'Stable';
    }
  }
}
