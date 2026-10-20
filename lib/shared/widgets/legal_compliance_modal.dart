import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class LegalComplianceModal {
  /// Opens the Government Disclaimer & Source Attribution Modal
  static void showGovernmentDisclaimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildModalHeader(
                title: 'Government Entity Disclaimer',
                subtitle: 'Google Play Store Compliance & Official Source Citations',
                icon: Icons.account_balance_rounded,
                iconColor: AppColors.primaryNavy,
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  children: [
                    // Prominent Alert Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NON-GOVERNMENT ENTITY NOTICE',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF991B1B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'NyayaSetu is an independent educational technology application developed solely for judicial exam aspirants, law students, and legal researchers. NyayaSetu does NOT represent, is NOT endorsed by, NOT authorized by, and NOT affiliated in any way with the Government of India, the Supreme Court of India, or any Government Department or Ministry.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: const Color(0xFF7F1D1D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Official Sources of Public Legal Information',
                      style: AppTypography.fontHeading(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All statutory bare act texts, criminal code reforms, and judicial judgments displayed in this app are sourced from public domain government databases. You can verify and inspect official enactments directly at:',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700, height: 1.45),
                    ),
                    const SizedBox(height: 12),

                    _buildSourceTile(
                      title: 'India Code (National Repository)',
                      url: 'https://www.indiacode.nic.in',
                      description: 'Official digital repository of Central and State Acts managed by the Legislative Department, Ministry of Law and Justice, Government of India.',
                    ),
                    _buildSourceTile(
                      title: 'Supreme Court of India Official Portal',
                      url: 'https://main.sci.gov.in',
                      description: 'Official website of the Supreme Court of India publishing certified judgments, causelists, and constitutional bench orders.',
                    ),
                    _buildSourceTile(
                      title: 'eCourts Digital Services India',
                      url: 'https://ecourts.gov.in',
                      description: 'National eCourts portal for district courts and state judicial services records under the Ministry of Law and Justice.',
                    ),
                    _buildSourceTile(
                      title: 'Law Commission of India',
                      url: 'https://lawcommissionofindia.nic.in',
                      description: 'Reports and consultative legal reform documents published by the Government of India.',
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Educational & Research Purpose',
                      style: AppTypography.fontHeading(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The materials provided in NyayaSetu—including visual flowcharts, mnemonics, toppers digests, mock exams, and video analyses—are curated strictly for competitive exam preparation (e.g., PCS-J, DJS, HJS, CLAT PG). This application does not provide official legal counsel, certified statutory gazettes, or attorney services. For legal court proceedings, users should consult certified publications from the Gazette of India.',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the Privacy Policy Modal
  static void showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildModalHeader(
                title: 'Privacy Policy',
                subtitle: 'Effective Date: October 2026 • NyayaSetu Platform',
                icon: Icons.shield_rounded,
                iconColor: const Color(0xFF059669),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  children: [
                    _buildPolicySection(
                      title: '1. Overview & Commitment',
                      content:
                          'NyayaSetu ("we", "us", or "our") respects your personal privacy. This Privacy Policy details what information we collect when you use the NyayaSetu mobile application and how your information is safeguarded in accordance with Google Play Developer Policies and applicable data protection regulations.',
                    ),
                    _buildPolicySection(
                      title: '2. Information We Collect',
                      content:
                          '• Authentication Data: When you sign in with Google, we receive basic profile info (Display Name, Email Address, and Avatar URL) from Google OAuth to create and manage your student profile.\n• Local Study Records: Your section notes, bookmarks, mock exam scores, and offline study materials are stored securely on your local device using encrypted Hive storage.\n• No Sensitive Permissions: NyayaSetu does NOT access your camera, microphone, device location, contacts, or storage files without explicit user interaction.',
                    ),
                    _buildPolicySection(
                      title: '3. How We Use Information',
                      content:
                          '• To display your exam target syllabus (e.g. Delhi Judicial Service, UP PCS-J).\n• To save and sync your personal legal annotations and topper notes.\n• To provide AI legal concept answers via Google Gemini API (ephemeral queries with zero ad targeting).\n• We NEVER sell, rent, or trade your personal information to third-party data brokers or marketing firms.',
                    ),
                    _buildPolicySection(
                      title: '4. Third-Party Integrations & Telemetry',
                      content:
                          'Our application integrates with reliable third-party service providers:\n• Google Sign-In: Governed by Google Privacy Policy (https://policies.google.com/privacy).\n• Product Telemetry (PostHog Compatible): Collects anonymous page views, button clicks, and feature usage to maintain app stability. Telemetry is never sold or used for ad targeting.\n• Login Alerts: Automated notifications triggered upon Google or Guest login to alert administrators of platform usage.\n• YouTube IFrame API: Used for embedding judicial exam lecture videos in compliance with YouTube API Terms.\n• OpenNyAI Legal Dataset: Public legal question data from HuggingFace.',
                    ),
                    _buildPolicySection(
                      title: '5. Data Deletion & User Rights',
                      content:
                          'In accordance with Google Play Store User Data Policies, you have the right to completely delete your account and all associated study data at any time. You can initiate instant account erasure directly inside the Profile screen ("Delete Account & Clear Data") or by sending an email request to techraman100@gmail.com.',
                    ),
                    _buildPolicySection(
                      title: '6. Children\'s Privacy',
                      content:
                          'NyayaSetu is designed for judicial examination aspirants, university law students, and adults. We do not knowingly collect personal identifiable information from children under the age of 13.',
                    ),
                    _buildPolicySection(
                      title: '7. Contact Us',
                      content:
                          'For any questions or data deletion inquiries regarding this Privacy Policy, please contact our Data Protection Officer at: techraman100@gmail.com.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the Terms of Service Modal
  static void showTermsOfService(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildModalHeader(
                title: 'Terms of Service',
                subtitle: 'Platform Usage & Fair Legal Education Guidelines',
                icon: Icons.gavel_rounded,
                iconColor: AppColors.accentGold,
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  children: [
                    _buildPolicySection(
                      title: '1. Acceptance of Terms',
                      content:
                          'By installing or using NyayaSetu, you agree to comply with and be bound by these Terms of Service. If you do not agree, please do not use the application.',
                    ),
                    _buildPolicySection(
                      title: '2. Educational Purpose & No Legal Advice',
                      content:
                          'NyayaSetu is an educational examination preparation tool. The content, including AI legal explanations, topper digests, and statute summaries, does NOT constitute formal legal advice, attorney-client privileged counsel, or official government gazette publications.',
                    ),
                    _buildPolicySection(
                      title: '3. Intellectual Property',
                      content:
                          'The statutory bare act texts and published court judgments are public domain documents. However, original topper revision notes, UI design, software architecture, exam mnemonics, and curated answer frameworks are the proprietary intellectual property of NyayaSetu.',
                    ),
                    _buildPolicySection(
                      title: '4. Limitation of Liability',
                      content:
                          'While we strive for 100% legal precision, statutory provisions and precedents evolve. NyayaSetu is provided on an "as is" and "as available" basis without warranty of any kind. Candidates should verify all legal provisions against official State Gazettes for judicial exam submissions.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Confirms and executes complete account and data erasure
  static Future<void> showDataDeletionDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.delete_forever_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Delete Account & Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account? This will:\n\n'
          '• Disconnect and erase your Google authentication profile.\n'
          '• Delete all your saved section study notes and annotations.\n'
          '• Clear all bookmarked bare acts and landmark ratios.\n'
          '• Reset your mock exam history.\n\n'
          'This action is irreversible and compliant with Google Play Data Deletion guidelines.',
          style: TextStyle(fontSize: 13.5, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Permanently Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(userProfileProvider.notifier).deleteAccount();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account and all personal data have been completely deleted.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  static Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  static Widget _buildModalHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPolicySection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSourceTile({
    required String title,
    required String url,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Visit Source',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_outward_rounded, size: 13, color: Color(0xFF2563EB)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(
            url,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600, height: 1.35),
          ),
        ],
      ),
    );
  }
}
