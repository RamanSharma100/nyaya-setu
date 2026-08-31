import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppMonogramLogo extends StatelessWidget {
  final double size;

  const AppMonogramLogo({super.key, this.size = 80.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.secondaryNavy, AppColors.primaryNavy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.accentGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.5, size * 0.5),
          painter: _MonogramPainter(),
        ),
      ),
    );
  }
}

class _MonogramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);

    final bridgePaint = Paint()
      ..color = AppColors.accentGoldLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final bridgePath = Path();
    bridgePath.moveTo(0, size.height * 0.7);
    bridgePath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.4,
      size.width,
      size.height * 0.7,
    );

    canvas.drawPath(bridgePath, bridgePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
