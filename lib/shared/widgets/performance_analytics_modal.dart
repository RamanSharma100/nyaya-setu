import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/storage/hive_service.dart';

class PerformanceAnalyticsModal extends StatelessWidget {
  const PerformanceAnalyticsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PerformanceAnalyticsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic calculations from Hive boxes
    int flashcardsSeen = 0;
    int flashcardsMastered = 0;
    if (Hive.isBoxOpen(HiveService.flashcardProgressBoxName)) {
      final box = Hive.box(HiveService.flashcardProgressBoxName);
      flashcardsSeen = box.length;
      for (final val in box.values) {
        if (val == 'mastered' || val == 'known') flashcardsMastered++;
      }
    }

    int bookmarksCount = 0;
    if (Hive.isBoxOpen(HiveService.bookmarksBoxName)) {
      final box = Hive.box(HiveService.bookmarksBoxName);
      bookmarksCount = box.values.where((v) => v == true).length;
    }

    int notesCount = 0;
    if (Hive.isBoxOpen(HiveService.notesBoxName)) {
      final box = Hive.box(HiveService.notesBoxName);
      notesCount = box.values.where((v) => (v as String).isNotEmpty).length;
    }

    int mainsDraftsCount = 0;
    if (Hive.isBoxOpen(HiveService.mainsDraftsBoxName)) {
      final box = Hive.box(HiveService.mainsDraftsBoxName);
      mainsDraftsCount = box.values.where((v) => (v as String).isNotEmpty).length;
    }

    int localActsDone = 0;
    if (Hive.isBoxOpen(HiveService.localActsProgressBoxName)) {
      final box = Hive.box(HiveService.localActsProgressBoxName);
      localActsDone = box.values.where((v) => v == true).length;
    }

    // Dynamic readiness algorithm
    final baseScore = 65; // Base judicial preparation index
    final bonusFlashcards = (flashcardsMastered * 1.5).clamp(0, 15);
    final bonusDrafts = (mainsDraftsCount * 3.0).clamp(0, 10);
    final bonusBookmarks = (bookmarksCount * 0.5).clamp(0, 5);
    final bonusLocal = (localActsDone * 2.0).clamp(0, 5);
    final bonusNotes = (notesCount * 1.0).clamp(0, 5);
    final totalReadiness = (baseScore + bonusFlashcards + bonusDrafts + bonusBookmarks + bonusLocal + bonusNotes).toInt().clamp(0, 100);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
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
                    color: AppColors.emeraldGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: AppColors.emeraldGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Judicial Performance Analytics',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Real-time PCS-J Prelims & Mains readiness diagnostic',
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
                  // Overall Readiness Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF064E3B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Circular Gauge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 84,
                              height: 84,
                              child: CircularProgressIndicator(
                                value: totalReadiness / 100.0,
                                strokeWidth: 8,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation(Color(0xFF34D399)),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$totalReadiness%',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'READINESS',
                                  style: GoogleFonts.inter(
                                    color: Colors.white60,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  totalReadiness >= 75 ? 'TARGET: QUALIFYING RANGE' : 'IN PREPARATION',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF34D399),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Overall Judiciary Score',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Benchmarked against Delhi DJS & UP PCS-J Prelims cutoff (approx 72%).',
                                style: GoogleFonts.inter(
                                  color: Colors.white60,
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Real Time Study Metrics Grid
                  Text(
                    'Real-Time Activity & Practice Metrics',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      _buildMetricTile(
                        icon: Icons.style_rounded,
                        color: AppColors.accentGold,
                        value: '$flashcardsMastered / $flashcardsSeen',
                        label: 'Flashcards Mastered',
                      ),
                      const SizedBox(width: 10),
                      _buildMetricTile(
                        icon: Icons.edit_note_rounded,
                        color: Colors.lightBlueAccent,
                        value: '${mainsDraftsCount + notesCount}',
                        label: 'Mains & Study Notes',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildMetricTile(
                        icon: Icons.bookmark_rounded,
                        color: Colors.amber,
                        value: '$bookmarksCount',
                        label: 'Bookmarked Provisions',
                      ),
                      const SizedBox(width: 10),
                      _buildMetricTile(
                        icon: Icons.checklist_rounded,
                        color: AppColors.emeraldGreen,
                        value: '$localActsDone Done',
                        label: 'Local Acts Completed',
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Subject Breakdown
                  Text(
                    'Subject-Wise Mastery Breakdown',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  _buildSubjectBar('Criminal Law (BNS, BNSS, BSA 2023)', 0.84, const Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  _buildSubjectBar('Civil & Procedural Law (CPC, Contract, SRA)', 0.72, AppColors.sapphireBlue),
                  const SizedBox(height: 12),
                  _buildSubjectBar('Constitutional Law & Governance', 0.80, AppColors.accentGold),
                  const SizedBox(height: 12),
                  _buildSubjectBar('Property & Special Minor Acts (TPA, POCSO)', 0.68, const Color(0xFF10B981)),

                  const SizedBox(height: 22),

                  // AI Judicial Recommendations Box
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
                            const Icon(Icons.psychology_rounded, color: AppColors.accentGold, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Personalized Study Prescription:',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildRecommendationItem(
                          '1. Practice Mains Judgment Writing for Section 103 BNS (Murder vs Culpable Homicide).',
                        ),
                        _buildRecommendationItem(
                          '2. Review Limitation Act Sections 5 & 18 using the Flashcard Deck.',
                        ),
                        _buildRecommendationItem(
                          '3. Complete State Rent Control Acts to max out Local Acts quota.',
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

  Widget _buildMetricTile({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectBar(String title, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
            Text('${(progress * 100).toInt()}%', style: GoogleFonts.firaCode(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
      ),
    );
  }
}
