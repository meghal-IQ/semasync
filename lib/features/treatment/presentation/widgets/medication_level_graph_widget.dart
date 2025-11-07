import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/medication_level_provider.dart';
import '../../../../core/providers/treatment_provider.dart';

class MedicationLevelGraphWidget extends StatefulWidget {
  const MedicationLevelGraphWidget({super.key});

  @override
  State<MedicationLevelGraphWidget> createState() => _MedicationLevelGraphWidgetState();
}

class _MedicationLevelGraphWidgetState extends State<MedicationLevelGraphWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<MedicationLevelProvider, TreatmentProvider>(
      builder: (context, medicationProvider, treatmentProvider, child) {
        final currentLevel = medicationProvider.currentLevelPercentage;
        final historicalData = medicationProvider.historicalData;
        final chartData = medicationProvider.getChartData();
        final shotEvents = medicationProvider.getShotEvents();
        
        // Get medication information from treatment provider
        final lastShot = treatmentProvider.latestShot;
        final nextShot = treatmentProvider.nextShotInfo;
        
        // Debug information
        print('🔍 MedicationLevelGraphWidget Debug:');
        print('  - Current Level: $currentLevel');
        print('  - Historical Data: ${historicalData != null ? 'Available' : 'Null'}');
        print('  - Chart Data Length: ${chartData.length}');
        print('  - Shot Events Length: ${shotEvents.length}');
        print('  - Last Shot: ${lastShot != null ? 'Available' : 'Null'}');
        if (lastShot != null) {
          print('  - Last Shot Details: ${lastShot.medication}, ${lastShot.dosage}, ${lastShot.date}');
        }
        
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
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
                // Header with medication info
                _buildHeader(lastShot, nextShot),
                const SizedBox(height: AppConstants.spacing16),
                
                // 7-Day Body Dose Calculation
                _buildSevenDayBodyDoseCard(lastShot, currentLevel),
                const SizedBox(height: AppConstants.spacing16),
                
                // Chart or fallback calculation
                if (chartData.isNotEmpty)
                  _buildChart(chartData, shotEvents)
                else if (lastShot != null && currentLevel > 0)
                  _buildFallbackChart(lastShot, currentLevel)
                else
                  _buildNoDataMessage(),
                
                const SizedBox(height: AppConstants.spacing16),
                
                // Previous Days Levels
                if (chartData.isNotEmpty)
                  _buildPreviousDaysLevels(chartData)
                else if (lastShot != null)
                  _buildFallbackPreviousDays(lastShot, currentLevel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(dynamic lastShot, dynamic nextShot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medication Level Graph',
          style: AppTextStyles.title(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        if (lastShot != null) ...[
          Text(
            'Medication: ${lastShot.medication}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            'Dosage: ${lastShot.dosage}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSevenDayBodyDoseCard(dynamic lastShot, double currentLevel) {
    if (lastShot == null) return const SizedBox.shrink();
    
    // Calculate 7-day body dose based on Mounjaro® pharmacokinetics
    // Mounjaro® (tirzepatide) has a half-life of approximately 5 days
    final dosage = double.tryParse(lastShot.dosage.replaceAll('mg', '')) ?? 0.25;
    final sevenDayBodyDose = _calculateSevenDayBodyDose(dosage);
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppConstants.spacing8),
              Text(
                '7-Day Body Dose Calculation',
                style: AppTextStyles.title(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'Based on Mounjaro® (tirzepatide) pharmacokinetics:',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            '• Half-life: ~5 days',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '• Current dose: ${dosage}mg',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '• Estimated 7-day body dose: ${sevenDayBodyDose.toStringAsFixed(2)}mg',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            'This represents the cumulative medication remaining in your body over a 7-day period.',
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> chartData, List<Map<String, dynamic>> shotEvents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '7-Day Medication Level Trend',
          style: AppTextStyles.title(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing12),
        SizedBox(
          height: 200,
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
                      return Text('');
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
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
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
                          radius: 5,
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
        const SizedBox(height: AppConstants.spacing8),
        Row(
          children: [
            _buildLegendItem('Medication Level', AppColors.primary),
            const SizedBox(width: AppConstants.spacing16),
            _buildLegendItem('Shot Events', AppColors.error),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
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
        const SizedBox(width: AppConstants.spacing4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviousDaysLevels(List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty) return const SizedBox.shrink();
    
    // Get last 7 days of data
    final lastSevenDays = chartData.take(7).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Previous Days Levels',
          style: AppTextStyles.title(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        ...lastSevenDays.map((dayData) {
          final date = DateTime.fromMillisecondsSinceEpoch(dayData['x']);
          final level = dayData['y'];
          final status = dayData['status'] ?? 'optimal';
          
          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
            padding: const EdgeInsets.all(AppConstants.spacing12),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor(status).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy').format(date),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE').format(date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${level.toStringAsFixed(1)}%',
                      style: AppTextStyles.title(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                    Text(
                      _getStatusLabel(status),
                      style: AppTextStyles.title(
                        fontSize: 10,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFallbackChart(dynamic lastShot, double currentLevel) {
    // Generate chart data based on shot information
    final chartData = _generateFallbackChartData(lastShot, currentLevel);
    final shotEvents = [{
      'x': lastShot.date.millisecondsSinceEpoch,
      'y': 100,
      'medication': lastShot.medication,
      'dosage': lastShot.dosage,
    }];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '7-Day Medication Level Trend',
              style: AppTextStyles.title(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppConstants.spacing8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing8,
                vertical: AppConstants.spacing2,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Calculated',
                style: AppTextStyles.title(
                  fontSize: 10,
                  color: AppColors.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing12),
        SizedBox(
          height: 200,
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
                      return Text('');
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
                      AppColors.warning,
                      AppColors.warning.withOpacity(0.3),
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.warning,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning.withOpacity(0.3),
                        AppColors.warning.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Shot events as markers
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
                        radius: 5,
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
        const SizedBox(height: AppConstants.spacing8),
        Row(
          children: [
            _buildLegendItem('Calculated Level', AppColors.warning),
            const SizedBox(width: AppConstants.spacing16),
            _buildLegendItem('Shot Events', AppColors.error),
          ],
        ),
        const SizedBox(height: AppConstants.spacing8),
        Container(
          padding: const EdgeInsets.all(AppConstants.spacing8),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Note: This chart shows calculated medication levels based on pharmacokinetic principles. Historical data will appear after multiple shots.',
            style: AppTextStyles.title(
              fontSize: 11,
              color: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackPreviousDays(dynamic lastShot, double currentLevel) {
    // Generate previous days data based on shot information
    final previousDays = _generateFallbackPreviousDays(lastShot, currentLevel);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Previous Days Levels',
              style: AppTextStyles.title(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppConstants.spacing8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing8,
                vertical: AppConstants.spacing2,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Calculated',
                style: AppTextStyles.title(
                  fontSize: 10,
                  color: AppColors.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing8),
        ...previousDays.map((dayData) {
          final date = DateTime.fromMillisecondsSinceEpoch(dayData['x']);
          final level = dayData['y'];
          final status = dayData['status'] ?? 'optimal';
          
          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
            padding: const EdgeInsets.all(AppConstants.spacing12),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor(status).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy').format(date),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE').format(date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${level.toStringAsFixed(1)}%',
                      style: AppTextStyles.title(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                    Text(
                      _getStatusLabel(status),
                      style: AppTextStyles.title(
                        fontSize: 10,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  List<Map<String, dynamic>> _generateFallbackChartData(dynamic lastShot, double currentLevel) {
    final List<Map<String, dynamic>> chartData = [];
    final shotDate = lastShot.date;
    final medication = lastShot.medication;
    
    // Get half-life based on medication
    final halfLifeHours = _getHalfLifeHours(medication);
    
    // Generate 7 days of data
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(shotDate.year, shotDate.month, shotDate.day).subtract(Duration(days: i));
      final hoursSinceShot = shotDate.difference(date).inHours;
      
      // Calculate level using exponential decay
      double level = 0;
      if (hoursSinceShot >= 0) {
        level = 100 * (0.5 * (hoursSinceShot / halfLifeHours));
        level = level.clamp(0, 100);
      }
      
      chartData.add({
        'x': date.millisecondsSinceEpoch,
        'y': level,
        'status': _getLevelStatus(level),
      });
    }
    
    return chartData;
  }

  List<Map<String, dynamic>> _generateFallbackPreviousDays(dynamic lastShot, double currentLevel) {
    final List<Map<String, dynamic>> previousDays = [];
    final shotDate = lastShot.date;
    final medication = lastShot.medication;
    
    // Get half-life based on medication
    final halfLifeHours = _getHalfLifeHours(medication);
    
    // Generate last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(shotDate.year, shotDate.month, shotDate.day).subtract(Duration(days: i));
      final hoursSinceShot = shotDate.difference(date).inHours;
      
      // Calculate level using exponential decay
      double level = 0;
      if (hoursSinceShot >= 0) {
        level = 100 * (0.5 * (hoursSinceShot / halfLifeHours));
        level = level.clamp(0, 100);
      }
      
      previousDays.add({
        'x': date.millisecondsSinceEpoch,
        'y': level,
        'status': _getLevelStatus(level),
      });
    }
    
    return previousDays;
  }

  double _getHalfLifeHours(String medication) {
    switch (medication) {
      case 'Mounjaro®':
      case 'Zepbound®':
      case 'Compounded Tirzepatide':
        return 120; // 5 days
      case 'Ozempic®':
      case 'Wegovy®':
      case 'Compounded Semaglutide':
        return 168; // 7 days
      case 'Trulicity®':
        return 120; // 5 days
      default:
        return 120; // Default to 5 days
    }
  }

  String _getLevelStatus(double level) {
    if (level >= 60) return 'optimal';
    if (level >= 30) return 'declining';
    if (level > 0) return 'low';
    return 'overdue';
  }

  Widget _buildNoDataMessage() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppConstants.spacing12),
            Text(
              'No medication level data available',
              textAlign: TextAlign.center,
              style: AppTextStyles.title(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppConstants.spacing4),
            Text(
              'Log your first shot to start tracking medication levels',
              textAlign: TextAlign.center,
              style: AppTextStyles.title(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateSevenDayBodyDose(double dosage) {
    // Mounjaro® (tirzepatide) has a half-life of approximately 5 days
    // For a 7-day period, we calculate the cumulative remaining medication
    const halfLife = 5.0; // days
    const days = 7.0;
    
    // Calculate remaining medication after 7 days using exponential decay
    // Remaining = Initial * (0.5)^(time/halfLife)
    final remainingAfter7Days = dosage * (0.5 * (days / halfLife));
    
    // For 7-day body dose, we consider the area under the curve
    // This is a simplified calculation - in reality, it would be more complex
    final sevenDayBodyDose = dosage * (1 - remainingAfter7Days / dosage) * days / halfLife;
    
    return sevenDayBodyDose;
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
}
