import 'package:flutter/material.dart';
import '../utils/theme.dart';

class TechPerformanceCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;

  const TechPerformanceCard({
    super.key,
    this.title = 'Performance',
    this.value = '85%',
    this.trend = '+15% vs semaine dernière',
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFF5722)], // Orange gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5722).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Curve
          Positioned.fill(
            child: CustomPaint(
              painter: _ChartPainter(),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Highlighting a point on the chart (Visual fake)
          Positioned(
            right: 60,
            bottom: 60, // Approximate position on the curve
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5722),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Start slightly off screen
    path.moveTo(0, size.height * 0.7);
    
    // Smooth bezier curve simulating data
    path.cubicTo(
      size.width * 0.2, size.height * 0.5, // Control point 1
      size.width * 0.4, size.height * 0.8, // Control point 2
      size.width * 0.5, size.height * 0.6, // End point 1 / Start 2
    );
    path.cubicTo(
      size.width * 0.6, size.height * 0.4, 
      size.width * 0.8, size.height * 0.5, 
      size.width, size.height * 0.3, 
    );

    canvas.drawPath(path, paint);

    // Gradient fill below curve (optional, distinct from reference but nice)
    // For exact reference match, line only is fine, but fill adds depth.
    // Let's keep line only as per 'orange card' reference which seems to have a line.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
