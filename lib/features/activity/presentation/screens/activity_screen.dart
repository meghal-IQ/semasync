import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/activity_summary_card.dart';
import '../widgets/step_counter_card.dart';
import '../widgets/workout_card.dart';
import '../widgets/activity_history_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
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
        title: const Text('Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () {
              // TODO: Show activity history
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Show activity settings
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
              ActivitySummaryCard(),
              SizedBox(height: AppConstants.spacing16),
              StepCounterCard(),
              SizedBox(height: AppConstants.spacing16),
              WorkoutCard(),
            ],
          ),
          // History Tab
          const ActivityHistoryCard(),
        ],
      ),
    );
  }
}




