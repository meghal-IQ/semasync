import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class TodaysActivityCard extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const TodaysActivityCard({
    super.key,
    required this.activities,
  });

  TextStyle _montserrat({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = Colors.black,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  Widget _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return Image.asset(
          'assets/images/water.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.water_drop,
              color: _getColorForType(type),
              size: 24,
            );
          },
        );
      case 'protein':
        return Image.asset(
          'assets/images/protein.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.fitness_center,
              color: _getColorForType(type),
              size: 24,
            );
          },
        );
      case 'fiber':
        return Image.asset(
          'assets/images/fiber.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.eco,
              color: _getColorForType(type),
              size: 24,
            );
          },
        );
      default:
        return Icon(
          Icons.info,
          color: _getColorForType(type),
          size: 24,
        );
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return const Color(0xFF3B82F6);
      case 'protein':
        return const Color(0xFFF59E0B);
      case 'fiber':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light gray background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Image.asset('assets/images/today.png'),
              const SizedBox(width: 8),
              Text(
                "Today's Activity",
                style: _montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          // Content
          if (activities.isEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    'No entries logged today',
                    style: _montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking your health',
                    style: _montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // const SizedBox(height: 16),
            ...activities.map((activity) {
              final type = activity['type'] as String? ?? '';
              final amount = activity['amount'];
              final unit = activity['unit'] as String? ?? '';
              final timestamp = activity['timestamp'] as DateTime?;
              
              return Container(
                decoration: BoxDecoration(
                  color: Color(0xffeaeaea),
                    borderRadius: BorderRadius.circular(12),
                  // color: Color(0xfff5f5f5)
                ),
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    // Icon
                    _getIconForType(type),
                    const SizedBox(width: 12),
                    
                    // Text
                    Expanded(
                      child: Text(
                        '$amount$unit ${type[0].toUpperCase()}${type.substring(1)}',
                        style: _montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    
                    // Timestamp
                    if (timestamp != null)
                      Text(
                        _getTimeAgo(timestamp),
                        style: _montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}

