import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/standard_widgets.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/enhanced_medication_level_card.dart';
import '../widgets/dose_card.dart';
import '../widgets/side_effects_card.dart';
import '../widgets/weekly_checkup_card.dart';
import '../providers/side_effect_provider.dart';
import '../providers/medication_level_provider.dart';
import '../../../../core/providers/weekly_checkup_provider.dart';
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
      // title: 'Treatment',
      appBar: AppBar(
        title: Text('Treatment'),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
          // Wait a bit to ensure data is loaded
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          children: [
            const EnhancedMedicationLevelCard(),
            const SizedBox(height: AppConstants.spacing16),
            const Row(
              children: [
                Expanded(child: DoseCard(type: DoseType.last)),
                SizedBox(width: AppConstants.spacing16),
                Expanded(child: DoseCard(type: DoseType.next)),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            const SideEffectsCard(),
            
            const SizedBox(height: AppConstants.spacing16),
            const WeeklyCheckupCard(),
            
            const SizedBox(height: AppConstants.spacing24),
            
            // Options Section
            StandardSectionHeader(title: 'OPTIONS'),
            const SizedBox(height: AppConstants.spacing16),
            
            StandardNavigationItem(
              icon: Icons.history_outlined,
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
              icon: Icons.settings_outlined,
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


