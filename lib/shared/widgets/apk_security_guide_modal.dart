import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/storage/hive_service.dart';

class ApkSecurityGuideModal extends StatefulWidget {
  const ApkSecurityGuideModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ApkSecurityGuideModal(),
    );
  }

  @override
  State<ApkSecurityGuideModal> createState() => _ApkSecurityGuideModalState();
}

class _ApkSecurityGuideModalState extends State<ApkSecurityGuideModal> {
  final _geminiKeyController = TextEditingController();
  final _kanoonKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _geminiKeyController.text = HiveService.getCustomApiKey('GEMINI_API_KEY');
    _kanoonKeyController.text = HiveService.getCustomApiKey('INDIAN_KANOON_API_KEY');
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _kanoonKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.crimsonRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.security_rounded, color: Colors.redAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'APK Security & .env Protection',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Anti-reverse engineering and zero-leak release architecture',
                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Shield Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppColors.emeraldGreen, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good News: .env is NOT bundled in your APK!',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF34D399),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your pubspec.yaml does NOT list ".env" under flutter assets. Anyone extracting your APK with apktool will NOT find any plaintext .env file.',
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3-Layer Protection System
                  Text(
                    'The 3 Pillars of APK Reverse-Engineering Defense:',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  _buildPillarTile(
                    number: '1',
                    title: 'Compile-Time Binary Injection (--dart-define-from-file)',
                    desc: 'Never package .env as an asset. Instead, compile with:\nflutter build apk --dart-define-from-file=.env\nThis bakes the keys into compiled ARM machine code in libapp.so, completely eliminating plaintext .env files.',
                  ),
                  const SizedBox(height: 10),

                  _buildPillarTile(
                    number: '2',
                    title: 'Native Code Obfuscation & Symbol Stripping',
                    desc: 'When building your release APK, run:\nflutter build apk --release --obfuscate --split-debug-info=symbols/\nThis renames classes, methods, and functions to random tokens (a, b, c) and strips debugging strings so decompilers cannot read your logic.',
                  ),
                  const SizedBox(height: 10),

                  _buildPillarTile(
                    number: '3',
                    title: 'Google Cloud Console Key Restriction (Most Important!)',
                    desc: 'In Google Cloud Console -> APIs & Services -> Credentials -> Your Gemini Key:\n• Under "Application restrictions", select "Android apps".\n• Add your package name (e.g. com.example.nyayasetu) and your SHA-1 certificate fingerprint.\n• Under "API restrictions", select ONLY "Generative Language API".\nEven if someone extracts the key string, Google blocks requests from any other app or server!',
                  ),

                  const SizedBox(height: 22),

                  // Optional Dynamic In-App Key Storage
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.key_rounded, color: AppColors.accentGold, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Custom In-App API Key Overrides:',
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You can ship a 100% key-free APK, and enter or update your keys here. Keys are saved securely in local device storage only.',
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 11, height: 1.35),
                        ),
                        const SizedBox(height: 14),

                        TextField(
                          controller: _geminiKeyController,
                          obscureText: true,
                          style: GoogleFonts.firaCode(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Custom Gemini AI API Key (Optional)',
                            labelStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                            hintText: 'AIzaSy...',
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextField(
                          controller: _kanoonKeyController,
                          obscureText: true,
                          style: GoogleFonts.firaCode(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Custom Indian Kanoon API Key (Optional)',
                            labelStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                            hintText: 'Enter API token...',
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save_rounded, size: 16),
                            label: const Text('Save Local Keys', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGold,
                              foregroundColor: AppColors.primaryNavy,
                            ),
                            onPressed: () async {
                              await HiveService.saveCustomApiKey('GEMINI_API_KEY', _geminiKeyController.text);
                              await HiveService.saveCustomApiKey('INDIAN_KANOON_API_KEY', _kanoonKeyController.text);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Secure local API keys updated!')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarTile({required String number, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.accentGold.withValues(alpha: 0.2),
            child: Text(
              number,
              style: GoogleFonts.inter(color: AppColors.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
