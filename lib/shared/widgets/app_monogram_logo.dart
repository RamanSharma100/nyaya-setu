import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A professional, rounded judicial logo emblem for NyayaSetu.
/// Features the Scales of Justice, Bridge of Law motif, and concentric golden rings.
class AppMonogramLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool showText;
  final VoidCallback? onTap;

  const AppMonogramLogo({
    super.key,
    this.size = 80.0,
    this.showGlow = true,
    this.showText = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.3),
          radius: 0.9,
          colors: [
            Color(0xFF1E3A5F),
            AppColors.primaryNavy,
            Color(0xFF070E18),
          ],
        ),
        border: Border.all(
          color: AppColors.accentGoldLight.withValues(alpha: 0.85),
          width: math.max(2.0, size * 0.025),
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.45),
                  blurRadius: size * 0.35,
                  spreadRadius: size * 0.04,
                ),
                BoxShadow(
                  color: const Color(0xFF1E3A5F).withValues(alpha: 0.5),
                  blurRadius: size * 0.2,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner decorative concentric rounded ring
          Container(
            width: size * 0.84,
            height: size * 0.84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
          ),

          // Central Judicial Emblem: Scales of Justice + Bridge Arch
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.balance_rounded,
                size: size * 0.44,
                color: AppColors.accentGold,
              ),
              if (size >= 60) ...[
                SizedBox(height: size * 0.02),
                // Stylized bridge curve with NS letters
                CustomPaint(
                  size: Size(size * 0.46, size * 0.12),
                  painter: _BridgeArchPainter(),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: logoWidget);
    }
    return logoWidget;
  }
}

/// Custom painter for the Setu (Bridge) arch beneath the scales of justice
class _BridgeArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.accentGoldDim, AppColors.accentGoldLight, AppColors.accentGoldDim],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Smooth rounded arch representing the Setu (bridge)
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.5,
      0,
      size.width,
      size.height,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
