import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/app_monogram_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryNavy,
              AppColors.secondaryNavy,
              Color(0xFF020C1B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const AppMonogramLogo(size: 96)
                .animate()
                .scale(duration: 800.ms, curve: Curves.easeOutBack)
                .fade(duration: 600.ms)
                .shimmer(delay: 1000.ms, duration: 1200.ms),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: GoogleFonts.outfit(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3,
              ),
            )
                .animate()
                .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOut)
                .fade(duration: 600.ms),
            const SizedBox(height: 12),
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(2),
              ),
            )
                .animate()
                .scaleX(begin: 0, end: 1, duration: 600.ms, delay: 200.ms),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                AppStrings.appTagline,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.accentGold,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                .animate()
                .slideY(begin: 0.4, end: 0, duration: 600.ms, delay: 400.ms)
                .fade(duration: 600.ms, delay: 400.ms),
            const Spacer(),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGold),
              ),
            ).animate().fade(delay: 600.ms),
            const SizedBox(height: 12),
            Text(
              'Loading Indian Judicial Preparation Data...',
              style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 12),
            ).animate().fade(delay: 700.ms),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'NyayaSetu is a private independent educational app. Not affiliated with any Government entity.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
