import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/analytics/login_notification_service.dart';
import '../../core/config/env_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/hive_service.dart';

class AnalyticsTelemetryModal extends StatefulWidget {
  const AnalyticsTelemetryModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AnalyticsTelemetryModal(),
    );
  }

  @override
  State<AnalyticsTelemetryModal> createState() => _AnalyticsTelemetryModalState();
}

class _AnalyticsTelemetryModalState extends State<AnalyticsTelemetryModal> {
  late final TextEditingController _webhookController;
  late final TextEditingController _emailController;
  late final TextEditingController _posthogKeyController;
  late final TextEditingController _posthogHostController;

  bool _isTestingAlert = false;
  String? _testAlertResult;

  @override
  void initState() {
    super.initState();
    _webhookController = TextEditingController(text: EnvConfig.loginAlertWebhook);
    _emailController = TextEditingController(text: EnvConfig.loginAlertEmail);
    _posthogKeyController = TextEditingController(text: EnvConfig.posthogApiKey);
    _posthogHostController = TextEditingController(text: EnvConfig.posthogHost);
  }

  @override
  void dispose() {
    _webhookController.dispose();
    _emailController.dispose();
    _posthogKeyController.dispose();
    _posthogHostController.dispose();
    super.dispose();
  }

  Future<void> _saveConfigurations() async {
    await HiveService.saveCustomApiKey('LOGIN_ALERT_WEBHOOK', _webhookController.text.trim());
    await HiveService.saveCustomApiKey('LOGIN_ALERT_EMAIL', _emailController.text.trim());
    await HiveService.saveCustomApiKey('POSTHOG_API_KEY', _posthogKeyController.text.trim());
    await HiveService.saveCustomApiKey('POSTHOG_HOST', _posthogHostController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analytics & Email webhook settings updated successfully!'),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {});
    }
  }

