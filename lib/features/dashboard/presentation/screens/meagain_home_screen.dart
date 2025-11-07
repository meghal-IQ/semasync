import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/providers/activity_provider.dart';
import '../../../../core/providers/nutrition_provider.dart';
import '../../../../core/providers/historical_data_provider.dart';
import '../../../../core/api/models/nutrition_log_model.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../treatment/presentation/providers/medication_level_provider.dart';
import '../widgets/fiber_card.dart';
import '../widgets/protein_card.dart';
import '../widgets/custom_day_picker.dart';
import '../widgets/shot_day_task_carousel.dart';
import '../widgets/medication_level_card.dart';
import '../widgets/todays_activity_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../widgets/water_card.dart';

class MeAgainHomeScreen extends StatefulWidget {
  const MeAgainHomeScreen({super.key});

  @override
  State<MeAgainHomeScreen> createState() => _MeAgainHomeScreenState();
}

class _MeAgainHomeScreenState extends State<MeAgainHomeScreen> {
  bool _isTodaysLogExpanded = false;
  bool _isShotDayExpanded = true;
  Timer? _timeUpdateTimer;
  DateTime _selectedDate = DateTime.now();
  int? _selectedTaskIndex; // Track selected task for radio button
  
  // Calculate today's index dynamically based on date range
  // CustomDayPicker shows dates from -60 to +60 (120 days total: ~2 months back and forward)
  // Today (when offset is 0) is at index 60
  int get _todayIndex {
    final startOffset = -60; // Start from 2 months ago
    final todayOffset = 0; // Today has offset 0
    return todayOffset - startOffset; // 0 - (-60) = 60
  }
  
  int get _selectedIndex {
    // Calculate selected index based on days difference from today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final difference = selected.difference(today).inDays;
    final calculatedIndex = _todayIndex + difference;
    // Clamp to valid range (0-120 for 121 days: -60 to +60)
    return calculatedIndex.clamp(0, 120);
  }
  
