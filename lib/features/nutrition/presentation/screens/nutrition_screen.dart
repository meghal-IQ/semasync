import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/nutrition_summary_card.dart';
import '../widgets/water_intake_card.dart';
import '../widgets/macro_goals_card.dart';
import '../widgets/meal_log_card.dart';
import '../widgets/nutrition_history_card.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {
              // TODO: Open food search
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_outlined),
            onPressed: () {
              // TODO: Open barcode scanner
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Today Tab
          ListView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            children: const [
              NutritionSummaryCard(),
              SizedBox(height: AppConstants.spacing16),
              WaterIntakeCard(),
              SizedBox(height: AppConstants.spacing16),
              MacroGoalsCard(),
              SizedBox(height: AppConstants.spacing16),
              MealLogCard(),
            ],
          ),
          // History Tab
          const NutritionHistoryCard(),
        ],
      ),
    );
  }
}




