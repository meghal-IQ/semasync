import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/standard_widgets.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/providers/activity_provider.dart';
import '../../../../core/providers/nutrition_provider.dart';
import '../../../../core/providers/historical_data_provider.dart';
import '../../../../core/api/models/nutrition_log_model.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/shot_day_widget.dart';

class SimpleSemaSyncDashboard extends StatefulWidget {
  const SimpleSemaSyncDashboard({super.key});

  @override
  State<SimpleSemaSyncDashboard> createState() => _SimpleSemaSyncDashboardState();
}

class _SimpleSemaSyncDashboardState extends State<SimpleSemaSyncDashboard> {
  bool _isTodaysLogExpanded = false;
  bool _isShotDayExpanded = true;
  Timer? _timeUpdateTimer;
  DateTime _selectedDate = DateTime.now();
  List<int> _shotDays = [3, 4]; // Wednesday and Thursday by default
  
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
            // Dashboard Header with Date Selector
            DashboardHeader(
              selectedDate: _selectedDate,
              onDateChanged: _onDateChanged,
              streakCount: 1, // TODO: Get actual streak count
            ),

            // Shot Day Selector
            const SizedBox(height: 16),
            ShotDaySelector(
              selectedDays: _shotDays,
              onDaysChanged: (days) {
                setState(() {
                  _shotDays = days;
                });
              },
            ),

