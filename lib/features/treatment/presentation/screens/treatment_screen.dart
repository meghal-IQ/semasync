import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
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
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Treatment',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1F36),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
          // Wait a bit to ensure data is loaded
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
          const EnhancedMedicationLevelCard(),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: DoseCard(type: DoseType.last)),
              SizedBox(width: 20),
              Expanded(child: DoseCard(type: DoseType.next)),
            ],
          ),
          const SizedBox(height: 20),
          const SideEffectsCard(),
          
          const SizedBox(height: 20),
          const WeeklyCheckupCard(),
          
          const SizedBox(height: 30),
          
          // Options Section
          _buildSectionHeader('OPTIONS'),
          const SizedBox(height: 16),
          
          _buildNavigationItem(
            context,
            icon: Icons.history_outlined,
            title: 'Shot History',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShotHistoryScreen()),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildNavigationItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Treatment Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TreatmentSettingsScreen()),
              );
            },
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9CA3AF),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Icon(
                icon, 
                color: AppColors.primary, 
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F36),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded, 
              color: const Color(0xFF9CA3AF), 
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}


