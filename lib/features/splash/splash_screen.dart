import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/widgets/app_monogram_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _orbitController;
  late AnimationController _shimmerController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<double> _taglineFade;
  late Animation<double> _progressFade;

  Timer? _navTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0, 0.6),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));

    _titleFade = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0, 0.7),
    );

    _taglineFade = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.3, 1.0),
    );

    _progressFade = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.6, 1.0),
    );

    _logoController.forward().catchError((_) {});
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _contentController.forward().catchError((_) {});
    });

    _navTimer = Timer(const Duration(milliseconds: 1500), _navigateToNext);
  }

  void _navigateToNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _navTimer?.cancel();
    _navTimer = null;

    try {
      final isLoggedIn = AuthService.getUserProfile().isLoggedIn;
      if (isLoggedIn) {
        context.go('/dashboard');
      } else {
        context.go('/login');
      }
    } catch (_) {
      try {
        context.go('/login');
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _logoController.dispose();
    _contentController.dispose();
    _orbitController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _navigateToNext,
      child: Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: Stack(
        children: [
          // Animated background orbs
          ..._buildBackgroundOrbs(),

          // Grid pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Orbiting logo
                SizedBox(
                  width: 160,
                  height: 160,
                  child: AnimatedBuilder(
                    animation: _orbitController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Orbit ring 1
                          _buildOrbitRing(60, _orbitController.value * 2 * math.pi, AppColors.accentGold.withValues(alpha: 0.2), 6),
                          // Orbit ring 2
                          _buildOrbitRing(75, -_orbitController.value * 2 * math.pi * 0.7, AppColors.emeraldGreen.withValues(alpha: 0.15), 4),
                          // Center logo
                          ScaleTransition(
                            scale: _logoScale,
                            child: FadeTransition(
                              opacity: _logoFade,
                              child: child,
                            ),
                          ),
                        ],
                      );
                    },
                    child: _buildLogoCenter(),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, AppColors.accentGoldLight],
                      ).createShader(bounds),
                      child: Text(
                        AppStrings.appName,
                        style: AppTypography.fontHeading(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeTransition(
                  opacity: _taglineFade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.45)),
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.accentGold.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      AppStrings.appTagline,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Progress indicator
                FadeTransition(
                  opacity: _progressFade,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: null,
                                backgroundColor: Colors.white10,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.accentGold.withValues(alpha: 0.8),
                                ),
                                minHeight: 3,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Preparing your judicial workspace...',
                        style: GoogleFonts.inter(
                          color: Colors.white30,
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildLogoCenter() {
    return const AppMonogramLogo(
      size: 96,
      showGlow: true,
    );
  }

  Widget _buildOrbitRing(double radius, double angle, Color dotColor, double dotSize) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: dotColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          // Orbiting dot
          Transform.translate(
            offset: Offset(
              radius * math.cos(angle),
              radius * math.sin(angle),
            ),
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBackgroundOrbs() {
    return [
      Positioned(
        top: -60,
        left: -60,
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.accentGold.withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -80,
        right: -50,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.emeraldGreen.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
