// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/providers/health_provider.dart';
// import '../../../../core/api/models/side_effect_log_model.dart';
//
// class SideEffectLoggingScreen extends StatefulWidget {
//   const SideEffectLoggingScreen({super.key});
//
//   @override
//   State<SideEffectLoggingScreen> createState() => _SideEffectLoggingScreenState();
// }
//
// class _SideEffectLoggingScreenState extends State<SideEffectLoggingScreen> {
//   DateTime _selectedDate = DateTime.now();
//   List<Map<String, dynamic>> _selectedSideEffects = [];
//   String _notes = '';
//   double _overallSeverity = 0.0;
//   bool _isSaving = false;
//   bool _relatedToShot = false;
//
//   final List<Map<String, dynamic>> _commonSideEffects = [
//     {
//       'name': 'Nausea',
//       'icon': Icons.sick,
//       'color': AppColors.warning,
//       'severity': 0.0,
//       'description': 'Feeling sick to your stomach',
//     },
//     {
//       'name': 'Vomiting',
//       'icon': Icons.sick_outlined,
//       'color': AppColors.error,
//       'severity': 0.0,
//       'description': 'Throwing up',
//     },
//     {
//       'name': 'Diarrhea',
//       'icon': Icons.water_drop_outlined,
//       'color': AppColors.warning,
//       'severity': 0.0,
//       'description': 'Loose, watery stools',
//     },
//     {
//       'name': 'Constipation',
//       'icon': Icons.block,
//       'color': AppColors.warning,
//       'severity': 0.0,
//       'description': 'Difficulty having bowel movements',
//     },
//     {
//       'name': 'Fatigue',
//       'icon': Icons.bedtime,
//       'color': AppColors.textSecondary,
//       'severity': 0.0,
//       'description': 'Feeling tired or weak',
//     },
//     {
//       'name': 'Headache',
//       'icon': Icons.healing,
//       'color': AppColors.warning,
//       'severity': 0.0,
//       'description': 'Pain in the head',
//     },
//     {
//       'name': 'Dizziness',
//       'icon': Icons.add,
//       'color': AppColors.warning,
//       'severity': 0.0,
//       'description': 'Feeling lightheaded or unsteady',
//     },
//     {
//       'name': 'Abdominal Pain',
//       'icon': Icons.pan_tool,
//       'color': AppColors.error,
//       'severity': 0.0,
//       'description': 'Pain in the stomach area',
//     },
//     {
//       'name': 'Decreased Appetite',
//       'icon': Icons.no_food,
//       'color': AppColors.textSecondary,
//       'severity': 0.0,
//       'description': 'Reduced desire to eat',
//     },
//     {
//       'name': 'Injection Site Reaction',
//       'icon': Icons.healing_outlined,
//       'color': AppColors.warning,
//       'severity': 0.0,
//       'description': 'Redness or pain at injection site',
//     },
//     {
//       'name': 'Heartburn',
//       'icon': Icons.local_fire_department,
//       'color': AppColors.warning,
//       'severity': 0.0,
//       'description': 'Burning sensation in chest',
//     },
//     {
//       'name': 'Bloating',
//       'icon': Icons.bubble_chart,
//       'color': AppColors.textSecondary,
//       'severity': 0.0,
//       'description': 'Excessive gas or bloating',
//     },
//     {
//       'name': 'Other',
//       'icon': Icons.more_horiz,
//       'color': AppColors.textSecondary,
//       'severity': 0.0,
//       'description': 'Other side effects not listed',
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Log Side Effects'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save_outlined),
//             onPressed: _saveSideEffects,
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(AppConstants.spacing16),
//         children: [
//           _buildDateSelector(),
//           const SizedBox(height: AppConstants.spacing24),
//           // _buildRelatedToShotToggle(),
//           // const SizedBox(height: AppConstants.spacing24),
//           // _buildOverallSeverity(),
//           // const SizedBox(height: AppConstants.spacing24),
//           _buildSideEffectsList(),
//           const SizedBox(height: AppConstants.spacing24),
//           _buildSelectedSideEffects(),
//           const SizedBox(height: AppConstants.spacing24),
//           _buildNotesField(),
//           const SizedBox(height: AppConstants.spacing32),
//           _buildSaveButton(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDateSelector() {
//     return Card(
//       child: ListTile(
//         leading: const Icon(Icons.calendar_today, color: AppColors.primary),
//         title: const Text('Date & Time'),
//         subtitle: Text(
//           '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at ${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
//         ),
//         trailing: const Icon(Icons.chevron_right),
//         onTap: _selectDateTime,
//       ),
//     );
//   }
//
//   Widget _buildRelatedToShotToggle() {
//     return Card(
//       child: SwitchListTile(
//         title: const Text('Related to Medication Shot?'),
//         subtitle: const Text('Did these effects occur after taking your shot?'),
//         value: _relatedToShot,
//         activeColor: AppColors.primary,
//         onChanged: (value) {
//           setState(() {
//             _relatedToShot = value;
//           });
//         },
//       ),
//     );
//   }
//
//   Widget _buildOverallSeverity() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(AppConstants.spacing16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Overall Severity',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   '${_overallSeverity.toInt()}/10',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primary,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: AppConstants.spacing16),
//             Slider(
//               value: _overallSeverity,
//               min: 0,
//               max: 10,
//               divisions: 10,
//               activeColor: AppColors.primary,
//               onChanged: (value) {
//                 setState(() {
//                   _overallSeverity = value;
//                 });
//               },
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'No Symptoms',
//                   style: TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 12,
//                   ),
//                 ),
//                 Text(
//                   'Severe Symptoms',
//                   style: TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: AppConstants.spacing12),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(AppConstants.spacing12),
//               decoration: BoxDecoration(
//                 color: _getSeverityColor().withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     _getSeverityIcon(),
//                     color: _getSeverityColor(),
//                     size: 20,
//                   ),
//                   const SizedBox(width: AppConstants.spacing8),
//                   Expanded(
//                     child: Text(
//                       _getSeverityDescription(),
//                       style: TextStyle(
//                         color: _getSeverityColor(),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSideEffectsList() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(AppConstants.spacing16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Select Side Effects',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: AppConstants.spacing12),
//             Text(
//               'Tap to select side effects you\'re experiencing',
//               style: TextStyle(
//                 color: AppColors.textSecondary,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: AppConstants.spacing16),
//             Wrap(
//               spacing: AppConstants.spacing8,
//               runSpacing: AppConstants.spacing8,
//               children: _commonSideEffects.map((sideEffect) =>
//                 _buildSideEffectChip(sideEffect)
//               ).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSideEffectChip(Map<String, dynamic> sideEffect) {
//     final isSelected = _selectedSideEffects.any((item) => item['name'] == sideEffect['name']);
//
//     return GestureDetector(
//       onTap: () => _toggleSideEffect(sideEffect),
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AppConstants.spacing12,
//           vertical: AppConstants.spacing8,
//         ),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? (sideEffect['color'] as Color).withOpacity(0.2)
//               : AppColors.textSecondary.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
//           border: Border.all(
//             color: isSelected
//                 ? sideEffect['color'] as Color
//                 : AppColors.textSecondary.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               sideEffect['icon'] as IconData,
//               color: isSelected
//                   ? sideEffect['color'] as Color
//                   : AppColors.textSecondary,
//               size: 16,
//             ),
//             const SizedBox(width: AppConstants.spacing4),
//             Text(
//               sideEffect['name'] as String,
//               style: TextStyle(
//                 color: isSelected
//                     ? sideEffect['color'] as Color
//                     : AppColors.textSecondary,
//                 fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSelectedSideEffects() {
//     if (_selectedSideEffects.isEmpty) {
//       return Card(
//         child: Padding(
//           padding: const EdgeInsets.all(AppConstants.spacing16),
//           child: Column(
//             children: [
//               Icon(
//                 Icons.check_circle_outline,
//                 size: 48,
//                 color: AppColors.textSecondary,
//               ),
//               const SizedBox(height: AppConstants.spacing12),
//               Text(
//                 'No side effects selected',
//                 style: TextStyle(
//                   color: AppColors.textSecondary,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: AppConstants.spacing8),
//               Text(
//                 'Select side effects above to track their severity',
//                 style: TextStyle(
//                   color: AppColors.textSecondary,
//                   fontSize: 12,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(AppConstants.spacing16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Selected Side Effects',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: AppConstants.spacing12),
//             ..._selectedSideEffects.map((sideEffect) =>
//               _buildSelectedSideEffectItem(sideEffect)
//             ).toList(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSelectedSideEffectItem(Map<String, dynamic> sideEffect) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
//       padding: const EdgeInsets.all(AppConstants.spacing12),
//       decoration: BoxDecoration(
//         color: (sideEffect['color'] as Color).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Icon(
//                 sideEffect['icon'] as IconData,
//                 color: sideEffect['color'] as Color,
//                 size: 20,
//               ),
//               const SizedBox(width: AppConstants.spacing8),
//               Expanded(
//                 child: Text(
//                   sideEffect['name'] as String,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               Text(
//                 '${sideEffect['severity'].toInt()}/10',
//                 style: TextStyle(
//                   color: sideEffect['color'] as Color,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(width: AppConstants.spacing8),
//               IconButton(
//                 icon: const Icon(Icons.remove_circle, color: AppColors.error),
//                 onPressed: () => _removeSideEffect(sideEffect),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppConstants.spacing8),
//           Slider(
//             value: sideEffect['severity'] as double,
//             min: 0,
//             max: 10,
//             divisions: 10,
//             activeColor: sideEffect['color'] as Color,
//             onChanged: (value) {
//               setState(() {
//                 sideEffect['severity'] = value;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotesField() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(AppConstants.spacing16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Additional Notes',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: AppConstants.spacing12),
//             TextField(
//               maxLines: 4,
//               decoration: const InputDecoration(
//                 hintText: 'Describe your side effects in more detail...',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _notes = value;
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSaveButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isSaving ? null : _saveSideEffects,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.warning,
//           padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
//         ),
//         child: _isSaving
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//             : const Text(
//                 'Log Side Effects',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//       ),
//     );
//   }
//
//   Future<void> _selectDateTime() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now().subtract(const Duration(days: 7)),
//       lastDate: DateTime.now(),
//     );
//
//     if (date != null) {
//       final time = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.fromDateTime(_selectedDate),
//       );
//
//       if (time != null) {
//         setState(() {
//           _selectedDate = DateTime(
//             date.year,
//             date.month,
//             date.day,
//             time.hour,
//             time.minute,
//           );
//         });
//       }
//     }
//   }
//
//   void _toggleSideEffect(Map<String, dynamic> sideEffect) {
//     setState(() {
//       if (_selectedSideEffects.any((item) => item['name'] == sideEffect['name'])) {
//         _selectedSideEffects.removeWhere((item) => item['name'] == sideEffect['name']);
//       } else {
//         _selectedSideEffects.add(Map<String, dynamic>.from(sideEffect));
//       }
//     });
//   }
//
//   void _removeSideEffect(Map<String, dynamic> sideEffect) {
//     setState(() {
//       _selectedSideEffects.removeWhere((item) => item['name'] == sideEffect['name']);
//     });
//   }
//
//   Color _getSeverityColor() {
//     if (_overallSeverity <= 2) return AppColors.success;
//     if (_overallSeverity <= 5) return AppColors.warning;
//     if (_overallSeverity <= 8) return AppColors.proteinOrange;
//     return AppColors.error;
//   }
//
//   IconData _getSeverityIcon() {
//     if (_overallSeverity <= 2) return Icons.check_circle;
//     if (_overallSeverity <= 5) return Icons.info;
//     if (_overallSeverity <= 8) return Icons.warning;
//     return Icons.error;
//   }
//
//   String _getSeverityDescription() {
//     if (_overallSeverity <= 2) return 'Mild symptoms - manageable';
//     if (_overallSeverity <= 5) return 'Moderate symptoms - some discomfort';
//     if (_overallSeverity <= 8) return 'Severe symptoms - significant impact';
//     return 'Very severe symptoms - contact your doctor';
//   }
//
//   Future<void> _saveSideEffects() async {
//     if (_isSaving) return;
//
//     // Validate that at least one side effect is selected
//     if (_selectedSideEffects.isEmpty) {
//       return;
//     }
//
//     setState(() {
//       _isSaving = true;
//     });
//
//     // Convert selected side effects to SideEffect objects
//     final effects = _selectedSideEffects.map((effect) {
//       return SideEffect(
//         name: effect['name'],
//         severity: (effect['severity'] as double).round(),
//         description: effect['description'],
//       );
//     }).toList();
//
//     final request = SideEffectLogRequest(
//       date: _selectedDate,
//       effects: effects,
//       overallSeverity: _overallSeverity.round(),
//       relatedToShot: _relatedToShot,
//       notes: _notes.isNotEmpty ? _notes : null,
//     );
//
//     final provider = context.read<HealthProvider>();
//     final success = await provider.logSideEffects(request);
//
//     setState(() {
//       _isSaving = false;
//     });
//
//     if (success && mounted) {
//       Navigator.pop(context);
//     }
//   }
// }
//
