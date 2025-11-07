import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class WaterCard extends StatefulWidget {
  final double water;
  final double waterGoal;
  final Function()? onIncrement;
  final Function()? onDecrement;

  const WaterCard({
    super.key,
    this.water = 0,
    this.waterGoal = 3493,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  State<WaterCard> createState() => _WaterCardState();
}

class _WaterCardState extends State<WaterCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fillAnimation;
  double _previousWater = 0;

  @override
  void initState() {
    super.initState();
    _previousWater = widget.water;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fillAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    // Set initial value to show current fill level
    _animationController.value = 1.0;
  }

  @override
  void didUpdateWidget(WaterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.water > oldWidget.water) {
      // Water increased, trigger animation from previous level
      _previousWater = oldWidget.water;
      _animationController.forward(from: 0.0);
    } else {
      _previousWater = widget.water;
      // Reset animation to show current level
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleIncrement() {
    if (widget.onIncrement != null) {
      _animationController.forward(from: 0.0);
      widget.onIncrement!();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    // Calculate responsive padding: 2% of screen width, min 12px, max 20px
    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePadding = (screenWidth * 0.02).clamp(12.0, 20.0);
    
    return Container(
      padding: EdgeInsets.all(responsivePadding),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon
          Row(
            children: [
              const Icon(
                Icons.water_drop,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Water',
                style: _montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Current/Goal text - larger and bold
          Text(
            '${widget.water.toInt()}ml / ${widget.waterGoal.toInt()}ml',
            style: _montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 12),

          // Water drop with partial fill animation
          Center(
            child: AnimatedBuilder(
              animation: _fillAnimation,
              builder: (context, child) {
                // Calculate previous and current fill percentages
                final previousFill = _previousWater / widget.waterGoal;
                final currentFill = widget.water / widget.waterGoal;
                // Interpolate between previous and current fill during animation
                final animatedFill = previousFill + (currentFill - previousFill) * _fillAnimation.value;
                return _WaterDropWithFill(
                  fillPercentage: animatedFill.clamp(0.0, 1.0),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Increment/Decrement controls
          Row(
            children: [
              GestureDetector(
                onTap: widget.onDecrement,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '237ml',
                      style: _montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _handleIncrement,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterDropWithFill extends StatelessWidget {
  final double fillPercentage;

  const _WaterDropWithFill({
    required this.fillPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 41,
      height: 41,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base water drop image
          Image.asset(
            'assets/images/water_drop.png',

            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon if image not found
              return const Icon(
                Icons.water_drop,
                color: Color(0xFF9CA3AF),
                size: 33,
              );
            },
          ),
          // Partial fill overlay
          // ClipPath(
          //   clipper: _WaterDropClipper(),
          //   child: CustomPaint(
          //     size: const Size(41, 41),
          //     painter: _WaterFillPainter(
          //       fillPercentage: fillPercentage,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _WaterDropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Water drop shape: teardrop with pointed top and rounded bottom
    final centerX = size.width / 2;
    final topY = size.height * 0.1;
    final bottomY = size.height * 0.9;
    
    // Start at the top point
    path.moveTo(centerX, topY);
    
    // Right curve to bottom
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.4,
      centerX, bottomY,
    );
    
    // Left curve back to top
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.4,
      centerX, topY,
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _WaterFillPainter extends CustomPainter {
  final double fillPercentage;

  _WaterFillPainter({
    required this.fillPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fillPercentage <= 0) return;

    // Create fill path matching the teardrop shape
    final fillPath = Path();
    final centerX = size.width / 2;
    final topY = size.height * 0.1;
    final bottomY = size.height * 0.9;
    
    // Calculate fill level from bottom (0 = bottom, 1 = top)
    // fillPercentage is 0.0 to 1.0, where 0 = empty, 1 = full
    final fillRange = bottomY - topY;
    final fillHeight = bottomY - (fillRange * fillPercentage.clamp(0.0, 1.0));
    
    // Start from bottom center
    fillPath.moveTo(centerX, bottomY);
    
    if (fillPercentage >= 1.0) {
      // Full fill - use complete teardrop shape
      fillPath.quadraticBezierTo(
        size.width * 0.7, size.height * 0.4,
        centerX, topY,
      );
      fillPath.quadraticBezierTo(
        size.width * 0.3, size.height * 0.4,
        centerX, bottomY,
      );
    } else {
      // Partial fill - create a curve that matches the teardrop shape
      // Calculate the Y position where the fill ends
      final fillY = fillHeight;
      
      // Calculate width at the fill level using the teardrop curve
      // The teardrop is wider at bottom, narrower at top
      // Use inverse mapping: bottomY (t=1) is widest, topY (t=0) is narrowest
      final fillRatio = (fillY - bottomY) / (topY - bottomY); // 0 at bottom, 1 at top
      
      // Calculate width at fill level using bezier curve approximation
      // The teardrop width follows a quadratic curve
      final maxWidth = size.width * 0.4; // Maximum width at bottom
      final minWidth = size.width * 0.1; // Minimum width at top
      
      // Inverse the ratio since we're filling from bottom
      final t = 1.0 - fillRatio; // t = 1 at bottom (max width), t = 0 at top (min width)
      final widthAtLevel = minWidth + (maxWidth - minWidth) * t;
      final halfWidth = widthAtLevel / 2;
      
      // Create fill path: bottom center -> right edge -> curved top -> left edge -> bottom center
      fillPath.lineTo(centerX + halfWidth, fillY);
      
      // Create a smooth curve for the top of the fill (meniscus effect)
      final curveControlY = fillY - (bottomY - fillY) * 0.2;
      fillPath.quadraticBezierTo(
        centerX, curveControlY,
        centerX - halfWidth, fillY,
      );
      
      fillPath.lineTo(centerX, bottomY);
    }
    
    fillPath.close();

    // Create gradient for water effect (darker at bottom, lighter at top)
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(centerX, fillHeight),
        Offset(centerX, bottomY),
        [
          const Color(0xFF3B82F6).withOpacity(0.7),
          const Color(0xFF3B82F6).withOpacity(0.9),
        ],
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterFillPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage;
  }
}

