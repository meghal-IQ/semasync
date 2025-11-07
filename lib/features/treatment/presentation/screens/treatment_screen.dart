import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/models/shot_log_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/standard_widgets.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/enhanced_medication_level_card.dart';
import '../widgets/medication_level_graph_widget.dart';
import '../widgets/medication_level_card.dart';
import '../widgets/medication_level_card_simplified.dart';
import '../widgets/dose_cards.dart';
import '../widgets/injection_site_card.dart';
import '../widgets/side_effects_card.dart';
import '../widgets/side_effects_card_updated.dart';
import '../widgets/weekly_checkup_card.dart';
import '../providers/side_effect_provider.dart';
import '../providers/medication_level_provider.dart';
import '../../../../core/providers/weekly_checkup_provider.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/api/models/weight_log_model.dart';
import '../../../../core/api/models/weekly_checkup_model.dart';
import '../../domain/models/side_effect.dart';
import 'side_effect_logging_screen.dart';
import 'weekly_checkup_screen.dart';
import 'shot_history_screen.dart';
import 'treatment_settings_screen.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final treatmentProvider = Provider.of<TreatmentProvider>(context, listen: false);
      final sideEffectProvider = Provider.of<SideEffectProvider>(context, listen: false);
      final medicationLevelProvider = Provider.of<MedicationLevelProvider>(context, listen: false);
      final weeklyCheckupProvider = Provider.of<WeeklyCheckupProvider>(context, listen: false);
      
      treatmentProvider.loadTreatmentData();
      sideEffectProvider.loadSideEffects(forceRefresh: true);
      sideEffectProvider.loadCurrentSideEffects(forceRefresh: true);
      sideEffectProvider.loadAnalytics(forceRefresh: true);
      medicationLevelProvider.loadCurrentMedicationLevel(forceRefresh: true);
      medicationLevelProvider.loadHistoricalData(days: 7, includePredictions: true);
      medicationLevelProvider.loadTrends(days: 30);
      medicationLevelProvider.calculateAndStoreMedicationLevel();
      weeklyCheckupProvider.loadLatestWeeklyCheckup();
      weeklyCheckupProvider.loadWeeklyCheckups();
      
      final healthProvider = Provider.of<HealthProvider>(context, listen: false);
      healthProvider.loadWeightData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadData();
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  children: [
                    // Medication Level Card
                    _buildMedicationLevelCard(),
                    const SizedBox(height: AppConstants.spacing16),
                    
                    // Last Dose and Next Dose Cards side by side
                    Row(
                      children: [
                        Expanded(child: _buildLastDoseCard()),
                        const SizedBox(width: AppConstants.spacing8),
                        Expanded(child: _buildNextDoseCard()),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    
                    // Side Effects Card
                    _buildSideEffectsCard(),
                    const SizedBox(height: AppConstants.spacing16),
                    
                    // Weekly Checkup Section
                    _buildWeeklyCheckupSection(),
                    const SizedBox(height: AppConstants.spacing24),
                    
                    // Options Section
                    _buildOptionsSection(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16, vertical: AppConstants.spacing12),
      child: Row(
        children: [
          Text(
            'Treatment',
            style: AppTextStyles.title(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationLevelCard() {
    return Consumer<MedicationLevelProvider>(
      builder: (context, medicationProvider, child) {
        final currentLevel = medicationProvider.currentLevelPercentage;
        final levelRounded = currentLevel.round();
        final isOptimal = levelRounded >= 70 && levelRounded <= 95;
        final statusText = isOptimal ? 'Optimal' : (levelRounded > 95 ? 'High' : 'Low');
        
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
                    'assets/images/injection.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.vaccines,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing8,
                      vertical: AppConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFEEE4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: AppTextStyles.text(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF037952),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing12),
              Text(
                'Current Status',
                style: AppTextStyles.subtitle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing12,
                      vertical: AppConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: Text(
                      '$levelRounded%',
                      style: AppTextStyles.text(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (currentLevel / 100).clamp(0.0, 1.0),
                        backgroundColor: AppColors.darkGrey,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                        minHeight: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLastDoseCard() {
    return Consumer<TreatmentProvider>(
      builder: (context, treatmentProvider, child) {
        final lastShot = treatmentProvider.latestShot;
        
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
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.add_box_outlined,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Text(
                    'Last Dose',
                    style: AppTextStyles.title(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing12),
              if (lastShot != null) ...[
                Text(
                  lastShot.dosage,
                  style: AppTextStyles.title(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing6),
                Text(
                  lastShot.medication,
                  style: AppTextStyles.subtitle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  DateFormat('MMM d, h:mm a').format(lastShot.date),
                  style: AppTextStyles.subtitle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ] else ...[
                Text(
                  'No data',
                  style: AppTextStyles.text(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  'Log your first shot',
                  style: AppTextStyles.subtitle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNextDoseCard() {
    return Consumer<TreatmentProvider>(
      builder: (context, treatmentProvider, child) {
        final nextShot = treatmentProvider.nextShotInfo;
        
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
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.add_box_outlined,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Text(
                    'Next Dose',
                    style: AppTextStyles.title(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing12),
              if (nextShot != null && nextShot.hasShots) ...[
                _buildCountdownProgress(nextShot),
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  DateFormat('MMM d, h:mm a').format(nextShot.nextDueDate!),
                  style: AppTextStyles.subtitle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ] else ...[
                Text(
                  'No data',
                  style: AppTextStyles.text(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  'Log your first shot',
                  style: AppTextStyles.subtitle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdownProgress(NextShotInfo nextShot) {
    const double totalCycleHours = 7.0 * 24.0;
    final double remainingHours = nextShot.hoursUntilNext;
    double targetProgress = 0.0;

    if (!nextShot.isOverdue) {
      final clampedRemainingHours = remainingHours.clamp(0.0, totalCycleHours);
      targetProgress = (clampedRemainingHours / totalCycleHours).clamp(0.0, 1.0);
    }

    final daysRemaining = nextShot.daysUntilNext.toInt();
    final hoursRemaining = (nextShot.hoursUntilNext % 24).toInt();
    final displayText = nextShot.isOverdue
        ? 'Overdue'
        : (nextShot.countdown?.isNotEmpty == true ? nextShot.countdown! : '${daysRemaining}d ${hoursRemaining}h');

    final bool useLightText = targetProgress >= 0.25;
    final Color progressColor = nextShot.isOverdue ? AppColors.error : AppColors.continueButton;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final double progressWidth = constraints.maxWidth * targetProgress;
              if (progressWidth <= 0) {
                return const SizedBox.shrink();
              }

              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: progressWidth,
                  height: 48,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              );
            },
          ),
          Text(
            displayText,
            style: AppTextStyles.text(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: useLightText ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideEffectsCard() {
    return Consumer<SideEffectProvider>(
      builder: (context, sideEffectProvider, child) {
        final currentSideEffects = sideEffectProvider.currentSideEffects;
        
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
                    'assets/images/injection_line.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.warning_amber,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Text(
                    'Side Effects',
                    style: AppTextStyles.title(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, size: 24),
                    color: AppColors.textPrimary,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SideEffectLoggingScreen(),
                        ),
                      );
                      sideEffectProvider.loadCurrentSideEffects(forceRefresh: true);
                      sideEffectProvider.loadSideEffects(forceRefresh: true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing16),
              if (currentSideEffects != null && currentSideEffects.isNotEmpty) ...[
                ..._getTopSideEffects(currentSideEffects).take(3).map((sideEffectDetail) => 
                  _buildSideEffectItem(sideEffectDetail)
                ).toList(),
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  _getLatestTimestamp(currentSideEffects),
                  style: AppTextStyles.subtitle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'No side effects reported',
                      style: AppTextStyles.subtitle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<SideEffectDetail> _getTopSideEffects(List<SideEffect> sideEffects) {
    final allEffects = <SideEffectDetail>[];
    for (final sideEffectLog in sideEffects) {
      allEffects.addAll(sideEffectLog.effects);
    }
    allEffects.sort((a, b) => b.severity.compareTo(a.severity));
    return allEffects;
  }

  Widget _buildSideEffectItem(SideEffectDetail sideEffectDetail) {
    final name = sideEffectDetail.name;
    final severity = sideEffectDetail.severity;
    const maxSeverity = 10.0;
    final progress = (severity / maxSeverity).clamp(0.0, 1.0);
    final severityScore = severity.round();
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.text(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.darkGrey,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.error),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Text(
            '$severityScore/${maxSeverity.toInt()}',
            style: AppTextStyles.text(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getLatestTimestamp(List<SideEffect> sideEffects) {
    if (sideEffects.isEmpty) {
      final now = DateTime.now();
      final day = now.day;
      final ordinal = _getOrdinal(day);
      return DateFormat('MMMM d\'$ordinal\' yyyy, h:mm a').format(now);
    }
    
    final latest = sideEffects.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    final day = latest.date.day;
    final ordinal = _getOrdinal(day);
    return DateFormat('MMMM d\'$ordinal\' yyyy, h:mm a').format(latest.date);
  }

  String _getOrdinal(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  Widget _buildWeeklyCheckupSection() {
    return Consumer3<WeeklyCheckupProvider, HealthProvider, TreatmentProvider>(
      builder: (context, checkupProvider, healthProvider, treatmentProvider, child) {
        final latestCheckup = checkupProvider.latestCheckup;
        final isDue = checkupProvider.isDueForWeeklyCheckup();
        final weightStats = healthProvider.weightStats;
        final weightHistory = healthProvider.weightHistory;
        
        final currentWeight = weightStats?.currentWeight;
        WeightLog? latestWeightEntry;
        if (weightHistory.isNotEmpty) {
          latestWeightEntry = weightHistory.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
        }
        final weightUnit = weightStats?.unit ?? latestWeightEntry?.unit ?? 'kg';
        final weightChange = weightStats?.weekChange ?? 0.0;
        
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Checkup',
                    style: AppTextStyles.title(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing8,
                      vertical: AppConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF099B6A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Up to date',
                      style: AppTextStyles.text(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing16),
              Row(
                children: [
                  Expanded(
                    child: _buildCheckupCard(
                      icon: 'assets/images/calender.png',
                      title: 'Last Checkup',
                      value: latestCheckup != null ? _formatDaysAgo(latestCheckup.date) : 'No data',
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Expanded(
                    child: _buildCheckupCard(
                      icon: 'assets/images/weight.png',
                      title: 'Weight',
                      value: currentWeight != null 
                          ? '${currentWeight.toStringAsFixed(1)} $weightUnit'
                          : (latestWeightEntry != null
                            ? '${latestWeightEntry.weight.toStringAsFixed(1)} ${latestWeightEntry.unit}'
                            : 'No data'),
                      badge: weightChange != 0
                          ? '${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} $weightUnit'
                          : '0.0 $weightUnit',
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Expanded(
                    child: _buildCheckupCard(
                      icon: 'assets/images/injection_line.png',
                      title: 'Side \neffects',
                      value: latestCheckup != null
                          ? '${latestCheckup.sideEffects.length} (${latestCheckup.overallSideEffectSeverity.toStringAsFixed(1)}/10)'
                          : '0 (0.0/10)',
                    ),
                  ),
                ],
              ),
              if (latestCheckup != null) ...[
                const SizedBox(height: AppConstants.spacing16),
                _buildRecommendationCard(latestCheckup),
              ],
              const SizedBox(height: AppConstants.spacing16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showWeeklyCheckupDialog(context),
                  icon: Image.asset(
                    'assets/images/dosage.png',
                    color: Colors.white,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.add_box_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  label: Text(
                    'View Checkup',
                    style: AppTextStyles.text(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.continueButton,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckupCard({
    required String icon,
    required String title,
    required String value,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 16,
            height: 16,
          color: AppColors.textSecondary,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.info,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
            textAlign: TextAlign.center,
                  style: AppTextStyles.text(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (badge != null) ...[
            const SizedBox(height: AppConstants.spacing4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
    textAlign: TextAlign.center,
                style: AppTextStyles.text(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(WeeklyCheckup checkup) {
    final recommendation = DosageRecommendation.values.firstWhere(
      (r) => r.name == checkup.dosageRecommendation,
      orElse: () => DosageRecommendation.continueCurrent,
    );

    final isContinue = recommendation == DosageRecommendation.continueCurrent;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: isContinue ? AppColors.success.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: isContinue ? AppColors.success : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing8),
              Expanded(
                child: Text(
                  recommendation.displayName,
                  style: AppTextStyles.title(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isContinue ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            recommendation.description,
            style: AppTextStyles.text(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            checkup.recommendationReason,
            style: AppTextStyles.subtitle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDaysAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return '1 day ago';
    } else {
      return '$difference days ago';
    }
  }

  void _showWeeklyCheckupDialog(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeeklyCheckupScreen()),
    );
    
    final weeklyCheckupProvider = Provider.of<WeeklyCheckupProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    
    await weeklyCheckupProvider.loadLatestWeeklyCheckup();
    await weeklyCheckupProvider.loadWeeklyCheckups();
    await healthProvider.loadWeightData();
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options',
          style: AppTextStyles.title(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        StandardNavigationItem(
          icon: Icons.access_time,
          title: 'Shot History',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShotHistoryScreen()),
            );
          },
        ),
        const SizedBox(height: AppConstants.spacing12),
        StandardNavigationItem(
          icon: Icons.settings,
          title: 'Treatment Settings',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TreatmentSettingsScreen()),
            );
          },
        ),
      ],
    );
  }
}
