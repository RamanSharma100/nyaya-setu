import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/auth/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/analytics_telemetry_modal.dart';
import '../../shared/widgets/app_monogram_logo.dart';
import '../../shared/widgets/legal_compliance_modal.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // User Information Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryNavy, AppColors.secondaryNavy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userProfile.isLoggedIn && userProfile.displayName.isNotEmpty
                          ? userProfile.displayName[0].toUpperCase()
                          : 'A',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile.isLoggedIn
                            ? userProfile.displayName
                            : 'Guest Legal Aspirant',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userProfile.isLoggedIn && userProfile.email.isNotEmpty
                            ? userProfile.email
                            : 'Sign in to sync your notes & mock test scores',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'Target: ${userProfile.targetState} Judicial Services',
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Sign In or Sign Out Action
          if (!userProfile.isLoggedIn)
            ElevatedButton.icon(
              onPressed: () => context.push('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Sign In with Google Account', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(userProfileProvider.notifier).logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully.')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
                side: BorderSide(color: AppColors.primaryNavy.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign Out'),
            ),
          const SizedBox(height: 24),

          // Section 1: Legal Compliance & Google Play Mandates
          _buildSectionHeader('Legal & Official Disclaimers'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_rounded, color: Color(0xFFDC2626)),
                  title: const Text('Government Entity Disclaimer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Non-affiliation statement & official India Code sources', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () => LegalComplianceModal.showGovernmentDisclaimer(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shield_rounded, color: Color(0xFF059669)),
                  title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Data protection, Google OAuth, and storage disclosures', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () => LegalComplianceModal.showPrivacyPolicy(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_rounded, color: AppColors.accentGold),
                  title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Educational use guidelines and fair use policies', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () => LegalComplianceModal.showTermsOfService(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Account & Data Safety (Mandatory for Google Play)
          _buildSectionHeader('Data Safety & Account Management'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text('Delete Account & Personal Data', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)),
                  subtitle: const Text('Permanently erase account, local notes & bookmarks', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () => LegalComplianceModal.showDataDeletionDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.primaryNavy),
                  title: const Text('Clear Offline Cache', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Refresh downloaded bare acts and temporary files', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offline memory cache cleared.')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 3: Telemetry, PostHog & Login Alerts
          _buildSectionHeader('Analytics, PostHog & Email Alerts'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.insights_rounded, color: Color(0xFF2563EB)),
                  title: const Text('App Analytics & Event Telemetry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('PostHog stream, Google/Guest login counts & click stats', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () {
                    AnalyticsService.trackButtonClick('analytics_telemetry_tile', screen: 'profile');
                    AnalyticsTelemetryModal.show(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.mark_email_read_rounded, color: Color(0xFFD97706)),
                  title: const Text('Login Email Alerts Config', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Configure webhook & test immediate login alert emails', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () {
                    AnalyticsService.trackButtonClick('login_email_alerts_tile', screen: 'profile');
                    AnalyticsTelemetryModal.show(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 4: App Information
          _buildSectionHeader('Application Information'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const AppMonogramLogo(size: 28, showGlow: false),
                  title: const Text('NyayaSetu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Version 1.0.0 (Release Build 1) • Production Ready', style: TextStyle(fontSize: 12)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Colors.blueGrey),
                  title: const Text('Open Source Software Licenses', style: TextStyle(fontSize: 14)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'NyayaSetu',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 NyayaSetu Legal Tech. All rights reserved. Sourced from public legal repositories.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Footer Notice
          Center(
            child: Text(
              'Independent Judicial Examination Prep Platform\nNot affiliated with the Government of India',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
