import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/standard_widgets.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../../../../core/theme/app_colors.dart';
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
import 'shot_history_screen.dart';
import 'treatment_settings_screen.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false; // Don't keep alive to ensure refresh
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load treatment data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final treatmentProvider = Provider.of<TreatmentProvider>(context, listen: false);
      final sideEffectProvider = Provider.of<SideEffectProvider>(context, listen: false);
      final medicationLevelProvider = Provider.of<MedicationLevelProvider>(context, listen: false);
      final weeklyCheckupProvider = Provider.of<WeeklyCheckupProvider>(context, listen: false);
      
      // Load treatment data (shots, medication level, next shot info)
      treatmentProvider.loadTreatmentData();
      
      // Load side effects with force refresh
      sideEffectProvider.loadSideEffects(forceRefresh: true);
      sideEffectProvider.loadCurrentSideEffects(forceRefresh: true);
      sideEffectProvider.loadAnalytics(forceRefresh: true);
      
      // Load medication level data
      medicationLevelProvider.loadCurrentMedicationLevel(forceRefresh: true);
      medicationLevelProvider.loadHistoricalData(days: 7, includePredictions: true);
      medicationLevelProvider.loadTrends(days: 30);
      
      // Calculate and store current medication level if not already done
      medicationLevelProvider.calculateAndStoreMedicationLevel();
      
      // Load weekly checkup data
      weeklyCheckupProvider.loadLatestWeeklyCheckup();
      weeklyCheckupProvider.loadWeeklyCheckups();
      
      // Load health data (weight)
      final healthProvider = Provider.of<HealthProvider>(context, listen: false);
      healthProvider.loadWeightData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when navigating back to this screen
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Treatment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
          // Wait a bit to ensure data is loaded
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          children: [
            // Medication Level Card - simplified with percentage and progress bar
            const MedicationLevelCardSimplified(),
            const SizedBox(height: AppConstants.spacing16),
            
            // Last Dose and Next Dose Cards side by side
             Row(
              children: [
                Expanded(child: LastDoseCard()),
                SizedBox(width: AppConstants.spacing16),
                Expanded(child: NextDoseCard()),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            
            // Side Effects Card
            const SideEffectsCardUpdated(),
            const SizedBox(height: AppConstants.spacing16),
            
            // Weekly Checkup Section
            // _WeeklyCheckupSection(),
            // const SizedBox(height: AppConstants.spacing16),

            // Treatment Plan Recommendation Card
            const WeeklyCheckupCard(),
            const SizedBox(height: AppConstants.spacing24),
            
            // Options Section
            StandardSectionHeader(title: 'OPTIONS'),
            const SizedBox(height: AppConstants.spacing16),
            
            StandardNavigationItem(
              icon: Icons.access_time, // Clock with arrow
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
              icon: Icons.settings, // Gear icon
              title: 'Treatment Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TreatmentSettingsScreen()),
                );
              },
            ),
            
            const SizedBox(height: AppConstants.spacing80),
          ],
        ),
      ),
    );
  }

}

// Weekly Checkup Section Widget
class _WeeklyCheckupSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3<WeeklyCheckupProvider, HealthProvider, TreatmentProvider>(
      builder: (context, checkupProvider, healthProvider, treatmentProvider, child) {
        final latestCheckup = checkupProvider.latestCheckup;
        final weightStats = healthProvider.weightStats;
        final weightHistory = healthProvider.weightHistory;
        
        // Get current weight from stats or latest history entry
        final currentWeight = weightStats?.currentWeight;
        WeightLog? latestWeightEntry;
        if (weightHistory.isNotEmpty) {
          // Find the most recent weight entry (sort by date descending)
          latestWeightEntry = weightHistory.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
        }
        final weightUnit = weightStats?.unit ?? latestWeightEntry?.unit ?? 'kg';
        // Get weight change from stats (week change) or calculate from history
        final weightChange = weightStats?.weekChange ?? 0.0;
        
        return Card(
          color: AppColors.lightGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Weekly Checkup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing8,
                        vertical: AppConstants.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xff099b6a),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Up to date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing16),
                // Three horizontal cards
                Row(
                  children: [
                    Expanded(
                      child: _buildCheckupCard(
                        icon: Icons.calendar_today,
                        title: 'Last Checkup',
                        value: latestCheckup != null 
                          ? _formatDaysAgo(latestCheckup.date)
                          : 'No data',
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Expanded(
                      child: _buildCheckupCard(
                        icon: Icons.monitor_weight,
                        title: 'Weight',
                        value: currentWeight != null 
                          ? '${currentWeight.toStringAsFixed(1)} $weightUnit'
                          : (latestWeightEntry != null
                            ? '${latestWeightEntry.weight.toStringAsFixed(1)} ${latestWeightEntry.unit}'
                            : 'No data'),
                        badge: weightChange != 0
                          ? '${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} $weightUnit'
                          : null,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Expanded(
                      child: _buildCheckupCard(
                        icon: Icons.auto_awesome,
                        title: 'Side effects',
                        value: latestCheckup != null
                          ? '${latestCheckup.sideEffects.length} (${latestCheckup.overallSideEffectSeverity.toStringAsFixed(1)}/10)'
                          : '0 (0.0/10)',
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

  Widget _buildCheckupCard({
    required IconData icon,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            title,
            style: const TextStyle(
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: AppConstants.spacing4),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
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
}


