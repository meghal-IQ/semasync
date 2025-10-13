import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../logging/presentation/screens/weight_logging_screen.dart';
import '../../../profile/presentation/screens/weight_goal_screen.dart';
import 'weight_logs_list_screen.dart';
import 'dart:math' as math;

class WeightResultsScreen extends StatefulWidget {
  const WeightResultsScreen({super.key});

  @override
  State<WeightResultsScreen> createState() => _WeightResultsScreenState();
}

class _WeightResultsScreenState extends State<WeightResultsScreen> {
  String _selectedTimeRange = '7d';

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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Main Content
            Expanded(
              child: Consumer<HealthProvider>(
                builder: (context, healthProvider, child) {
                  if (healthProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.spacing16),
                    child: Column(
                      children: [
                        // Weight Graph Card
                        _buildWeightGraphCard(healthProvider),
                        
                        const SizedBox(height: AppConstants.spacing16),
                        
                        // Progress and BMI Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildProgressCard(healthProvider),
                            ),
                            const SizedBox(width: AppConstants.spacing16),
                            Expanded(
                              child: _buildBMICard(healthProvider),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: AppConstants.spacing16),
                        
                        // Difference Card
                        _buildDifferenceCard(healthProvider),
                        
                        const SizedBox(height: AppConstants.spacing16),
                        
                        // Timeline Card
                        _buildTimelineCard(healthProvider),
                        
                        const SizedBox(height: AppConstants.spacing16),
                        
                        // Today's Log Card
                        _buildTodaysLogCard(healthProvider),
                        
                        const SizedBox(height: AppConstants.spacing24),
                        
                        // Options Section
                        _buildOptionsSection(),
                        
                        const SizedBox(height: AppConstants.spacing80),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "weight_fab",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WeightLoggingScreen()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Results',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing4),
              const Text(
                'Today',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              const Icon(
                Icons.filter_list_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightGraphCard(HealthProvider healthProvider) {
    final stats = healthProvider.weightStats;
    final history = healthProvider.weightHistory;
    final user = context.read<AuthProvider>().user;
    final preferredUnit = user?.preferredUnits.weight ?? 'kg';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_weight,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing8),
              Text(
                'Weight($preferredUnit)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Time range buttons
              Row(
                children: [
                  _buildTimeRangeButton('7d', _selectedTimeRange == '7d'),
                  const SizedBox(width: AppConstants.spacing8),
                  _buildTimeRangeButton('30d', _selectedTimeRange == '30d'),
                  const SizedBox(width: AppConstants.spacing8),
                  _buildTimeRangeButton('90d', _selectedTimeRange == '90d'),
                  const SizedBox(width: AppConstants.spacing8),
                  _buildTimeRangeButton('1y', _selectedTimeRange == '1y'),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing16),
          
          // Weight Graph
          SizedBox(
            height: 200,
            child: history.isEmpty
                ? Center(
                    child: Text(
                      'No weight data yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                    : CustomPaint(
                    painter: WeightGraphPainter(
                      weightHistory: history,
                      currentWeight: stats?.currentWeight,
                      unit: preferredUnit,
                    ),
                    child: Container(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeRange = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing8,
          vertical: AppConstants.spacing4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(HealthProvider healthProvider) {
    final stats = healthProvider.weightStats;
    final user = context.read<AuthProvider>().user;
    final preferredUnit = user?.preferredUnits.weight ?? 'kg';
    
    // Backend stores in kg, convert to preferred unit
    final startWeightKg = user?.weight ?? stats?.startingWeight ?? 0;
    final currentWeightKg = stats?.currentWeight ?? 0;
    final goalWeightKg = user?.goals.targetWeight ?? 91.3;
    
    // Convert to preferred unit for display
    final startWeight = UnitConverter.convertWeight(startWeightKg, preferredUnit);
    final currentWeight = UnitConverter.convertWeight(currentWeightKg, preferredUnit);
    final goalWeight = UnitConverter.convertWeight(goalWeightKg, preferredUnit);
    
    double progress = 0.0;
    if (startWeightKg > 0 && goalWeightKg > 0 && currentWeightKg > 0) {
      final totalChange = (goalWeightKg - startWeightKg).abs();
      final currentChange = (currentWeightKg - startWeightKg).abs();
      progress = totalChange > 0 ? (currentChange / totalChange * 100).clamp(0, 100) : 0;
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing8),
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing8),
          
          Text(
            'Goal Weight: ${goalWeight.toStringAsFixed(1)}$preferredUnit',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppConstants.spacing16),
          
          // Circular Progress
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: Column(
                children: [
                  CircularProgressIndicator(
                    value: progress / 100,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    strokeWidth: 8,
                  ),
                  SizedBox(height: 4,),
                  Center(
                    child: Text(
                      '${progress.toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMICard(HealthProvider healthProvider) {
    final stats = healthProvider.weightStats;
    final user = context.read<AuthProvider>().user;
    final currentWeightKg = stats?.currentWeight;
    final latestDate = stats?.latestEntryDate;
    
    // Calculate BMI using user's height from profile
    final heightCm = user?.height ?? 175.0; // cm from profile
    final heightM = heightCm / 100; // convert to meters
    
    double? bmi;
    if (currentWeightKg != null && currentWeightKg > 0 && heightM > 0) {
      // BMI is always calculated with kg and meters
      bmi = currentWeightKg / (heightM * heightM);
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing4),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 10,
                ),
              ),
              const SizedBox(width: AppConstants.spacing8),
              const Text(
                'BMI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing16),
          
          Text(
            bmi != null ? bmi.toStringAsFixed(1) : '--',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: AppConstants.spacing4),
          
          Text(
            latestDate != null
                ? '${_formatDate(latestDate)}, ${_formatTime(latestDate)}'
                : 'Today',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferenceCard(HealthProvider healthProvider) {
    final stats = healthProvider.weightStats;
    final user = context.read<AuthProvider>().user;
    final preferredUnit = user?.preferredUnits.weight ?? 'kg';
    
    // Backend data in kg
    final totalChangeKg = stats?.totalChange ?? 0;
    final startWeightKg = user?.weight ?? stats?.startingWeight ?? 0;
    final firstDate = stats?.firstEntryDate;
    
    // Convert to preferred unit
    final totalChange = UnitConverter.convertWeight(totalChangeKg.abs(), preferredUnit);
    final startWeight = UnitConverter.convertWeight(startWeightKg, preferredUnit);
    
    final isPositive = totalChangeKg > 0;
    final sign = isPositive ? '+' : '-';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_weight,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing8),
              const Text(
                'Difference',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing16),
          
          Text(
            totalChangeKg != 0 ? '$sign${totalChange.toStringAsFixed(1)}$preferredUnit' : '--',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: AppConstants.spacing4),
          
          Text(
            firstDate != null && startWeightKg > 0
                ? 'From ${startWeight.toStringAsFixed(1)} $preferredUnit, ${_formatDate(firstDate)}'
                : 'No data yet',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(HealthProvider healthProvider) {
    final stats = healthProvider.weightStats;
    final user = context.read<AuthProvider>().user;
    final preferredUnit = user?.preferredUnits.weight ?? 'kg';
    
    // Backend data in kg
    final startWeightKg = user?.weight ?? stats?.startingWeight ?? 0;
    final currentWeightKg = stats?.currentWeight ?? 0;
    final goalWeightKg = user?.goals.targetWeight ?? 91.3;
    final targetDate = user?.goals.targetDate;
    
    // Convert to preferred unit
    final startWeight = UnitConverter.convertWeight(startWeightKg, preferredUnit);
    final currentWeight = UnitConverter.convertWeight(currentWeightKg, preferredUnit);
    final goalWeight = UnitConverter.convertWeight(goalWeightKg, preferredUnit);
    
    double progress = 0.0;
    if (startWeightKg > 0 && goalWeightKg > 0) {
      final totalChange = (goalWeightKg - startWeightKg).abs();
      final currentChange = (currentWeightKg - startWeightKg).abs();
      progress = totalChange > 0 ? (currentChange / totalChange).clamp(0, 1) : 0;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WeightGoalScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacing8),
                const Text(
                  'Timeline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              const Spacer(),
              Text(
                targetDate != null 
                    ? 'Est. Date ${_formatDate(targetDate)}'
                    : 'Est. Date Oct 1, 2025',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              ],
            ),
            
            const SizedBox(height: AppConstants.spacing16),
            
            // Timeline Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${startWeight.toStringAsFixed(0)}$preferredUnit',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  currentWeightKg > 0 ? '${currentWeight.toStringAsFixed(0)}$preferredUnit' : '--',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${goalWeight.toStringAsFixed(0)}$preferredUnit',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stats?.firstEntryDate != null 
                      ? _formatDate(stats!.firstEntryDate!)
                      : 'Sep 17, 2025',
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
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysLogCard(HealthProvider healthProvider) {
    final history = healthProvider.weightHistory;
    final today = DateTime.now();
    final todaysEntries = history.where((log) {
      return log.date.year == today.year &&
             log.date.month == today.month &&
             log.date.day == today.day;
    }).length;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WeightLogsListScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.format_list_bulleted,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppConstants.spacing12),
            Text(
              "Today's Log ($todaysEntries)",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Text(
              'See more',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OPTIONS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        
        const SizedBox(height: AppConstants.spacing16),
        
        // Weight Settings
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WeightGoalScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monitor_weight,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacing12),
                const Text(
                  'Weight Settings',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppConstants.spacing12),
        
        // Show All Weight Logs
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WeightLogsListScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.list_alt,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacing12),
                const Text(
                  'Show All Weight Logs',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class WeightGraphPainter extends CustomPainter {
  final List<dynamic> weightHistory;
  final double? currentWeight;
  final String unit;

  WeightGraphPainter({
    required this.weightHistory,
    this.currentWeight,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || weightHistory.isEmpty) return;
    
    // Define graph margins
    const leftMargin = 40.0;
    const rightMargin = 20.0;
    const topMargin = 50.0;
    const bottomMargin = 30.0;
    
    final graphWidth = size.width - leftMargin - rightMargin;
    final graphHeight = size.height - topMargin - bottomMargin;

    // Find min and max weights for scaling
    double minWeightKg = weightHistory.first.weight;
    double maxWeightKg = weightHistory.first.weight;
    
    for (var log in weightHistory) {
      if (log.weight < minWeightKg) minWeightKg = log.weight;
      if (log.weight > maxWeightKg) maxWeightKg = log.weight;
    }
    
    // Convert to preferred unit
    double minWeight = UnitConverter.convertWeight(minWeightKg, unit);
    double maxWeight = UnitConverter.convertWeight(maxWeightKg, unit);
    
    // Add padding to the range
    final range = maxWeight - minWeight;
    final padding = range > 0 ? range * 0.2 : 2.0;
    minWeight -= padding;
    maxWeight += padding;
    
    // Round to nice numbers
    minWeight = (minWeight / 5).floor() * 5.0;
    maxWeight = (maxWeight / 5).ceil() * 5.0;
    
    // Draw horizontal gridlines and Y-axis labels
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;
    
    final labelStyle = TextStyle(
      color: Colors.grey.shade400,
      fontSize: 10,
    );
    
    const numGridLines = 4;
    for (int i = 0; i <= numGridLines; i++) {
      final y = topMargin + (graphHeight * i / numGridLines);
      
      // Draw gridline
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(leftMargin + graphWidth, y),
        gridPaint,
      );
      
      // Draw Y-axis label
      final weight = maxWeight - ((maxWeight - minWeight) * i / numGridLines);
      final textSpan = TextSpan(
        text: weight.toStringAsFixed(0),
        style: labelStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      textPainter.layout(maxWidth: leftMargin - 10);
      textPainter.paint(
        canvas,
        Offset(5, y - textPainter.height / 2),
      );
    }
    
    // Create points for the line
    final path = Path();
    final points = <Offset>[];
    final dates = <String>[];
    
    for (int i = 0; i < weightHistory.length; i++) {
      final x = leftMargin + (i / (weightHistory.length - 1)) * graphWidth;
      final weightConverted = UnitConverter.convertWeight(weightHistory[i].weight, unit);
      final normalizedWeight = (weightConverted - minWeight) / (maxWeight - minWeight);
      final y = topMargin + graphHeight - (normalizedWeight * graphHeight);
      
      points.add(Offset(x, y));
      
      // Store date for X-axis
      final date = weightHistory[i].date;
      dates.add('${date.month}/${date.day}');
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    // Draw the line
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(path, linePaint);
    
    // Draw X-axis date labels
    for (int i = 0; i < points.length; i++) {
      if (i % math.max(1, (points.length / 6).floor()) == 0 || i == points.length - 1) {
        final textSpan = TextSpan(
          text: dates[i],
          style: labelStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(points[i].dx - textPainter.width / 2, topMargin + graphHeight + 5),
        );
      }
    }
    
    // Draw data points
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    
    for (var point in points) {
      canvas.drawCircle(point, 5, pointPaint);
    }
    
    // Draw latest weight indicator
    if (points.isNotEmpty && currentWeight != null) {
      final lastPoint = points.last;
      
      // Draw vertical dashed line
      final dashedPaint = Paint()
        ..color = AppColors.primary.withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      
      final dashHeight = 5.0;
      final dashSpace = 3.0;
      double currentY = lastPoint.dy;
      
      while (currentY < topMargin + graphHeight) {
        canvas.drawLine(
          Offset(lastPoint.dx, currentY),
          Offset(lastPoint.dx, math.min(currentY + dashHeight, topMargin + graphHeight)),
          dashedPaint,
        );
        currentY += dashHeight + dashSpace;
      }
      
      // Draw white bubble with shadow
      final bubblePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      final currentWeightConverted = UnitConverter.convertWeight(currentWeight!, unit);
      final bubbleText = '${currentWeightConverted.toStringAsFixed(1)}$unit';
      
      // Measure text to size bubble
      final textSpan = TextSpan(
        text: bubbleText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      final bubbleWidth = textPainter.width + 20;
      final bubbleHeight = 32.0;
      final bubbleX = lastPoint.dx - bubbleWidth / 2;
      final bubbleY = lastPoint.dy - bubbleHeight - 15;
      
      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bubbleX, bubbleY, bubbleWidth, bubbleHeight),
        const Radius.circular(16),
      );
      
      // Draw shadow
      canvas.drawRRect(
        bubbleRect.shift(const Offset(0, 2)),
        shadowPaint,
      );
      
      // Draw bubble
      canvas.drawRRect(bubbleRect, bubblePaint);
      
      // Draw text
      final dateSpan = TextSpan(
        text: dates.last,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 9,
        ),
      );
      final datePainter = TextPainter(
        text: dateSpan,
        textDirection: TextDirection.ltr,
      );
      datePainter.layout();
      
      // Draw weight text
      textPainter.paint(
        canvas,
        Offset(
          lastPoint.dx - textPainter.width / 2,
          bubbleY + (bubbleHeight - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
