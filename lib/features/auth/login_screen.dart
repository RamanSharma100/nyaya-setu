import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/widgets/app_monogram_logo.dart';
import '../../shared/widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String _selectedGoal = 'DJS';

  late AnimationController _entryController;
  late AnimationController _floatController;
  late Animation<double> _cardSlide;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _headerFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _cardSlide = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);

    final success = await ref.read(userProfileProvider.notifier).loginWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      router.go('/dashboard');
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text('Sign-in was cancelled or not completed.'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.secondaryNavy,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: Stack(
        children: [
          // Background decorative elements
          _buildBackground(size),

          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header section
                  FadeTransition(
                    opacity: _headerFade,
                    child: Column(
                      children: [
                        // Animated logo
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -4 * math.sin(_floatController.value * math.pi)),
                              child: child,
                            );
                          },
                          child: const AppMonogramLogo(
                            size: 82,
                            showGlow: true,
                          ),
                        ),

                        const SizedBox(height: 16),

                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, AppColors.accentGoldLight],
                          ).createShader(bounds),
                          child: Text(
                            'NyayaSetu',
                            style: AppTypography.fontHeading(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),
                        Text(
                          'Indian Judicial Service (PCS-J) Preparation',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),

                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFeaturePill(Icons.quiz_outlined, 'Mock Tests'),
                            _buildFeaturePill(Icons.play_circle_outline, 'Video Lectures'),
                            _buildFeaturePill(Icons.menu_book_outlined, 'Bare Acts'),
                            _buildFeaturePill(Icons.gavel_outlined, 'Case Laws'),
                            _buildFeaturePill(Icons.search, 'Concept Search'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_cardSlide),
                    child: FadeTransition(
                      opacity: _cardSlide,
                      child: _buildLoginCard(userProfile),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FadeTransition(
                    opacity: _cardSlide,
                    child: Text(
                      'Independent Educational Platform • Not affiliated with any Government or Judicial Body',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white24,
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentGold.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -40,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.emeraldGreen.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accentGold, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(dynamic userProfile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryNavy,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get Started',
            style: AppTypography.fontHeading(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your target exam to personalize your study plan',
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'TARGET EXAM',
            style: GoogleFonts.inter(
              color: AppColors.accentGold,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGoal,
                dropdownColor: AppColors.tertiaryNavy,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.accentGold),
                style: AppTypography.fontHeading(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                items: const [
                  DropdownMenuItem(value: 'DJS', child: Text('🏛️  Delhi Judicial Service (DJS)')),
                  DropdownMenuItem(value: 'UP PCS-J', child: Text('⚖️  UP PCS-J')),
                  DropdownMenuItem(value: 'MP CJ', child: Text('📜  MP Civil Judge')),
                  DropdownMenuItem(value: 'RJS', child: Text('🔱  Rajasthan Judicial Service (RJS)')),
                  DropdownMenuItem(value: 'BJS', child: Text('🏅  Bihar Judicial Service (BJS)')),
                  DropdownMenuItem(value: 'HCS-J', child: Text('⚡  Haryana Judicial Service (HCS-J)')),
                  DropdownMenuItem(value: 'ALL-INDIA', child: Text('🇮🇳  All-India Universal Prep')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedGoal = val);
                    ref.read(userProfileProvider.notifier).updateTargetState(val);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (userProfile.isLoggedIn) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userProfile.displayName.isNotEmpty
                            ? userProfile.displayName[0].toUpperCase()
                            : 'U',
                        style: AppTypography.fontHeading(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile.displayName,
                          style: AppTypography.fontHeading(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (userProfile.email.isNotEmpty)
                          Text(
                            userProfile.email,
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(userProfileProvider.notifier).logout(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Switch',
                      style: GoogleFonts.inter(
                        color: AppColors.accentGold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          GoogleSignInButton(
            onPressed: _handleGoogleSignIn,
            isLoading: _isLoading,
            height: 52,
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => context.go('/dashboard'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.25), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Text(
                'Explore as Guest  →',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _buildStatItem('5+', 'Acts & Codes'),
              _buildStatDivider(),
              _buildStatItem('50+', 'Case Laws'),
              _buildStatDivider(),
              _buildStatItem('100+', 'Mock MCQs'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.fontHeading(
              color: AppColors.accentGold,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white12,
    );
  }
}
