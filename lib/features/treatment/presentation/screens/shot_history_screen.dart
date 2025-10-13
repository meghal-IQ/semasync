import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/api/services/treatment_service.dart';
import '../../../../core/api/models/shot_log_model.dart';
import '../../../../core/api/models/api_response.dart';
import '../../../../core/providers/treatment_provider.dart';
import '../providers/side_effect_provider.dart';
import '../widgets/shot_log_item.dart';

class ShotHistoryScreen extends StatefulWidget {
  const ShotHistoryScreen({super.key});

  @override
  State<ShotHistoryScreen> createState() => _ShotHistoryScreenState();
}

class _ShotHistoryScreenState extends State<ShotHistoryScreen> {
  final TreatmentService _treatmentService = TreatmentService();
  List<ShotLog> _shots = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadShots();
  }

  Future<void> _loadShots() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _treatmentService.getShotHistory();
      if (response.success && response.data != null) {
        setState(() {
          _shots = response.data!.shots;
          _isLoading = false;
        });
        
        // Also refresh the TreatmentProvider so other screens update
        if (mounted) {
          await context.read<TreatmentProvider>().loadTreatmentData();
        }
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load shots: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'All Shot Logs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const ShotLoggingScreen()),
              // ).then((_) => _loadShots()); // Reload after adding new shot
            },
          ),
        ],
      ),
      body: _buildBody(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // TODO: Navigate to shot logging screen
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Shot logging feature coming soon!')),
      //     );
      //   },
      //   backgroundColor: Colors.black,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'Failed to load shot history',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing24),
            ElevatedButton(
              onPressed: _loadShots,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_shots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'No shots logged yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Tap the + button to log your first shot',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Consumer<SideEffectProvider>(
      builder: (context, sideEffectProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          itemCount: _shots.length,
          itemBuilder: (context, index) {
            final shot = _shots[index];
            return ShotLogItem(
              shot: shot,
              sideEffects: sideEffectProvider.sideEffects
                  .where((effect) => effect.shotId == shot.id)
                  .toList(),
              onDeleted: _loadShots,
              onUpdated: _loadShots,
            );
          },
        );
      },
    );
  }
}