            // Shot Day Widget (only shows on shot days)
            const SizedBox(height: 16),
            ShotDayWidget(
              selectedDays: _shotDays,
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                child: Column(
                  children: [
                    const SizedBox(height: AppConstants.spacing20),
                    
                    // Medication Level Card with gradient
                    _buildEnhancedMedicationCard(),
                    
                    const SizedBox(height: AppConstants.spacing16),
                    
                    // Nutrition Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildFiberCard(),
                        ),
                        const SizedBox(width: AppConstants.spacing12),
                        Expanded(
                          child: _buildWaterCard(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.spacing12),
                    
                    // Protein and Goal Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildProteinCard(),
                        ),
                        const SizedBox(width: AppConstants.spacing12),
                        Expanded(
                          child: _buildGoalCard(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.spacing24),
                    
                    // Shot Day Reminder Section (if today is shot day)
                    _buildShotDayReminder(),
                    
                    // Today's Log Section (or Historical Log Section)
                    _buildLogSection(),
                    
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
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return Text(
                              authProvider.user?.firstName ?? 'There',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
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

  Widget _buildEnhancedMedicationCard() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    
    return Consumer2<TreatmentProvider, HistoricalDataProvider>(
      builder: (context, treatmentProvider, historicalProvider, child) {
        // For today, use the actual provider objects
        // For historical, we'll just show basic info or skip advanced features
        final medLevel = isToday ? treatmentProvider.medicationLevel : null;
        final nextShot = isToday ? treatmentProvider.nextShotInfo : null;
        
        // Get historical medication level if viewing past date
        double currentLevel = 0.0;
        if (!isToday) {
          final treatments = historicalProvider.treatmentData;
          if (treatments.isNotEmpty) {
            final treatment = treatments.first;
            currentLevel = (treatment['currentLevel'] ?? treatment['level'] ?? 0.0).toDouble();
          }
        } else if (medLevel != null) {
          currentLevel = medLevel.currentLevel;
        }
        
        return Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,  // Mint/teal
                  AppColors.primary,  // Mint/teal
                ],
              ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medication Level',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1F36),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Current Status',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShaderMask(
                             shaderCallback: (bounds) => const LinearGradient(
                               colors: [
                                 AppColors.primary,
                                 AppColors.primary,
                               ],
                             ).createShader(bounds),
                      child: Text(
                        currentLevel.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -2,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF),
                          height: 1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    //        Container(
                    //          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    //          decoration: BoxDecoration(
                    //            color: AppColors.primary.withOpacity(0.1),
                    //           borderRadius: BorderRadius.circular(10),
                    //          ),
                    //          child: Row(
                    //            mainAxisSize: MainAxisSize.min,
                    //            children: [
                    //              Container(
                    //                width: 8,
                    //                height: 8,
                    //                decoration: const BoxDecoration(
                    //                  color: AppColors.primary,
                    //                  shape: BoxShape.circle,
                    //                ),
                    //              ),
                    //              const SizedBox(width: 6),
                    //              Text(
                    //                medLevel != null ? medLevel.status.toUpperCase() : 'INACTIVE',
                    //                style: const TextStyle(
                    //                  fontSize: 11,
                    //                  fontWeight: FontWeight.w700,
                    //                  color: AppColors.primary,
                    //                  letterSpacing: 0.5,
                    //                ),
                    //              ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 12),
                // Text(
                //   medLevel != null ? medLevel.statusDisplay : 'Log your first shot to see your level',
                //   style: const TextStyle(
                //     fontSize: 14,
                //     color: Color(0xFF6B7280),
                //     fontWeight: FontWeight.w500,
                //     height: 1.4,
                //   ),
                // ),
                if (isToday && nextShot != null && nextShot.hasShots) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: nextShot.isOverdue
                                   ? [
                                       const Color(0xFFFFE5E5),
                                       const Color(0xFFFFD6D6),
                                     ]
                                   : [
                                       const Color(0xFFE5F9F7),
                                       const Color(0xFFD6F5F2),
                                     ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: nextShot.isOverdue 
                                ? const Color(0xFFFF4444)
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            nextShot.isOverdue 
                                ? Icons.warning_rounded 
                                : Icons.access_time_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nextShot.isOverdue ? 'OVERDUE' : 'NEXT DOSE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: nextShot.isOverdue 
                                      ? const Color(0xFFFF4444)
                                      : AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nextShot.countdown ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: nextShot.isOverdue 
                                      ? const Color(0xFFFF4444)
                                      : const Color(0xFFFF4444)
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Icon(
                        //   Icons.arrow_forward_ios_rounded,
                        //   size: 16,
                        //   color: nextShot.isOverdue 
                        //       ? const Color(0xFFDC2626).withOpacity(0.5)
                        //       : AppColors.primary.withOpacity(0.5),
                        // ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
                
                const Text(
                  'Fiber',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: -0.2,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${fiber.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1F36),
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'g / ${fiberGoal}g',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
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
                
                const Text(
                  'Water',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: -0.2,
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
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1F36),
                          letterSpacing: -1.5,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'ml / ${waterGoal.toStringAsFixed(0)}ml',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
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

  Widget _buildProteinCard() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    
    return Consumer2<NutritionProvider, HistoricalDataProvider>(
      builder: (context, nutritionProvider, historicalProvider, child) {
        double protein;
        if (isToday) {
          final dailySummary = nutritionProvider.dailySummary;
          protein = ((dailySummary?.protein ?? 0) as num).toDouble().clamp(0, double.infinity);
        } else {
          final historicalNutrition = historicalProvider.nutritionData;
          final proteinValue = historicalNutrition?['protein'] ?? 0;
          protein = (proteinValue as num).toDouble().clamp(0, double.infinity);
        }
        const proteinGoal = 120;
        final progress = (protein / proteinGoal * 100).clamp(0, 100);
        
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
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bakery_dining_rounded,
                    color: Color(0xFFF59E0B),
                    size: 24,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Protein',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: -0.2,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${protein.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1F36),
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'g / ${proteinGoal}g',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
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
                        () => _decrementProtein(), 
                        const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildCleanControlButton(
                        Icons.add_rounded, 
                        () => _incrementProtein(), 
                        const Color(0xFFF59E0B),
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
    
    return Consumer2<HealthProvider, HistoricalDataProvider>(
      builder: (context, healthProvider, historicalProvider, child) {
        // Get weight info
        double? currentWeight;
        String unit = 'kg';
        
        if (isToday) {
          final stats = healthProvider.weightStats;
          currentWeight = stats?.currentWeight;
          unit = stats?.unit ?? 'kg';
        } else {
          // For historical data, get weight from historical provider
          final weightData = historicalProvider.weightData;
          if (weightData.isNotEmpty) {
            final weight = weightData.first;
            currentWeight = (weight['weight'] ?? weight['currentWeight'])?.toDouble();
            unit = weight['unit'] ?? 'kg';
          }
        }
        
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
                    color: const Color(0xFFEC4899).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Color(0xFFEC4899),
                    size: 24,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Weight Goal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: -0.2,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currentWeight != null 
                          ? currentWeight.toStringAsFixed(1)
                          : '0.0',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1F36),
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Simple progress indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEC4899).withOpacity(0.1),
                        const Color(0xFFF59E0B).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.trending_down_rounded,
                        size: 16,
                        color: Color(0xFFEC4899),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'On Track',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    } else {
      // Load historical data
      context.read<HistoricalDataProvider>().loadHistoricalData(_selectedDate);
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
          calories: protein * 4, // ~4 calories per gram of protein
          protein: protein, // Can be negative for removal
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
        
        // Force refresh of daily summary to ensure UI updates
        await nutritionProvider.loadDailySummary();
        
        // Show success feedback
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
                    const Text(
                      'Shot Day',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
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
                      style: const TextStyle(
                        fontSize: 14,
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
                ),
                
                const Divider(height: 1, color: AppColors.divider),
                
                _buildShotDayTask(
                  'Drink lots of Water\n(+electrolytes)',
                  '7:00 PM',
                  false,
                ),
                
                const Divider(height: 1, color: AppColors.divider),
                
                _buildShotDayTask(
                  'Load Syringe and let come to\nroom temp',
                  '7:15 PM',
                  false,
                ),
                
                const Divider(height: 1, color: AppColors.divider),
                
                _buildShotDayTask(
                  'Take Shot',
                  '8:00 PM',
                  true, // Highlighted task
                ),
                
                const Divider(height: 1, color: AppColors.divider),
                
                _buildShotDayTask(
                  'Another High Protein Meal/Drink',
                  '9:00 PM',
                  false,
                ),
              ],
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildShotDayTask(String title, String time, bool isHighlighted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
      child: Row(
        children: [
          // Checkbox
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AppColors.divider,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          const SizedBox(width: AppConstants.spacing16),
          
          // Task title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
          
          // Time
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
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

  Widget _buildLogSection() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    
    if (isToday) {
      return _buildTodaysLogSection();
    } else {
      return _buildHistoricalLogSection();
    }
  }

  Widget _buildHistoricalLogSection() {
    return Consumer<HistoricalDataProvider>(
      builder: (context, historicalProvider, child) {
        if (historicalProvider.isLoading) {
          return _buildLoadingCard();
        }

        if (historicalProvider.errorMessage != null) {
          return _buildErrorCard(historicalProvider.errorMessage!);
        }

        if (!historicalProvider.hasData) {
          return _buildNoDataCard();
        }

        final logEntries = historicalProvider.logEntries;
        
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
                      child: const Icon(
                        Icons.history_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "${historicalProvider.formattedDate} Activity",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F36),
                          letterSpacing: -0.3,
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
                        '${logEntries.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (logEntries.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...logEntries.map((entry) => _buildHistoricalLogEntry(entry)).toList(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoricalLogEntry(Map<String, dynamic> entry) {
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
              entry['icon'] ?? '📝',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['title'] ?? 'Entry',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1F36),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry['subtitle'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
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
              _formatTime(DateTime.parse(entry['time'])),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No activity was logged on this date',
              style: TextStyle(
                fontSize: 14,
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
                      child: const Icon(
                        Icons.history_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Today's Activity",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F36),
                          letterSpacing: -0.3,
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
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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
                        const Text(
                          'No entries logged today',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Start tracking your health',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1F36),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
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
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8B5CF6),
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
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    } else if (entry.type == 'protein') {
      final amount = (entry.data['totalAmount'] as num).clamp(0, double.infinity);
      return Text(
        'Total: ${amount.toStringAsFixed(0)}g from ${entry.data['entryCount']} entries',
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    } else if (entry.type == 'fiber') {
      final amount = (entry.data['totalAmount'] as num).clamp(0, double.infinity);
      return Text(
        'Total: ${amount.toStringAsFixed(0)}g from ${entry.data['entryCount']} entries',
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
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