  @override
  void initState() {
    super.initState();
    // Load all data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForSelectedDate();
    });
    
    // Set up timer to update time display every 30 seconds for recent entries
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild and update the time display
        });
      }
    });
  }

  Widget _buildTodaysActivity() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    return Consumer2<NutritionProvider, HistoricalDataProvider>(
      builder: (context, nutritionProvider, historicalProvider, child) {
        final activities = <Map<String, dynamic>>[];

        if (isToday) {
          final todaysLog = nutritionProvider.todaysLog;
          if (todaysLog != null && todaysLog.logs.isNotEmpty) {
            for (final log in todaysLog.logs) {
              activities.add({
                'type': log.type,
                'amount': log.data['amount'] ?? '',
                'unit': log.data['unit'] ?? '',
                'timestamp': log.time,
              });
            }
          }
        } else {
          // Get historical data
          final historicalLogs = historicalProvider.logEntries;
          if (historicalLogs.isNotEmpty) {
            for (final log in historicalLogs) {
              // Extract data from historical log structure
              activities.add({
                'type': _extractLogType(log),
                'amount': _extractLogAmount(log),
                'unit': _extractLogUnit(log),
                'timestamp': _extractLogTimestamp(log),
              });
            }
          }
        }

        return TodaysActivityCard(activities: activities);
      },
    );
  }

  String _extractLogType(dynamic log) {
    // Try different field names based on log structure
    if (log is Map) {
      return (log['type'] ?? log['category'] ?? '').toString();
    }
    return '';
  }

  dynamic _extractLogAmount(dynamic log) {
    if (log is Map) {
      return log['amount'] ?? log['value'] ?? '';
    }
    return '';
  }

  String _extractLogUnit(dynamic log) {
    if (log is Map) {
      return (log['unit'] ?? 'g').toString();
    }
    return 'g';
  }

  DateTime? _extractLogTimestamp(dynamic log) {
    if (log is Map) {
      if (log['timestamp'] is DateTime) {
        return log['timestamp'];
      }
      if (log['timestamp'] is String) {
        return DateTime.tryParse(log['timestamp']);
      }
      if (log['time'] is DateTime) {
        return log['time'];
      }
      if (log['time'] is String) {
        return DateTime.tryParse(log['time']);
      }
    }
    return null;
  }

  @override
  void dispose() {
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with App Name
            _buildCustomHeader(),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Custom Day Picker
                    CustomDayPicker(
                      selectedIndex: _selectedIndex,
                      onDaySelected: (index) {
                        // Calculate the date based on selected index dynamically
                        final daysFromToday = index - _todayIndex;
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final newDate = today.add(Duration(days: daysFromToday));
                        
                        setState(() {
                          _selectedDate = newDate;
                        });
                        
                        _loadDataForSelectedDate();
                      },
                    ),
                    
                    const SizedBox(height: 12),

                    // Shot Day Task Carousel
                    ShotDayTaskCarousel(selectedDate: _selectedDate),

                    const SizedBox(height: 12),

                    // Medication Level Card (new design)
                    MedicationLevelCard(selectedDate: _selectedDate),
                    
                    const SizedBox(height: AppConstants.spacing16),
                    
                    // Nutrition Cards Grid - Staggered Layout
                    Consumer2<NutritionProvider, HistoricalDataProvider>(
                      builder: (context, nutritionProvider, historicalProvider, child) {
                        final isToday = _isSameDay(_selectedDate, DateTime.now());
                        
                        // Get values
                        double fiber;
                        double water;
                        double protein;
                        
                        if (isToday) {
                          final dailySummary = nutritionProvider.dailySummary;
                          fiber = ((dailySummary?.fiber ?? 0) as num).toDouble().clamp(0, double.infinity);
                          water = ((dailySummary?.water ?? 0) as num).toDouble().clamp(0, double.infinity);
                          protein = ((dailySummary?.protein ?? 0) as num).toDouble().clamp(0, double.infinity);
                        } else {
                          final historicalNutrition = historicalProvider.nutritionData;
                          fiber = ((historicalNutrition?['fiber'] ?? 0) as num).toDouble().clamp(0, double.infinity);
                          water = ((historicalNutrition?['water'] ?? 0) as num).toDouble().clamp(0, double.infinity);
                          protein = ((historicalNutrition?['protein'] ?? 0) as num).toDouble().clamp(0, double.infinity);
                        }
                        
                        return MasonryGridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: AppConstants.spacing16,
                          crossAxisSpacing: AppConstants.spacing16,
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 0:
                                return FiberCard(
                                  fiber: fiber,
                                  fiberGoal: 20,
                                  onIncrement: isToday ? _incrementFiber : null,
                                  onDecrement: isToday ? _decrementFiber : null,
                                );
                              case 1:
                                return WaterCard(
                                  water: water,
                                  waterGoal: 3494,
                                  onIncrement: isToday ? _incrementWater : null,
                                  onDecrement: isToday ? _decrementWater : null,
                                );
                              case 2:
                                return _buildGoalCard();
                              case 3:
                                return ProteinCard(
                                  protein: protein,
                                  proteinGoal: 120,
                                  onIncrement: isToday ? _incrementProtein : null,
                                  onDecrement: isToday ? _decrementProtein : null,
                                );
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: AppConstants.spacing24),
                    
                    // Shot Day Reminder Section (if today is shot day)
                    _buildShotDayReminder(),
                    
                    // Today's Activity
                    _buildTodaysActivity(),
                    
                    const SizedBox(height: AppConstants.spacing80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientHeader() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Good Morning' : 
                     hour < 17 ? 'Good Afternoon' : 
                     'Good Evening';
    String emoji = hour < 12 ? '☀️' : hour < 17 ? '🌤️' : '🌙';
    
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(
                             color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                             border: Border.all(
                               color: AppColors.primary.withOpacity(0.2),
                               width: 1,
                             ),
                           ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Today',
                          style: AppTextStyles.subtitle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                         Container(
                           width: 40,
                           height: 40,
                           decoration: BoxDecoration(
                             color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                             border: Border.all(
                               color: AppColors.primary.withOpacity(0.2),
                               width: 1,
                             ),
                           ),
                           child: const Icon(
                             Icons.notifications_none_rounded,
                             color: AppColors.primary,
                             size: 20,
                           ),
                         ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    emoji,
                    style: AppTextStyles.text(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: AppTextStyles.subtitle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return Text(
                              authProvider.user?.firstName ?? 'There',
                              style: AppTextStyles.text(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    final now = DateTime.now();
    final isToday = _isSameDay(_selectedDate, now);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png'),
          const SizedBox(width: 12),
          Text(
            'Semasync',
            style: AppTextStyles.title(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            isToday 
                ? 'Today' 
                : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: AppTextStyles.title(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiberCard() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    
    return Consumer2<NutritionProvider, HistoricalDataProvider>(
      builder: (context, nutritionProvider, historicalProvider, child) {
        double fiber;
        if (isToday) {
          final dailySummary = nutritionProvider.dailySummary;
          fiber = ((dailySummary?.fiber ?? 0) as num).toDouble().clamp(0, double.infinity);
        } else {
          final historicalNutrition = historicalProvider.nutritionData;
          final fiberValue = historicalNutrition?['fiber'] ?? 0;
          fiber = (fiberValue as num).toDouble().clamp(0, double.infinity);
        }
        const fiberGoal = 25;
        final progress = (fiber / fiberGoal * 100).clamp(0, 100);
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.grain_rounded,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  'Fiber',
                  style: AppTextStyles.title(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${fiber.toStringAsFixed(0)}',
                      style: AppTextStyles.text(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1F36),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'g / ${fiberGoal}g',
                      style: AppTextStyles.subtitle(
                        fontSize: 14,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    minHeight: 6,
                  ),
                ),
                
                const SizedBox(height: 18),
                
                // Controls
                Row(
                  children: [
                    Expanded(
                      child: _buildCleanControlButton(
                        Icons.remove_rounded, 
                        () => _decrementFiber(), 
                        const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildCleanControlButton(
                        Icons.add_rounded, 
                        () => _incrementFiber(), 
                        const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaterCard() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    
    return Consumer2<NutritionProvider, HistoricalDataProvider>(
      builder: (context, nutritionProvider, historicalProvider, child) {
        double waterAmount;
        double waterGoal;
        if (isToday) {
          final dailySummary = nutritionProvider.dailySummary;
          waterAmount = ((dailySummary?.water ?? 0) as num).toDouble().clamp(0, double.infinity);
          waterGoal = ((dailySummary?.waterGoal ?? 2500) as num).toDouble();
        } else {
          final historicalNutrition = historicalProvider.nutritionData;
          final waterValue = historicalNutrition?['water'] ?? 0;
          final goalValue = historicalNutrition?['waterGoal'] ?? 2500;
          waterAmount = (waterValue as num).toDouble().clamp(0, double.infinity);
          waterGoal = (goalValue as num).toDouble();
        }
        final progress = (waterAmount / waterGoal * 100).clamp(0, 100);
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  'Water',
                  style: AppTextStyles.title(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        '${waterAmount.toStringAsFixed(0)}',
                        style: AppTextStyles.text(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1F36),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'ml / ${waterGoal.toStringAsFixed(0)}ml',
                        style: AppTextStyles.subtitle(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                    minHeight: 6,
                  ),
                ),
                
                const SizedBox(height: 18),
                
                // Controls
                Row(
                  children: [
                    Expanded(
                      child: _buildCleanControlButton(
                        Icons.remove_rounded, 
                        () => _decrementWater(), 
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildCleanControlButton(
                        Icons.add_rounded, 
                        () => _incrementWater(), 
                        const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalCard() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    
    return Consumer3<HealthProvider, HistoricalDataProvider, AuthProvider>(
      builder: (context, healthProvider, historicalProvider, authProvider, child) {
        // Get weight info
        double? currentWeight;
        double? startWeight;
        double? goalWeight;
        String unit = 'kg';
        
        final user = authProvider.user;
        final preferredUnit = user?.preferredUnits.weight ?? 'kg';
        
        if (isToday) {
          final stats = healthProvider.weightStats;
          final statsUnit = stats?.unit ?? 'kg';
          currentWeight = stats?.currentWeight;
          startWeight = user?.weight ?? stats?.startingWeight ?? 0;
          goalWeight = user?.goals.targetWeight ?? 91.3;
          
          // Convert to preferred unit
          if (currentWeight != null) {
            final currentWeightKg = UnitConverter.convertWeightToKg(currentWeight, statsUnit);
            currentWeight = UnitConverter.convertWeight(currentWeightKg, preferredUnit);
          }
          if (startWeight != null && startWeight > 0) {
            final startWeightKg = UnitConverter.convertWeightToKg(startWeight, statsUnit);
            startWeight = UnitConverter.convertWeight(startWeightKg, preferredUnit);
          }
          if (goalWeight != null && goalWeight > 0) {
            goalWeight = UnitConverter.convertWeight(goalWeight, preferredUnit);
          }
          unit = preferredUnit;
        } else {
          // For historical data, get weight from historical provider
          final weightData = historicalProvider.weightData;
          if (weightData.isNotEmpty) {
            final weight = weightData.first;
            currentWeight = (weight['weight'] ?? weight['currentWeight'])?.toDouble();
            unit = weight['unit'] ?? 'kg';
          }
          // Get start and goal from user profile
          final startWeightKg = user?.weight ?? 0;
          final goalWeightKg = user?.goals.targetWeight ?? 91.3;
          startWeight = UnitConverter.convertWeight(startWeightKg, preferredUnit);
          goalWeight = UnitConverter.convertWeight(goalWeightKg, preferredUnit);
          unit = preferredUnit;
        }
        
        // Default values if no data
        final displayWeight = currentWeight ?? 0.0;
        final displayStartWeight = startWeight ?? 330.693;
        final displayGoalWeight = goalWeight ?? 176.37;
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Builder(
              builder: (context) {
                // Calculate responsive padding: 2% of screen width, min 12px, max 20px
                final screenWidth = MediaQuery.of(context).size.width;
                final responsivePadding = (screenWidth * 0.02).clamp(12.0, 20.0);
                
                return Padding(
                  padding: EdgeInsets.all(responsivePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon and title
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            // width: 32,
                            // height: 32,
                            // decoration: BoxDecoration(
                            //   color: const Color(0xFFEB579F),
                            //   borderRadius: BorderRadius.circular(8),
                            // ),
                            child: const Icon(
                              Icons.monitor_weight,
                              color: const Color(0xFFEB579F),
                              // size: 18,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Weight Goal',
                              style: AppTextStyles.title(
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Large weight value with unit
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              displayWeight.toStringAsFixed(2),
                              style: AppTextStyles.text(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF000000),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            unit == 'kg' ? 'kg' : 'lbs',
                            style: AppTextStyles.text(
                              fontSize: 11,
                              color: const Color(0xFFA0A0A0),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Graph - Flexible height to prevent overflow
                      SizedBox(
                        height: 100,
                        width: double.infinity,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: WeightGoalGraphPainter(
                              startWeight: displayStartWeight,
                              currentWeight: displayWeight,
                              goalWeight: displayGoalWeight,
                              unit: unit,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.divider,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSmallControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.divider,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildModernControlButton(IconData icon, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildCleanControlButton(IconData icon, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
                      borderRadius: BorderRadius.circular(10),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _loadDataForSelectedDate();
  }

  void _loadDataForSelectedDate() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    
    if (isToday) {
      // Load current day data
      context.read<DashboardProvider>().loadDashboardData();
      context.read<TreatmentProvider>().loadTreatmentData();
      context.read<HealthProvider>().loadWeightData();
      context.read<ActivityProvider>().loadActivityData();
      context.read<NutritionProvider>().loadNutritionData();
      context.read<NutritionProvider>().loadTodaysLog();
      // Load medication level for today
      context.read<MedicationLevelProvider>().loadCurrentMedicationLevel();
    } else {
      // Load historical data
      context.read<HistoricalDataProvider>().loadHistoricalData(_selectedDate);
      // Load medication level for the selected historical date
      context.read<MedicationLevelProvider>().loadMedicationLevelForDate(_selectedDate);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }


  void _incrementFiber() {
    _logQuickNutrition(fiber: 1);
  }

  void _decrementFiber() {
    _logQuickNutrition(fiber: -1);
  }

  void _incrementWater() {
    print('=== INCREMENT WATER CALLED ===');
    print('=== TESTING INCREMENT FUNCTION ===');
    
    // Show immediate visual feedback
    
    _logQuickWater(237);
  }

  void _decrementWater() {
    print('=== DECREMENT WATER CALLED ===');
    print('=== TESTING DECREMENT FUNCTION ===');
    
    // Show immediate visual feedback
    
    _logQuickWater(-237);
  }

  void _incrementProtein() {
    _logQuickNutrition(protein: 5);
  }

  void _decrementProtein() {
    _logQuickNutrition(protein: -5);
  }

  void _logQuickNutrition({double? fiber, double? protein}) async {
    try {
      final nutritionProvider = context.read<NutritionProvider>();
      
      // Create a simple meal log for quick nutrition logging
      final now = DateTime.now();
      final mealType = _getMealTypeForTime(now);
      
      // Create food items based on what we're logging
      final foods = <Food>[];
      
      if (fiber != null) {
        foods.add(Food(
          name: fiber > 0 ? 'Fiber Supplement' : 'Fiber Removal',
          portion: '${fiber.abs()}g',
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          fiber: fiber, // Can be negative for removal
        ));
      }
      
      if (protein != null) {
        foods.add(Food(
          name: protein > 0 ? 'Protein Supplement' : 'Protein Removal',
          portion: '${protein.abs()}g',
          calories: protein * 4,
          protein: protein,
          carbs: 0,
          fat: 0,
        ));
      }
      
      if (foods.isNotEmpty) {
        final request = MealLogRequest(
          date: now,
          mealType: mealType,
          foods: foods,
          notes: 'Quick log from dashboard',
        );
        
        await nutritionProvider.logMeal(request);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _logQuickWater(int amount) async {
    
    try {
      final nutritionProvider = context.read<NutritionProvider>();
      
      // Create water entry (now supports negative amounts)
      final now = DateTime.now();
      final waterEntry = WaterEntry(
        time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        amount: amount, // Can be negative for removal
        type: amount > 0 ? 'Glass' : 'Removal',
      );

      final request = WaterLogRequest(
        date: now,
        entries: [waterEntry],
        notes: amount > 0 ? 'Quick log from dashboard' : 'Quick removal from dashboard',
      );

      
      print('Calling nutritionProvider.logWater...');
      await nutritionProvider.logWater(request);
      print('nutritionProvider.logWater completed successfully');
      
      // Show success feedback
    } catch (e) {
      print('ERROR in _logQuickWater:'+ e.toString());
    }
    print('=== _logQuickWater END ===');
  }

  String _getMealTypeForTime(DateTime time) {
    final hour = time.hour;
    if (hour < 11) return 'breakfast';
    if (hour < 15) return 'lunch';
    if (hour < 19) return 'dinner';
    return 'snack';
  }

  Widget _buildShotDayReminder() {
    return Consumer<TreatmentProvider>(
      builder: (context, treatmentProvider, child) {
        final nextShot = treatmentProvider.nextShotInfo;
        
        // Check if today is shot day
        if (nextShot == null || !_isShotDayToday(nextShot.nextDueDate)) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFEF3C7),
                Color(0xFFFDE68A),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      'Shot Day',
                      style: AppTextStyles.title(
                        color: AppColors.primary,
                      ),
                    ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isShotDayExpanded = !_isShotDayExpanded;
                      });
                    },
                    child: Text(
                      _isShotDayExpanded ? 'See Less' : 'See More',
                      style: AppTextStyles.subtitle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (_isShotDayExpanded) ...[
                const SizedBox(height: AppConstants.spacing20),
                const Divider(height: 1, color: AppColors.divider),
                
                // Shot Day Tasks
                _buildShotDayTask(
                  'High-Protein Meal/Drink',
                  '7:00 PM',
                  false,
                  0,
                ),
                
                const Divider(height: 1, color: AppColors.divider),
                
                _buildShotDayTask(
                  'Drink lots of Water\n(+electrolytes)',
                  '7:00 PM',
                  false,
                  1,
                ),
                
                const Divider(height: 1, color: AppColors.divider),
                
                _buildShotDayTask(
                  'Load Syringe and let come to\nroom temp',
                  '7:15 PM',
                  false,
                  2,
                ),
                
                const Divider(height: 1, color: AppColors.divider),
                
                _buildShotDayTask(
                  'Take Shot',
                  '8:00 PM',
                  true, // Highlighted task
                  3,
                ),
                
                const Divider(height: 1, color: AppColors.divider),
                
                _buildShotDayTask(
                  'Another High Protein Meal/Drink',
                  '9:00 PM',
                  false,
                  4,
                ),
              ],
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildShotDayTask(String title, String time, bool isHighlighted, int index) {
    final isSelected = _selectedTaskIndex == index;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTaskIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
        child: Row(
          children: [
            // Radio Button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6A34D7) : Colors.white,
                border: Border.all(
                  color: const Color(0xFF6A34D7),
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: AppConstants.spacing16),
            
            // Task title
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.title(
                  fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                  color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            
            // Time
            Text(
              time,
              style: AppTextStyles.title(
                fontWeight: FontWeight.w400,
                color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isShotDayToday(DateTime? nextDueDate) {
    if (nextDueDate == null) return false;
    final now = DateTime.now();
    return now.year == nextDueDate.year &&
           now.month == nextDueDate.month &&
           now.day == nextDueDate.day;
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.divider.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.divider.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load data',
              style: AppTextStyles.title(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.text(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.divider.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(
              Icons.inbox_outlined,
              color: AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'No entries for ${_formatDate(_selectedDate)}',
              style: AppTextStyles.title(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No activity was logged on this date',
              style: AppTextStyles.text(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildTodaysLogSection() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final todaysLog = nutritionProvider.todaysLog;
        final isLoading = nutritionProvider.isLoading;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset('assets/images/today.png')
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Today's Activity",
                        style: AppTextStyles.title(
                          color: const Color(0xFF1A1F36),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${todaysLog?.logs.length ?? 0}',
                        style: AppTextStyles.title(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isTodaysLogExpanded = !_isTodaysLogExpanded;
                        });
                      },
                      child: Icon(
                        _isTodaysLogExpanded 
                          ? Icons.keyboard_arrow_up_rounded 
                          : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: AppConstants.spacing16),
              
              // const SizedBox(height: 20),
              
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                )
              else if (todaysLog?.logs.isEmpty ?? true)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inbox_outlined,
                            color: Color(0xFF9CA3AF),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No entries logged today',
                          style: AppTextStyles.subtitle(
                            color: const Color(0xFF6B7280),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start tracking your health',
                          style: AppTextStyles.subtitle(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isTodaysLogExpanded)
                ...todaysLog!.logs.map((entry) => _buildLogEntry(entry)).toList(),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildLogEntry(dynamic entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              entry.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: AppTextStyles.title(
                    color: const Color(0xFF1A1F36),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subtitle,
                  style: AppTextStyles.subtitle(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _formatTime(entry.time),
              style: AppTextStyles.text(
                fontSize: 11,
                color: const Color(0xFF8B5CF6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryDetails(dynamic entry) {
    if (entry.type == 'water') {
      final amount = (entry.data['totalAmount'] as num).clamp(0, double.infinity);
      return Text(
        'Total: ${amount.toStringAsFixed(0)}ml from ${entry.data['entryCount']} entries',
        style: AppTextStyles.text(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      );
    } else if (entry.type == 'protein') {
      final amount = (entry.data['totalAmount'] as num).clamp(0, double.infinity);
      return Text(
        'Total: ${amount.toStringAsFixed(0)}g from ${entry.data['entryCount']} entries',
        style: AppTextStyles.text(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      );
    } else if (entry.type == 'fiber') {
      final amount = (entry.data['totalAmount'] as num).clamp(0, double.infinity);
      return Text(
        'Total: ${amount.toStringAsFixed(0)}g from ${entry.data['entryCount']} entries',
        style: AppTextStyles.text(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

class WeightGoalGraphPainter extends CustomPainter {
  final double startWeight;
  final double currentWeight;
  final double goalWeight;
  final String unit;

  WeightGoalGraphPainter({
    required this.startWeight,
    required this.currentWeight,
    required this.goalWeight,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Calculate positions with proper margins to accommodate labels
    // Top padding for start weight label (fontSize 10 + spacing)
    const topPadding = 12.0;
    // Bottom padding for goal weight label (fontSize 10 + spacing)
    const bottomPadding = 14.0;
    // Left padding for labels so they're not cut off
    const leftPadding = 4.0;
    const rightPadding = 4.0;
    
    final graphWidth = size.width - leftPadding - rightPadding;
    final graphHeight = size.height - topPadding - bottomPadding;

    // Determine min and max weights for scaling - MUST include currentWeight
    // Find the actual min and max across all three weights (start, current, goal)
    final maxWeight = [startWeight, currentWeight, goalWeight].reduce((a, b) => a > b ? a : b);
    final minWeight = [startWeight, currentWeight, goalWeight].reduce((a, b) => a < b ? a : b);
    final weightRange = maxWeight - minWeight;
    // Ensure minimum range to prevent division by zero and provide visual padding
    final minRange = weightRange > 0 ? weightRange * 0.1 : 10.0; // 10% padding or 10 units minimum
    final padding = weightRange > 0 ? minRange : 10.0;
    final scaledMaxWeight = maxWeight + padding;
    final scaledMinWeight = minWeight - padding;
    final scaledRange = scaledMaxWeight - scaledMinWeight;
    
    // Prevent division by zero
    if (scaledRange <= 0 || graphHeight <= 0 || graphWidth <= 0) {
      return; // Don't draw if we have invalid dimensions
    }

    // Calculate Y positions (inverted because canvas Y increases downward)
    // Higher weight = smaller Y = top of graph
    // Lower weight = larger Y = bottom of graph
    var startY = topPadding + graphHeight - ((startWeight - scaledMinWeight) / scaledRange * graphHeight);
    var currentY = topPadding + graphHeight - ((currentWeight - scaledMinWeight) / scaledRange * graphHeight);
    var goalY = topPadding + graphHeight - ((goalWeight - scaledMinWeight) / scaledRange * graphHeight);
    
    // Validate that positions are valid numbers
    if (startY.isNaN || startY.isInfinite || 
        currentY.isNaN || currentY.isInfinite || 
        goalY.isNaN || goalY.isInfinite) {
      return; // Don't draw if we have invalid positions
    }
    
    // Allow positions to slightly exceed bounds for better visual representation
    // But keep them within reasonable limits to prevent drawing outside canvas
    final minY = topPadding - 10; // Allow slight overflow above
    final maxY = topPadding + graphHeight + 10; // Allow slight overflow below
    startY = startY.clamp(minY, maxY);
    currentY = currentY.clamp(minY, maxY);
    goalY = goalY.clamp(minY, maxY);

    // Create curved path from start to end - use full width for complete graph
    final path = Path();
    final startX = leftPadding;
    // Extend the curve to nearly full width (95%) for a complete-looking graph
    final endX = leftPadding + graphWidth * 0.95;
    final currentX = leftPadding + graphWidth * 0.7; // Current weight at 70% of graph width
    
    // Create a smooth curve that extends to the end
    path.moveTo(startX, startY);
    
    // Calculate end Y position (slightly above goal for visual progression)
    final endY = goalY + (currentY - goalY) * 0.3;
    
    // Use quadratic bezier for smooth curve from start to current
    final controlPointX1 = startX + (currentX - startX) * 0.5;
    final controlPointY1 = startY - (startY - currentY) * 0.3;
    path.quadraticBezierTo(controlPointX1, controlPointY1, currentX, currentY);
    
    // Continue the curve from current to end
    final controlPointX2 = currentX + (endX - currentX) * 0.5;
    final controlPointY2 = currentY + (endY - currentY) * 0.5;
    path.quadraticBezierTo(controlPointX2, controlPointY2, endX, endY);

    // Draw gradient fill under the curve - extend for complete visual
    final fillPath = Path();
    // Start from the curve path
    fillPath.moveTo(startX, startY);
    // Follow the same curve path
    fillPath.quadraticBezierTo(controlPointX1, controlPointY1, currentX, currentY);
    fillPath.quadraticBezierTo(controlPointX2, controlPointY2, endX, endY);
    // Extend horizontally to the right edge for complete graph
    final fillEndX = leftPadding + graphWidth;
    fillPath.lineTo(fillEndX, endY);
    // Drop down to bottom
    fillPath.lineTo(fillEndX, topPadding + graphHeight);
    // Go back to start point at bottom
    fillPath.lineTo(startX, topPadding + graphHeight);
    fillPath.close();

    // Create gradient - diagonal from top-left to bottom-right for better visual effect
    // The ClipRect wrapper will handle clipping to card bounds
    final gradient = ui.Gradient.linear(
      Offset(startX, topPadding),
      Offset(fillEndX, topPadding + graphHeight),
      [
        const Color(0xFFEB579F).withOpacity(0.5),
        const Color(0xFFEB579F).withOpacity(0.02),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    final linePaint = Paint()
      ..color = const Color(0xFFEB579F)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw dotted line for goal - extend to full width
    final goalX = leftPadding + graphWidth;
    final dottedPaint = Paint()
      ..color = const Color(0xFFA0A0A0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dashWidth = 4.0;
    final dashSpace = 2.0;
    double currentXPos = startX;
    while (currentXPos < goalX) {
      final dashEnd = (currentXPos + dashWidth).clamp(startX, goalX);
      canvas.drawLine(
        Offset(currentXPos, goalY),
        Offset(dashEnd, goalY),
        dottedPaint,
      );
      currentXPos += dashWidth + dashSpace;
      if (currentXPos >= goalX) break;
    }

    // Draw labels
    final textStyle = AppTextStyles.text(
      color: const Color(0xFFA0A0A0),
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );

    // Top-left label (starting weight) - show 3 decimals like "330.693"
    final startText = startWeight.toStringAsFixed(3);
    final startTextSpan = TextSpan(
      text: startText,
      style: textStyle,
    );
    final startTextPainter = TextPainter(
      text: startTextSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    startTextPainter.layout(maxWidth: (leftPadding + graphWidth) * 0.5);
    // Position label above the start point, with left padding to avoid cutoff
    final startLabelX = leftPadding;
    final startLabelY = (startY - startTextPainter.height - 2).clamp(
      0.0,
      topPadding + graphHeight - startTextPainter.height,
    );
    if (startLabelX + startTextPainter.width <= size.width && 
        startLabelY >= 0 && startLabelY + startTextPainter.height <= size.height) {
      startTextPainter.paint(canvas, Offset(startLabelX, startLabelY));
    }

    // Bottom label (goal weight) - show 2 decimals like "176.37"
    final goalText = goalWeight.toStringAsFixed(2);
    final goalTextSpan = TextSpan(
      text: goalText,
      style: textStyle,
    );
    final goalTextPainter = TextPainter(
      text: goalTextSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    goalTextPainter.layout(maxWidth: (leftPadding + graphWidth) * 0.5);
    // Position label at the bottom of the graph area, with left padding to avoid cutoff
    final goalLabelX = leftPadding;
    final desiredY = topPadding + graphHeight + 2;
    final maxSafeY = size.height - goalTextPainter.height - 2;
    // Use the smaller of desired position or safe position to ensure it fits
    final goalLabelY = desiredY < maxSafeY ? desiredY : maxSafeY;
    if (goalLabelX + goalTextPainter.width <= size.width && 
        goalLabelY + goalTextPainter.height <= size.height) {
      goalTextPainter.paint(canvas, Offset(goalLabelX, goalLabelY));
    }

    // Pink pill label for current weight - show 2 decimals like "231.48"
    final pillText = currentWeight.toStringAsFixed(2);
    final pillTextSpan = TextSpan(
      text: pillText,
      style: AppTextStyles.title(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
    final pillTextPainter = TextPainter(
      text: pillTextSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    pillTextPainter.layout(maxWidth: (leftPadding + graphWidth) * 0.5);

    final pillWidth = pillTextPainter.width + 10;
    final pillHeight = 20.0;
    final pillX = (currentX - pillWidth / 2).clamp(leftPadding, leftPadding + graphWidth - pillWidth);
    final pillY = (currentY - pillHeight - 5).clamp(topPadding, topPadding + graphHeight - pillHeight);
    
    // Only draw if it fits within bounds (both horizontal and vertical)
    if (pillX >= leftPadding && 
        pillX + pillWidth <= size.width && 
        pillY >= topPadding && 
        pillY + pillHeight <= topPadding + graphHeight) {

      // Draw pill background
      final pillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pillX, pillY, pillWidth, pillHeight),
        const Radius.circular(11),
      );
      final pillPaint = Paint()
        ..color = const Color(0xFFEB579F)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(pillRect, pillPaint);

      // Draw pill text
      pillTextPainter.paint(
        canvas,
        Offset(pillX + (pillWidth - pillTextPainter.width) / 2, pillY + (pillHeight - pillTextPainter.height) / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WeightGoalGraphPainter oldDelegate) =>
      oldDelegate.startWeight != startWeight ||
      oldDelegate.currentWeight != currentWeight ||
      oldDelegate.goalWeight != goalWeight ||
      oldDelegate.unit != unit;
}

class GoalChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Create an upward trending line
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.9, size.height * 0.2),
    ];
    
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    canvas.drawPath(path, paint);
    
    // Draw the endpoint dot
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(points.last, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}