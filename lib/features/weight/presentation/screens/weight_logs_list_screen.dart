import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../logging/presentation/screens/weight_logging_screen.dart';

class WeightLogsListScreen extends StatefulWidget {
  const WeightLogsListScreen({super.key});

  @override
  State<WeightLogsListScreen> createState() => _WeightLogsListScreenState();
}

class _WeightLogsListScreenState extends State<WeightLogsListScreen> {
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
      appBar: AppBar(
        title: const Text(
          'All Log Shot',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeightLoggingScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<HealthProvider, AuthProvider>(
        builder: (context, healthProvider, authProvider, child) {
          if (healthProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final history = healthProvider.weightHistory;
          final preferredUnit = authProvider.user?.preferredUnits.weight ?? 'kg';

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monitor_weight_outlined,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  const Text(
                    'No weight logs yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  const Text(
                    'Tap + to add your first entry',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final log = history[index];
              final isFirst = index == 0;
              final isLast = index == history.length - 1;
              
              // Calculate change from previous entry (in kg)
              double? changeKg;
              if (!isLast) {
                final previousLog = history[index + 1];
                changeKg = log.weight - previousLog.weight;
              }

              return _buildWeightLogCard(
                log: log,
                changeKg: changeKg,
                isFirst: isFirst,
                preferredUnit: preferredUnit,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWeightLogCard({
    required dynamic log,
    double? changeKg,
    required bool isFirst,
    required String preferredUnit,
  }) {
    // Convert weight to preferred unit based on original unit
    double weightConverted;
    if (log.unit.toLowerCase() == preferredUnit.toLowerCase()) {
      // Same unit, no conversion needed
      weightConverted = log.weight;
    } else if (log.unit.toLowerCase() == 'lbs' && preferredUnit.toLowerCase() == 'kg') {
      // Convert from lbs to kg
      weightConverted = UnitConverter.convertWeightToKg(log.weight, 'lbs');
    } else if (log.unit.toLowerCase() == 'kg' && preferredUnit.toLowerCase() == 'lbs') {
      // Convert from kg to lbs
      weightConverted = UnitConverter.convertWeight(log.weight, 'lbs');
    } else {
      // Fallback to original weight
      weightConverted = log.weight;
    }
    
    // Convert change from kg to preferred unit
    final change = changeKg != null ? UnitConverter.convertWeight(changeKg.abs(), preferredUnit) : null;
    final isPositive = changeKg != null && changeKg > 0;
    final isNegative = changeKg != null && changeKg < 0;
    final sign = isPositive ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Weight Display - darker grey badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weightConverted.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  preferredUnit.toLowerCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppConstants.spacing16),
          
          // Weight Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weight Entry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Row(
                  children: [
                    if (change != null) ...[
                      Icon(
                        isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 16,
                        color: isNegative ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: AppConstants.spacing4),
                      Text(
                        '$sign${change.toStringAsFixed(1)}${preferredUnit.toLowerCase()}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isNegative ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                        ),
                      ),
                    ] else ...[
                      Text(
                        '0.00${preferredUnit.toLowerCase()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
                if (log.notes != null && log.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    log.notes!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Timestamp only
          Text(
            _formatTime(log.date),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

