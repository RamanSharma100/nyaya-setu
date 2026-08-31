import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_monogram_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String _selectedGoal = 'DJS';

  final List<Map<String, String>> _features = [
    {
      'title': 'BNS 2023 & BNSS 2023 Live Converter',
      'desc': 'Instant side-by-side IPC/CrPC statutory diffs & key changes.',
      'icon': 'compare_arrows'
    },
    {
      'title': 'Spaced Repetition Prelims Flashcards',
      'desc': 'Tinder-style swipe deck for penalties, terms & section numbers.',
      'icon': 'style'
    },
    {
      'title': 'Mains Answer Studio & Rubrics',
      'desc': 'Distraction-free drafting pad with judicial IRAC evaluation rubrics.',
      'icon': 'edit_note'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryNavy, AppColors.secondaryNavy],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const AppMonogramLogo(size: 72)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 16),
                Text(
                  'Welcome to NyayaSetu',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ).animate().fade(duration: 600.ms),
                const SizedBox(height: 6),
                Container(
                  width: 40,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Indian Judicial Services (PCS-J) Preparation Platform',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppColors.textMutedDark, fontSize: 13),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    itemCount: _features.length,
                    itemBuilder: (context, index) {
                      final item = _features[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['title']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['desc']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Target Goal:',
                        style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGoal,
                          dropdownColor: AppColors.secondaryNavy,
                          style: GoogleFonts.outfit(color: AppColors.accentGold, fontWeight: FontWeight.bold),
                          items: const [
                            DropdownMenuItem(value: 'DJS', child: Text('Delhi (DJS)')),
                            DropdownMenuItem(value: 'UP PCS-J', child: Text('UP (UP PCS-J)')),
                            DropdownMenuItem(value: 'MP CJ', child: Text('MP (MP CJ)')),
                            DropdownMenuItem(value: 'RJS', child: Text('Rajasthan (RJS)')),
                            DropdownMenuItem(value: 'BJS', child: Text('Bihar (BJS)')),
                            DropdownMenuItem(value: 'HCS-J', child: Text('Haryana (HCS-J)')),
                            DropdownMenuItem(value: 'ALL-INDIA', child: Text('All-India Universal')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedGoal = val);
                              ref.read(userProfileProvider.notifier).updateTargetState(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            final router = GoRouter.of(context);
                            setState(() => _isLoading = true);
                            await ref.read(userProfileProvider.notifier).loginWithGoogle();
                            if (!mounted) return;
                            setState(() => _isLoading = false);
                            router.go('/dashboard');
                          },
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryNavy),
                          )
                        : const Icon(Icons.g_mobiledata, size: 28, color: AppColors.primaryNavy),
                    label: Text(
                      userProfile.isLoggedIn ? 'Signed In as ${userProfile.displayName}' : 'Continue with Google',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {
                    context.go('/dashboard');
                  },
                  child: Text(
                    'Explore App in Guest Mode ➔',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    'Disclaimer: NyayaSetu is an independent private educational preparation app. It is not affiliated with, authorized by, or associated with the Supreme Court of India, any High Court, or any Government Authority.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 10, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
