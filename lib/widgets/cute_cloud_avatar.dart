import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CuteCloudAvatar extends StatelessWidget {
  final double size;
  final Color? cloudColor;
  final Color? eyeColor;
  final Color? mouthColor;

  const CuteCloudAvatar({
    super.key,
    this.size = 100,
    this.cloudColor,
    this.eyeColor,
    this.mouthColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CuteCloudPainter(
          cloudColor: cloudColor ?? Colors.white,
          eyeColor: eyeColor ?? const Color(0xFF4A4A4A),
          mouthColor: mouthColor ?? const Color(0xFF4A4A4A),
        ),
      ),
    );
  }
}

class _CuteCloudPainter extends CustomPainter {
  final Color cloudColor;
  final Color eyeColor;
  final Color mouthColor;

  _CuteCloudPainter({
    required this.cloudColor,
    required this.eyeColor,
    required this.mouthColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 100;

    // Draw cloud body with multiple circles
    final cloudPaint = Paint()
      ..color = cloudColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Main cloud circles
    final circles = [
      Offset(center.dx - 25 * scale, center.dy + 5 * scale), // Left
      Offset(center.dx + 25 * scale, center.dy + 5 * scale), // Right
      Offset(center.dx, center.dy - 5 * scale), // Top center
      Offset(center.dx - 15 * scale, center.dy - 15 * scale), // Top left
      Offset(center.dx + 15 * scale, center.dy - 15 * scale), // Top right
      Offset(center.dx, center.dy + 15 * scale), // Bottom
    ];

    for (final circleCenter in circles) {
      canvas.drawCircle(circleCenter, 20 * scale, cloudPaint);
    }

    // Draw cute eyes
    final eyePaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill;

    // Left eye
    canvas.drawCircle(
      Offset(center.dx - 12 * scale, center.dy),
      4 * scale,
      eyePaint,
    );

    // Right eye
    canvas.drawCircle(
      Offset(center.dx + 12 * scale, center.dy),
      4 * scale,
      eyePaint,
    );

    // Draw eye highlights (cute sparkles)
    final highlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - 10 * scale, center.dy - 2 * scale),
      1.5 * scale,
      highlightPaint,
    );

    canvas.drawCircle(
      Offset(center.dx + 14 * scale, center.dy - 2 * scale),
      1.5 * scale,
      highlightPaint,
    );

    // Draw cute smile
    final mouthPaint = Paint()
      ..color = mouthColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    mouthPath.moveTo(center.dx - 8 * scale, center.dy + 12 * scale);
    mouthPath.quadraticBezierTo(
      center.dx,
      center.dy + 20 * scale,
      center.dx + 8 * scale,
      center.dy + 12 * scale,
    );
    canvas.drawPath(mouthPath, mouthPaint);

    // Draw cute blush cheeks
    final blushPaint = Paint()
      ..color = AppColors.sakura.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - 22 * scale, center.dy + 8 * scale),
      5 * scale,
      blushPaint,
    );

    canvas.drawCircle(
      Offset(center.dx + 22 * scale, center.dy + 8 * scale),
      5 * scale,
      blushPaint,
    );
  }

  @override
  bool shouldRepaint(_CuteCloudPainter oldDelegate) {
    return oldDelegate.cloudColor != cloudColor ||
        oldDelegate.eyeColor != eyeColor ||
        oldDelegate.mouthColor != mouthColor;
  }
}
