import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/healthicons.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/mingcute.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_text_styles.dart';
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

class _WeightResultsScreenState extends State<WeightResultsScreen> with SingleTickerProviderStateMixin {
  String _selectedTimeRange = '7d';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadWeightData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                    return Center(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: child,
                          );
                        },
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  }

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.spacing16),
                      child: Column(
                        children: [
                          // Weight Graph Card
                          _buildAnimatedCard(
                            delay: 0,
                            child: _buildWeightGraphCard(healthProvider),
                          ),
                          
                          const SizedBox(height: AppConstants.spacing16),
                          
                          // Progress, BMI and Difference Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildAnimatedCard(
                                  delay: 100,
                                  child: _buildProgressCard(healthProvider),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacing16),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildAnimatedCard(
                                      delay: 150,
                                      child: _buildBMICard(healthProvider),
                                    ),
                                    const SizedBox(height: AppConstants.spacing12),
                                    _buildAnimatedCard(
                                      delay: 200,
                                      child: _buildDifferenceCard(healthProvider),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppConstants.spacing16),
                          
                          // Timeline Card
                          _buildAnimatedCard(
                            delay: 250,
                            child: _buildTimelineCard(healthProvider),
                          ),
                          
                          const SizedBox(height: AppConstants.spacing16),
                          
                          // Today's Log Card
                          _buildAnimatedCard(
                            delay: 300,
                            child: _buildTodaysLogCard(healthProvider),
                          ),
                          
                          const SizedBox(height: AppConstants.spacing24),
                          
                          // Options Section
                          _buildAnimatedCard(
                            delay: 350,
                            child: _buildOptionsSection(),
                          ),
                          
                          const SizedBox(height: AppConstants.spacing80),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: FloatingActionButton(
          heroTag: "weight_fab",
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const WeightLoggingScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          backgroundColor: const Color(0xFF6A34D7),
          child: Image.asset(
            'assets/images/logo.png', // Using logo as plus icon placeholder
            width: 24,
            height: 24,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildAnimatedTappableCard({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return _AnimatedTappableCard(
      onTap: onTap,
      child: child,
    );
  }

  List<dynamic> _filterWeightHistoryByTimeRange(List<dynamic> history) {
    if (history.isEmpty) return history;
    
    final now = DateTime.now();
    DateTime cutoffDate;
    
    switch (_selectedTimeRange) {
      case '7d':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case '30d':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case '90d':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case '1y':
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 7));
    }
    
    return history.where((log) {
      return log.date.isAfter(cutoffDate) || log.date.isAtSameMomentAs(cutoffDate);
    }).toList();
  }

  List<dynamic> _normalizeWeightHistory(List<dynamic> history) {
    final now = DateTime.now();
    int days;
    switch (_selectedTimeRange) {
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

    final normalizedHistory = <dynamic>[];
    
    // Create a map for quick lookup
    final historyMap = <DateTime, dynamic>{};
    for (var log in history) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      historyMap[logDate] = log;
    }
    
    // Get the latest weight and unit for interpolation
    double? latestWeight;
    String? latestUnit;
    if (history.isNotEmpty) {
      latestWeight = history.first.weight;
      latestUnit = history.first.unit;
    }
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      
      // Check if we have data for this date
      if (historyMap.containsKey(dateOnly)) {
        normalizedHistory.add(historyMap[dateOnly]);
      } else {
        // Create a placeholder entry for missing dates
        // Use the latest weight with slight variation for visualization
        final placeholderWeight = latestWeight != null 
            ? latestWeight + (math.Random().nextDouble() - 0.5) * 2.0 // Small variation
            : 70.0; // Default weight if no data
        
        normalizedHistory.add({
          'date': dateOnly,
          'weight': placeholderWeight,
          'unit': latestUnit ?? 'kg',
          'isPlaceholder': true,
        });
      }
    }

    return normalizedHistory.reversed.toList();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
           Text(
            'Results',
            style: AppTextStyles.title(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightGraphCard(HealthProvider healthProvider) {
    final stats = healthProvider.weightStats;
    final history = _normalizeWeightHistory(_filterWeightHistoryByTimeRange(healthProvider.weightHistory));
    final user = context.read<AuthProvider>().user;
    final preferredUnit = user?.preferredUnits.weight ?? 'kg';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(Healthicons.weight),
              // Image.asset(
              //   'assets/images/weight.png',
              //   width: 20,
              //   height: 20,
              //   color: AppColors.textPrimary,
              // ),
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
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing16),
          
          // Weight Graph
          SizedBox(
            height: 200,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: history.isEmpty
                  ? Center(
                      key: const ValueKey('empty'),
                      child: Text(
                        'No weight data for this period',
                        style: AppTextStyles.title(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : CustomPaint(
                      key: ValueKey(_selectedTimeRange),
                      painter: WeightGraphPainter(
                        weightHistory: history,
                        currentWeight: stats?.currentWeight != null && stats?.unit != null
                            ? UnitConverter.convertWeight(
                                UnitConverter.convertWeightToKg(stats!.currentWeight!, stats!.unit),
                                preferredUnit)
                            : null,
                        unit: preferredUnit,
                      ),
                      child: Container(),
                    ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A34D7) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: AppTextStyles.title(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildProgressCard(HealthProvider healthProvider) {
    final stats = healthProvider.weightStats;
    final user = context.read<AuthProvider>().user;
    final preferredUnit = user?.preferredUnits.weight ?? 'kg';
    
    // Backend returns weight in the same unit as logged, convert to preferred unit
    final statsUnit = stats?.unit ?? 'kg';
    final startWeightRaw = user?.weight ?? stats?.startingWeight ?? 0;
    final currentWeightRaw = stats?.currentWeight ?? 0;
    final goalWeightKg = user?.goals.targetWeight ?? 91.3;
    
    // Convert all weights to kg first, then to preferred unit for display
    final startWeightInKg = UnitConverter.convertWeightToKg(startWeightRaw, statsUnit);
    final currentWeightInKg = UnitConverter.convertWeightToKg(currentWeightRaw, statsUnit);
    
    final startWeight = UnitConverter.convertWeight(startWeightInKg, preferredUnit);
    final currentWeight = UnitConverter.convertWeight(currentWeightInKg, preferredUnit);
    final goalWeight = UnitConverter.convertWeight(goalWeightKg, preferredUnit);
    
    double progress = 0.0;
    if (startWeightInKg > 0 && goalWeightKg > 0 && currentWeightInKg > 0) {
      // Calculate progress based on journey from start to goal
      if (goalWeightKg < startWeightInKg) {
        // Weight loss goal: progress = (start - current) / (start - goal) * 100
        final totalLoss = startWeightInKg - goalWeightKg;
        final currentLoss = startWeightInKg - currentWeightInKg;
        if (totalLoss > 0) {
          // Calculate progress as percentage of total loss achieved
          progress = (currentLoss / totalLoss * 100).clamp(0, 100);
          // If current weight is at or below goal, progress is 100%
          if (currentWeightInKg <= goalWeightKg) {
            progress = 100;
          }
          // Ensure progress doesn't exceed 100% if current weight is above start
          if (currentWeightInKg > startWeightInKg) {
            progress = 0;
          }
        }
      } else if (goalWeightKg > startWeightInKg) {
        // Weight gain goal: progress = (current - start) / (goal - start) * 100
        final totalGain = goalWeightKg - startWeightInKg;
        final currentGain = currentWeightInKg - startWeightInKg;
        if (totalGain > 0) {
          // Calculate progress as percentage of total gain achieved
          progress = (currentGain / totalGain * 100).clamp(0, 100);
          // If current weight is at or above goal, progress is 100%
          if (currentWeightInKg >= goalWeightKg) {
            progress = 100;
          }
          // Ensure progress doesn't go negative if current weight is below start
          if (currentWeightInKg < startWeightInKg) {
            progress = 0;
          }
        }
      } else {
        // Start and goal are the same, progress is 100% if current matches
        progress = (currentWeightInKg == goalWeightKg) ? 100 : 0;
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/dosage.png',
              ),
              const SizedBox(width: AppConstants.spacing4),
              Text(
                'Progress',
                style: AppTextStyles.title(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing8),
          
          Text(
            'Goal Weight: ${goalWeight.toStringAsFixed(1)}$preferredUnit',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
            ),
          ),
          
          const SizedBox(height: AppConstants.spacing16),
          
          // Circular Progress
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: progress),
              builder: (context, value, child) {
                return SizedBox(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle (grey)
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.9,
                        height: MediaQuery.of(context).size.width / 2.9,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          backgroundColor: AppColors.darkGrey,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGrey),
                          strokeWidth: 8,
                        ),
                      ),
                      // Progress circle (purple)
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.9,
                        height: MediaQuery.of(context).size.width / 2.9,
                        child: CircularProgressIndicator(
                          value: value / 100,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A34D7)),
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Percentage text
                      Text(
                        '${value.toInt()}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6A34D7),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMICard(HealthProvider healthProvider) {
    final stats = healthProvider.weightStats;
    final user = context.read<AuthProvider>().user;
    final currentWeightRaw = stats?.currentWeight;
    final latestDate = stats?.latestEntryDate;
    
    // Calculate BMI using user's height from profile
    final heightCm = user?.height ?? 175.0; // cm from profile
    final heightM = heightCm / 100; // convert to meters
    
    // Convert current weight to kg for BMI calculation
    double? bmi;
    if (currentWeightRaw != null && currentWeightRaw > 0 && heightM > 0 && stats?.unit != null) {
      // BMI is always calculated with kg and meters
      final currentWeightKg = UnitConverter.convertWeightToKg(currentWeightRaw, stats!.unit);
      bmi = currentWeightKg / (heightM * heightM);
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/dosage.png',
              ),
              const SizedBox(width: AppConstants.spacing4),
               Text(
                'BMI',
                style: AppTextStyles.title(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing6),
          
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.0, end: bmi ?? 0.0),
            builder: (context, value, child) {
              return Text(
                value > 0 ? value.toStringAsFixed(1) : '--',
                style: AppTextStyles.title(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          
          const SizedBox(height: AppConstants.spacing4),
          
          Text(
            latestDate != null
                ? '${_formatDate(latestDate)}, ${_formatTime(latestDate)}'
                : 'Today',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
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
    
    // Backend data in same unit as logged
    final statsUnit = stats?.unit ?? 'kg';
    final totalChangeRaw = stats?.totalChange ?? 0;
    final startWeightRaw = user?.weight ?? stats?.startingWeight ?? 0;
    final firstDate = stats?.firstEntryDate;
    
    // Convert to preferred unit - first to kg, then to preferred
    final totalChangeInKg = UnitConverter.convertWeightToKg(totalChangeRaw.abs(), statsUnit);
    final totalChange = UnitConverter.convertWeight(totalChangeInKg, preferredUnit);
            
    final startWeightInKg = UnitConverter.convertWeightToKg(startWeightRaw, statsUnit);
    final startWeight = UnitConverter.convertWeight(startWeightInKg, preferredUnit);
    
    final isPositive = totalChangeRaw > 0;
    final sign = isPositive ? '+' : '-';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                 Center(
                  child: Image.asset(
                    'assets/images/dosage.png',
                  ),
                ),
              const SizedBox(width: AppConstants.spacing4),
               Text(
                'Difference',
                style: AppTextStyles.title(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing6),
          
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.0, end: totalChange),
            builder: (context, value, child) {
              return Text(
                totalChangeRaw != 0 ? '$sign${value.toStringAsFixed(1)}$preferredUnit' : '--',
                style: AppTextStyles.title(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          
          const SizedBox(height: AppConstants.spacing4),
          
          Text(
            firstDate != null && startWeightRaw > 0
                ? 'From ${startWeight.toStringAsFixed(1)} $preferredUnit, ${_formatDate(firstDate)}'
                : 'No data yet',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
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
    
    // Backend data in same unit as logged, convert to preferred unit
    final statsUnit = stats?.unit ?? 'kg';
    final startWeightRaw = user?.weight ?? stats?.startingWeight ?? 0;
    final currentWeightRaw = stats?.currentWeight ?? 0;
    final goalWeightKg = user?.goals.targetWeight ?? 91.3;
    final targetDate = user?.goals.targetDate;
    
    // Convert all weights to kg first, then to preferred unit for display
    final startWeightInKg = UnitConverter.convertWeightToKg(startWeightRaw, statsUnit);
    final currentWeightInKg = UnitConverter.convertWeightToKg(currentWeightRaw, statsUnit);
    
    final startWeight = UnitConverter.convertWeight(startWeightInKg, preferredUnit);
    final currentWeight = UnitConverter.convertWeight(currentWeightInKg, preferredUnit);
    final goalWeight = UnitConverter.convertWeight(goalWeightKg, preferredUnit);
    
    double progress = 0.0;
    if (startWeightInKg > 0 && goalWeightKg > 0 && currentWeightInKg > 0) {
      // Calculate progress in kg for accuracy
      final totalChange = (goalWeightKg - startWeightInKg).abs();
      final currentChange = (currentWeightInKg - startWeightInKg).abs();
      progress = totalChange > 0 ? (currentChange / totalChange).clamp(0, 1) : 0;
    }

    return _buildAnimatedTappableCard(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const WeightGoalScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/injection_line.png', // Person icon with outstretched arms
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
                    color: Color(0xFF1A1F36),
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A34D7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  targetDate != null 
                      ? 'Est. Date ${_formatDate(targetDate)}'
                      : 'Est. Date Oct 14, 2025',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6A34D7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ],
            ),
            
            const SizedBox(height: AppConstants.spacing16),
            
            // Timeline Progress Bar
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${startWeight.toStringAsFixed(1)}$preferredUnit',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${goalWeight.toStringAsFixed(1)}$preferredUnit',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    currentWeightRaw > 0 ? '${currentWeight.toStringAsFixed(1)}$preferredUnit' : '--',
                    style: const TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing8),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: progress),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A34D7)),
                  minHeight: 8,
                );
              },
            ),
            const SizedBox(height: AppConstants.spacing8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stats?.firstEntryDate != null 
                      ? _formatDate(stats!.firstEntryDate!)
                      : 'Sep 17, 2025',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                ),
                Text(
                  currentWeight > 0 ? 'Today' : 'Today',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
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

    return _buildAnimatedTappableCard(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const WeightLogsListScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Iconify(Healthicons.weight),
                const SizedBox(width: AppConstants.spacing12),
                Text(
                  "Today's Log",
                  style: AppTextStyles.subtitle(
                    fontSize: 16,
                    color: Color(0xFF1A1F36),
                  ),
                ),
                const Spacer(),
                Text(
                  'See less',
                  style: AppTextStyles.title(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
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
        Text(
          'OPTIONS',
          style: AppTextStyles.title(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: AppConstants.spacing16),
        
        // Weight Settings
        _buildAnimatedTappableCard(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const WeightGoalScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Iconify(Healthicons.weight),
                const SizedBox(width: AppConstants.spacing12),
                Text(
                  'Weight Settings',
                  style: AppTextStyles.subtitle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6A34D7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppConstants.spacing12),
        
        // Show All Weight Logs
        _buildAnimatedTappableCard(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const WeightLogsListScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/list.png', // List icon - replace with actual list icon
                  width: 20,
                  height: 20,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppConstants.spacing12),
                Text(
                  'Show All Weight Logs',
                  style: AppTextStyles.subtitle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6A34D7),
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
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _AnimatedTappableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedTappableCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedTappableCard> createState() => _AnimatedTappableCardState();
}

class _AnimatedTappableCardState extends State<_AnimatedTappableCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.forward();
  }

  void _onTapCancel() {
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
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

  double _getWeightFromEntry(dynamic entry) {
    if (entry is Map) {
      return entry['weight'] as double;
    } else {
      return entry.weight;
    }
  }

  String _getUnitFromEntry(dynamic entry) {
    if (entry is Map) {
      return entry['unit'] as String? ?? 'kg';
    } else {
      return entry.unit;
    }
  }

  DateTime _getDateFromEntry(dynamic entry) {
    if (entry is Map) {
      return entry['date'] as DateTime;
    } else {
      return entry.date;
    }
  }

  bool _isPlaceholder(dynamic entry) {
    if (entry is Map) {
      return entry['isPlaceholder'] == true;
    } else {
      return false; // Real WeightLog objects are never placeholders
    }
  }

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

    // Sort weight history by date to ensure chronological order
    final sortedHistory = List.from(weightHistory);
    sortedHistory.sort((a, b) {
      final dateA = _getDateFromEntry(a);
      final dateB = _getDateFromEntry(b);
      return dateA.compareTo(dateB);
    });

    // Find min and max weights for scaling (convert each to kg first for comparison)
    double firstWeight = _getWeightFromEntry(sortedHistory.first);
    String firstUnit = _getUnitFromEntry(sortedHistory.first);
    double minWeightKg = UnitConverter.convertWeightToKg(firstWeight, firstUnit);
    double maxWeightKg = minWeightKg;
    
    for (var log in sortedHistory) {
      final weight = _getWeightFromEntry(log);
      final entryUnit = _getUnitFromEntry(log);
      final weightInKg = UnitConverter.convertWeightToKg(weight, entryUnit);
      if (weightInKg < minWeightKg) minWeightKg = weightInKg;
      if (weightInKg > maxWeightKg) maxWeightKg = weightInKg;
    }
    
    // Include currentWeight in min/max calculation if available
    if (currentWeight != null) {
      // currentWeight is already in the preferred unit, convert to kg for comparison
      final currentWeightKg = UnitConverter.convertWeightToKg(currentWeight!, unit);
      if (currentWeightKg < minWeightKg) minWeightKg = currentWeightKg;
      if (currentWeightKg > maxWeightKg) maxWeightKg = currentWeightKg;
    }
    
    // Convert to preferred unit
    double minWeight = UnitConverter.convertWeight(minWeightKg, unit);
    double maxWeight = UnitConverter.convertWeight(maxWeightKg, unit);
    
    // Ensure minimum range for better visualization
    final range = maxWeight - minWeight;
    final minRange = unit.toLowerCase() == 'kg' ? 10.0 : 20.0; // 10kg or 20lbs minimum range
    
    if (range < minRange) {
      final center = (maxWeight + minWeight) / 2;
      minWeight = center - minRange / 2;
      maxWeight = center + minRange / 2;
    } else {
      // Add small padding to the range
      final padding = range * 0.1; // Reduced padding
      minWeight -= padding;
      maxWeight += padding;
    }
    
    // Round to nice numbers
    if (unit.toLowerCase() == 'kg') {
      minWeight = (minWeight / 5).floor() * 5.0;
      maxWeight = (maxWeight / 5).ceil() * 5.0;
    } else {
      minWeight = (minWeight / 10).floor() * 10.0;
      maxWeight = (maxWeight / 10).ceil() * 10.0;
    }
    
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
    
    for (int i = 0; i < sortedHistory.length; i++) {
      // Handle single data point case
      final x = sortedHistory.length == 1 
          ? leftMargin + graphWidth / 2 
          : leftMargin + (i / (sortedHistory.length - 1)) * graphWidth;
      
      // Convert weight: first to kg, then to preferred unit
      // For the last point, use currentWeight if available (more accurate)
      double weightConverted;
      if (i == sortedHistory.length - 1 && currentWeight != null) {
        // Use currentWeight for the last point to ensure label matches position
        weightConverted = currentWeight!;
      } else {
        final entryWeight = _getWeightFromEntry(sortedHistory[i]);
        final entryUnit = _getUnitFromEntry(sortedHistory[i]);
        final weightInKg = UnitConverter.convertWeightToKg(entryWeight, entryUnit);
        weightConverted = UnitConverter.convertWeight(weightInKg, unit);
      }
      
      final normalizedWeight = (weightConverted - minWeight) / (maxWeight - minWeight);
      final y = topMargin + graphHeight - (normalizedWeight * graphHeight);
      
      points.add(Offset(x, y));
      
      // Store date for X-axis
      final date = _getDateFromEntry(sortedHistory[i]);
      dates.add('${date.month}/${date.day}');
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    // Draw the line with different styles for real vs placeholder data
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    
    final placeholderLinePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    
    // Draw solid line segments for real data
    for (int i = 0; i < points.length - 1; i++) {
      final currentIsPlaceholder = _isPlaceholder(sortedHistory[i]);
      final nextIsPlaceholder = _isPlaceholder(sortedHistory[i + 1]);
      
      if (!currentIsPlaceholder && !nextIsPlaceholder) {
        // Both points are real data - draw solid line
        canvas.drawLine(points[i], points[i + 1], linePaint);
      } else if (currentIsPlaceholder || nextIsPlaceholder) {
        // One or both points are placeholders - draw dashed line
        _drawDashedLine(canvas, points[i], points[i + 1], placeholderLinePaint);
      }
    }
    
    // Draw X-axis date labels
    final maxLabels = 6;
    final labelInterval = math.max(1, (points.length / maxLabels).floor());
    
    for (int i = 0; i < points.length; i++) {
      // Show first, last, and evenly spaced labels
      if (i == 0 || i == points.length - 1 || i % labelInterval == 0) {
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
    
    final placeholderPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isPlaceholder = _isPlaceholder(sortedHistory[i]);
      
      if (isPlaceholder) {
        // Draw smaller, semi-transparent circles for placeholder points
        canvas.drawCircle(point, 3, placeholderPaint);
      } else {
        // Draw normal circles for real data points
        canvas.drawCircle(point, 5, pointPaint);
      }
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
      
      final bubbleText = '${currentWeight!.toStringAsFixed(1)}$unit';
      
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
        style: AppTextStyles.title(
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

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    
    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final startRatio = (i * (dashWidth + dashSpace)) / distance;
      final endRatio = ((i * (dashWidth + dashSpace)) + dashWidth) / distance;
      
      final dashStart = Offset.lerp(start, end, startRatio)!;
      final dashEnd = Offset.lerp(start, end, endRatio)!;
      
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
