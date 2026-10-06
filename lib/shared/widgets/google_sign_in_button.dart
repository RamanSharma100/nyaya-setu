import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final double strokeWidth = s * 0.22;
    final double radius = (s - strokeWidth) / 2;
    final Offset center = Offset(s / 2, s / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, -0.4, 0.9, false, bluePaint);
    canvas.drawArc(rect, 0.5, 1.6, false, greenPaint);
    canvas.drawArc(rect, 2.1, 1.5, false, yellowPaint);
    canvas.drawArc(rect, 3.6, 2.3, false, redPaint);

    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final double barHeight = strokeWidth;
    final double barWidth = s * 0.44;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - 1,
        center.dy - barHeight / 2,
        barWidth + 1,
        barHeight,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final double height;
  final bool isDark;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continue with Google',
    this.height = 50.0,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDark ? const Color(0xFF131314) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFE3E3E3) : const Color(0xFF1F1F1F);
    final Color borderColor = isDark ? const Color(0xFF8E918F) : const Color(0xFFDADCE0);

    return Semantics(
      button: true,
      label: text,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(height / 2),
          elevation: isDark ? 0 : 0.5,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(height / 2),
            splashColor: textColor.withValues(alpha: 0.1),
            highlightColor: textColor.withValues(alpha: 0.05),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? const Color(0xFFE3E3E3) : const Color(0xFF4285F4),
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const GoogleLogo(size: 20),
                        const SizedBox(width: 12),
                        Text(
                          text,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
