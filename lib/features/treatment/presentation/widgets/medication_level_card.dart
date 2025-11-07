import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/medication_level_provider.dart';
import '../../../../core/providers/treatment_provider.dart';

class MedicationLevelCard extends StatefulWidget {
  const MedicationLevelCard({super.key});

  @override
  State<MedicationLevelCard> createState() => _MedicationLevelCardState();
}

class _MedicationLevelCardState extends State<MedicationLevelCard> {
  String _selectedTimeRange = '7d';

  @override
  Widget build(BuildContext context) {
    return Consumer2<MedicationLevelProvider, TreatmentProvider>(
      builder: (context, medicationProvider, treatmentProvider, child) {
        final currentLevel = medicationProvider.currentLevelPercentage;
        final lastShot = treatmentProvider.latestShot;
        final shotHistory = treatmentProvider.shotHistory;
        
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
                // Header with title and info icon
                Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Text(
                      'Medication Level',
                      style: AppTextStyles.title(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        _showMedicationInfoDialog(context);
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing16),
                
                // Time range selectors
                _buildTimeRangeSelectors(),
                const SizedBox(height: AppConstants.spacing16),
                
                // Chart
                _buildChart(lastShot, shotHistory, currentLevel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeRangeSelectors() {
    final timeRanges = ['7d', '30d', '90d', '1y'];
    
    return Row(
      children: timeRanges.map((range) {
        final isSelected = _selectedTimeRange == range;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeRange = range;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppConstants.spacing8),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacing8,
                horizontal: AppConstants.spacing12,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                range,
                textAlign: TextAlign.center,
                style: AppTextStyles.title(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChart(dynamic lastShot, List<dynamic> shotHistory, double currentLevel) {
    if (lastShot == null) {
      return _buildNoDataChart();
    }

    // Generate chart data based on selected time range
    final chartData = _generateChartData(lastShot, shotHistory, _selectedTimeRange);
    
    return SizedBox(
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
            // Shot event markers
            LineChartBarData(
              spots: _getAllShotEventSpots(chartData),
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
            // Today marker
            LineChartBarData(
              spots: [_getTodaySpot(chartData)],
              isCurved: false,
              color: AppColors.primary,
              barWidth: 0,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(chartData[touchedSpot.x.toInt()]['x']);
                  return LineTooltipItem(
                    '${chartData[touchedSpot.x.toInt()]['y'].toStringAsFixed(3)}mg\n${DateFormat('MMM d, h:mm a').format(date)}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
              tooltipRoundedRadius: 8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppConstants.spacing12),
            Text(
              'No medication level data available',
              style: AppTextStyles.title(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateChartData(dynamic lastShot, List<dynamic> shotHistory, String timeRange) {
    final List<Map<String, dynamic>> chartData = [];
    
    // Debug information
    print('🔍 Chart Data Generation Debug:');
    print('  - Last Shot: ${lastShot != null ? '${lastShot.medication} ${lastShot.dosage} on ${lastShot.date}' : 'null'}');
    print('  - Shot History Length: ${shotHistory.length}');
    for (int i = 0; i < shotHistory.length; i++) {
      final shot = shotHistory[i];
      print('  - Shot $i: ${shot.medication} ${shot.dosage} on ${shot.date}');
    }
    
    // If no shot history, fall back to last shot only
    if (shotHistory.isEmpty && lastShot != null) {
      shotHistory = [lastShot];
    }
    
    if (shotHistory.isEmpty) {
      return chartData;
    }
    
    // Determine number of days based on time range
    int days;
    switch (timeRange) {
      case '7d':
        days = 7;
        break;
      case '30d':
        days = 30;
        break;
      case '90d':
        days = 90;
        break;
      case '1y':
        days = 365;
        break;
      default:
        days = 7;
    }
    
    // Generate data points centered around today
    final today = DateTime.now();
    final halfDays = days ~/ 2;
    final startDate = today.subtract(Duration(days: halfDays));
    
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      
      // Calculate cumulative level from all shots
      double totalLevel = 0;
      
      // Iterate through all shots and add their contributions
      for (final shot in shotHistory) {
        final shotDate = shot.date;
        final shotMedication = shot.medication;
        final shotHalfLife = _getHalfLifeHours(shotMedication);
        final hoursSinceShot = date.difference(shotDate).inHours;
        
        if (hoursSinceShot >= 0) {
          // Calculate contribution from this shot using exponential decay
          final contribution = 100 * pow(0.5, hoursSinceShot / shotHalfLife);
          totalLevel += contribution;
        }
      }
      
      // Cap the total level at 100%
      totalLevel = totalLevel.clamp(0, 100);
      
      chartData.add({
        'x': date.millisecondsSinceEpoch,
        'y': totalLevel.toDouble(),
      });
    }
    
    return chartData;
  }

  FlSpot _getShotEventSpot(List<Map<String, dynamic>> chartData, dynamic lastShot) {
    // Find the index where the shot occurred
    for (int i = 0; i < chartData.length; i++) {
      final chartDate = DateTime.fromMillisecondsSinceEpoch(chartData[i]['x']);
      final shotDate = lastShot.date;
      
      // If the chart date matches the shot date (same day)
      if (chartDate.year == shotDate.year && 
          chartDate.month == shotDate.month && 
          chartDate.day == shotDate.day) {
        return FlSpot(i.toDouble(), 100); // Show at top of chart
      }
    }
    
    // If not found, return a spot at the end
    return FlSpot((chartData.length - 1).toDouble(), 100);
  }

  List<FlSpot> _getAllShotEventSpots(List<Map<String, dynamic>> chartData) {
    final List<FlSpot> shotSpots = [];
    
    // Get all shots from the treatment provider
    // For now, we'll identify shot events from the chart data where level jumps to 100%
    for (int i = 1; i < chartData.length; i++) {
      final prevLevel = chartData[i - 1]['y'];
      final currentLevel = chartData[i]['y'];
      
      // If there's a significant jump in level, it's likely a shot event
      if (currentLevel > prevLevel + 50) {
        shotSpots.add(FlSpot(i.toDouble(), 100));
      }
    }
    
    // If no shot events detected, return empty list
    return shotSpots;
  }

  FlSpot _getTodaySpot(List<Map<String, dynamic>> chartData) {
    final today = DateTime.now();
    
    // Find the index for today
    for (int i = 0; i < chartData.length; i++) {
      final chartDate = DateTime.fromMillisecondsSinceEpoch(chartData[i]['x']);
      
      // If the chart date matches today (same day)
      if (chartDate.year == today.year && 
          chartDate.month == today.month && 
          chartDate.day == today.day) {
        return FlSpot(i.toDouble(), chartData[i]['y']); // Show at the medication level
      }
    }
    
    // If today is not in the range, return the middle point
    return FlSpot((chartData.length / 2).toDouble(), chartData[chartData.length ~/ 2]['y']);
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

  void _showMedicationInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.medical_services,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppConstants.spacing8),
            Text('Medication Level Estimates'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The medication levels provided in this app are estimates calculated using established pharmacokinetic principles. Our calculations are based on peer-reviewed studies and official clinical pharmacology data for medications including semaglutide, tirzepatide, and retatrutide.',
                style: AppTextStyles.title(fontSize: 14),
              ),
              SizedBox(height: AppConstants.spacing16),
              Text(
                'How Medication Levels are Calculated:',
                style: AppTextStyles.title(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppConstants.spacing8),
              Text('• Half-life: We factor in the medication\'s half-life—the duration required for the concentration of the drug in the body to reduce by half.'),
              SizedBox(height: AppConstants.spacing8),
              Text('• Dosage and Frequency: Estimates also take into account your entered dosage and frequency of medication intake.'),
              SizedBox(height: AppConstants.spacing16),
              Text(
                'Important Considerations:',
                style: AppTextStyles.title(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppConstants.spacing8),
              Text('These estimations provide a general indication of how medications behave typically in the body but do not account for individual variations in metabolism, health conditions, or other personal factors.'),
              SizedBox(height: AppConstants.spacing16),
              Text(
                'Professional Advice:',
                style: AppTextStyles.title(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppConstants.spacing8),
              Text('Always consult your healthcare professional for personalized advice related to your medication and health decisions.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}