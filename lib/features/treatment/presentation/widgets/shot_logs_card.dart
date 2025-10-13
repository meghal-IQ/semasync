import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/api/services/treatment_service.dart';
import '../../../../core/api/models/shot_log_model.dart';
import '../../../../core/api/models/api_response.dart';
import '../providers/side_effect_provider.dart';

class ShotLogsCard extends StatefulWidget {
  const ShotLogsCard({super.key});

  @override
  State<ShotLogsCard> createState() => _ShotLogsCardState();
}

class _ShotLogsCardState extends State<ShotLogsCard> {
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  'Shot History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: _loadShots,
                  icon: const Icon(Icons.refresh),
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.spacing32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: AppConstants.spacing8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_shots.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No shots logged yet.\nTap the + button to log your first shot.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              Consumer<SideEffectProvider>(
                builder: (context, sideEffectProvider, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _shots.length,
                    itemBuilder: (context, index) {
                      final shot = _shots[index];
                      return _buildShotItem(shot, sideEffectProvider);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShotItem(ShotLog shot, SideEffectProvider sideEffectProvider) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    
    // Get side effects for this shot
    final shotSideEffects = sideEffectProvider.sideEffects
        .where((effect) => effect.shotId == shot.id)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shot header with date and time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormatter.format(shot.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    timeFormatter.format(shot.date),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing8,
                  vertical: AppConstants.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Text(
                  shot.dosage,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacing8),
          
          // Shot details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.medication,
                  label: 'Medication',
                  value: shot.medication,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.location_on,
                  label: 'Site',
                  value: shot.injectionSite,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.sick,
                  label: 'Pain',
                  value: '${shot.painLevel}/10',
                  color: _getPainColor(shot.painLevel),
                ),
              ),
            ],
          ),
          
          // Side effects section
          if (shotSideEffects.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacing8),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppConstants.spacing4),
                      Text(
                        'Side Effects (${shotSideEffects.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  ...shotSideEffects.map((effect) => _buildSideEffectItem(effect)),
                ],
              ),
            ),
          ] else if (shot.sideEffects.isNotEmpty && shot.sideEffects.first != 'None') ...[
            const SizedBox(height: AppConstants.spacing8),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppConstants.spacing4),
                      const Text(
                        'Reported Side Effects',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Wrap(
                    spacing: AppConstants.spacing4,
                    runSpacing: AppConstants.spacing4,
                    children: shot.sideEffects
                        .where((effect) => effect != 'None')
                        .map((effect) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacing6,
                                vertical: AppConstants.spacing2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.2),
                              ),
                              child: Text(
                                effect,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.warning,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
          
          // Notes
          if (shot.notes != null && shot.notes!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacing8),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppConstants.spacing4),
                  Expanded(
                    child: Text(
                      shot.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: color ?? AppColors.textSecondary,
            ),
            const SizedBox(width: AppConstants.spacing4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSideEffectItem(dynamic sideEffect) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing4),
      padding: const EdgeInsets.all(AppConstants.spacing6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sideEffect.effects?.isNotEmpty == true 
                    ? sideEffect.effects[0]['name'] ?? 'Unknown Effect'
                    : 'Side Effect',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getSeverityColor(sideEffect.overallSeverity ?? 0),
                ),
                child: Text(
                  '${(sideEffect.overallSeverity ?? 0).toStringAsFixed(1)}/10',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (sideEffect.notes != null && sideEffect.notes.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacing2),
            Text(
              sideEffect.notes,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPainColor(int painLevel) {
    if (painLevel <= 2) return Colors.green;
    if (painLevel <= 5) return Colors.orange;
    return Colors.red;
  }

  Color _getSeverityColor(double severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 6) return Colors.orange;
    return Colors.red;
  }
}