  Future<void> _sendTestAlert() async {
    final endpoint = _webhookController.text.trim();
    if (endpoint.isEmpty) {
      setState(() {
        _testAlertResult = '⚠️ Please enter a Webhook URL or Formspree endpoint first.';
      });
      return;
    }

    setState(() {
      _isTestingAlert = true;
      _testAlertResult = null;
    });

    final success = await LoginNotificationService.sendTestAlert(targetEndpoint: endpoint);

    if (mounted) {
      setState(() {
        _isTestingAlert = false;
        _testAlertResult = success
            ? '✅ Test email alert sent successfully to webhook!'
            : '❌ Webhook dispatch failed. Please verify endpoint URL & network.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentEvents = AnalyticsService.getRecentEvents();
    final auditLogs = LoginNotificationService.getAuditLogs();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0B132B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.insights_rounded, color: Color(0xFF60A5FA), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Telemetry & User Analytics',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'PostHog Events • Google/Guest Logins • Email Alerts',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white60),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // Scrollable Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. KPI Cards Grid
                _buildMetricsGrid(),
                const SizedBox(height: 20),

                // 2. Login Email Alert Setup Section
                _buildEmailAlertSection(),
                const SizedBox(height: 20),

                // 3. PostHog Remote Setup Section
                _buildPostHogSection(),
                const SizedBox(height: 20),

                // 4. Login Notification Audit Log
                _buildAuditLogSection(auditLogs),
                const SizedBox(height: 20),

                // 5. Live Events Stream (PostHog & Local)
                _buildLiveEventStreamSection(recentEvents),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLATFORM METRICS OVERVIEW',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: AppColors.accentGold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Google Logins',
                count: '${AnalyticsService.googleLoginsCount}',
                subtitle: 'Verified Accounts',
                icon: Icons.verified_user_rounded,
                accentColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Guest Logins',
                count: '${AnalyticsService.guestLoginsCount}',
                subtitle: 'Anonymous Sessions',
                icon: Icons.person_outline_rounded,
                accentColor: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Screen Views',
                count: '${AnalyticsService.pageViewsCount}',
                subtitle: 'Total Pages Loaded',
                icon: Icons.visibility_rounded,
                accentColor: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Button Clicks',
                count: '${AnalyticsService.buttonClicksCount}',
                subtitle: 'User Tap Actions',
                icon: Icons.touch_app_rounded,
                accentColor: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
              ),
              Icon(icon, color: accentColor, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            count,
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailAlertSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mark_email_read_rounded, color: AppColors.accentGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Login Email Alert Dispatcher (Works in India)',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Triggers an immediate email every time a user signs in with Google or explores as guest. Works 100% in India without VPN or blocks.',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
          ),
          const SizedBox(height: 12),

          // Quick guide chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildOptionChip('Option 1: Direct Email (No signup)'),
                const SizedBox(width: 6),
                _buildOptionChip('Option 2: Web3Forms (Free Key)'),
                const SizedBox(width: 6),
                _buildOptionChip('Option 3: Google Apps Script'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Webhook Endpoint Field
          TextField(
            controller: _webhookController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Alert Destination (Email / Web3Forms / Script)',
              labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
              hintText: 'Enter your email (e.g. name@gmail.com) OR Web3Forms key',
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
              prefixIcon: const Icon(Icons.send_to_mobile_rounded, color: AppColors.accentGold, size: 18),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Zero-Block Indian Setup Options:',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Simply type your Gmail (e.g. you@gmail.com) ➔ Powered by FormSubmit Ajax directly to your inbox.\n• Or enter your free Web3Forms Access Key from web3forms.com (works 100% in India).\n• Or paste your Google Apps Script Web App URL.',
                  style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTestingAlert ? null : _sendTestAlert,
                  icon: _isTestingAlert
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 14),
                  label: const Text('Test Alert'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveConfigurations,
                  icon: const Icon(Icons.save_rounded, size: 14),
                  label: const Text('Save Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

          if (_testAlertResult != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _testAlertResult!,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.accentGold,
        ),
      ),
    );
  }

  Widget _buildPostHogSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bubble_chart_rounded, color: Color(0xFF38BDF8), size: 18),
              const SizedBox(width: 8),
              Text(
                'PostHog Remote Ingestion',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'All events (pageviews, button taps, logins) are buffered locally and optionally streamed to your PostHog cloud project.',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _posthogKeyController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'PostHog Project API Key (phc_...)',
              labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
              hintText: 'phc_xxxxxxxxxxxxxxxxx',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              prefixIcon: const Icon(Icons.key_rounded, color: Colors.white38, size: 18),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _posthogHostController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'PostHog Host',
              labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
              hintText: 'https://us.i.posthog.com or https://eu.i.posthog.com',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              prefixIcon: const Icon(Icons.cloud_queue_rounded, color: Colors.white38, size: 18),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogSection(List<Map<String, dynamic>> auditLogs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT LOGIN ALERTS OUTBOX',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.accentGold,
              ),
            ),
            Text(
              '${auditLogs.length} dispatched',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (auditLogs.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2541),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                'No login email alerts triggered yet.\nSign in or tap Explore as Guest to generate alerts.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
              ),
            ),
          )
        else
          ...auditLogs.take(5).map((log) {
            final isSuccess = log['status'] == 'delivered';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2541),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSuccess ? const Color(0xFF10B981).withValues(alpha: 0.3) : Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    color: isSuccess ? const Color(0xFF10B981) : Colors.orangeAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log['subject'] ?? 'Login Alert',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${log['timestamp']} • ${log['status']}',
                          style: GoogleFonts.inter(fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildLiveEventStreamSection(List<Map<String, dynamic>> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LIVE TELEMETRY EVENT STREAM',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.accentGold,
              ),
            ),
            Text(
              '${events.length} captured',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (events.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2541),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                'No user actions recorded yet. Navigate screens or tap buttons to populate stream.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
              ),
            ),
          )
        else
          ...events.take(12).map((evt) {
            final eventName = evt['event'] ?? 'unknown';
            final props = (evt['properties'] as Map<String, dynamic>?) ?? {};
            final detail = props['button_id'] ?? props['page_name'] ?? props['login_method'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2541),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: _getEventColor(eventName).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getEventIcon(eventName), color: _getEventColor(eventName), size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventName,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        if (detail.isNotEmpty)
                          Text(
                            detail,
                            style: GoogleFonts.inter(fontSize: 10, color: Colors.white54),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(evt['timestamp'] ?? ''),
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.white38),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Color _getEventColor(String eventName) {
    if (eventName == '\$pageview') return const Color(0xFF38BDF8);
    if (eventName == 'button_clicked') return const Color(0xFFA78BFA);
    if (eventName == 'user_logged_in') return const Color(0xFF34D399);
    return Colors.grey;
  }

  IconData _getEventIcon(String eventName) {
    if (eventName == '\$pageview') return Icons.remove_red_eye_rounded;
    if (eventName == 'button_clicked') return Icons.touch_app_rounded;
    if (eventName == 'user_logged_in') return Icons.login_rounded;
    return Icons.flash_on_rounded;
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
