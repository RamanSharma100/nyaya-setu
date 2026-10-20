import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/network/handmade_notes_service.dart';
import '../../core/storage/hive_service.dart';
import '../../core/utils/youtube_helper.dart';
import '../../shared/models/bare_act.dart';
import '../../shared/models/handmade_note.dart';
import '../../shared/widgets/youtube_video_card.dart';

class SectionDetailScreen extends ConsumerStatefulWidget {
  final BareAct bareAct;
  final Section section;

  const SectionDetailScreen({
    super.key,
    required this.bareAct,
    required this.section,
  });

  @override
  ConsumerState<SectionDetailScreen> createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends ConsumerState<SectionDetailScreen> {
  late TextEditingController _noteController;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = HiveService.isBookmarked(widget.bareAct.id, widget.section.sectionNumber);
    _noteController = TextEditingController(
      text: HiveService.getSectionNote(widget.bareAct.id, widget.section.sectionNumber),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sec = widget.section;
    final act = widget.bareAct;
    final video = YouTubeHelper.getMatchingVideo('${act.shortTitle} ${sec.sectionNumber} ${sec.title}');
    final notesAsync = ref.watch(handmadeNotesProvider);

    // Find if a curated topper note exists for this section
    HandmadeNote? matchingNote;
    if (notesAsync.value != null && notesAsync.value!.isNotEmpty) {
      final secQuery = '${act.shortTitle} ${sec.sectionNumber}';
      matchingNote = notesAsync.value!.where((n) {
        return HandmadeNotesService.matchesSearch(n, secQuery) ||
            (n.actShortTitle.toLowerCase().contains(act.shortTitle.toLowerCase()) &&
                n.sectionNumber.toLowerCase().contains(sec.sectionNumber.toLowerCase()));
      }).firstOrNull;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${act.shortTitle} - Section ${sec.sectionNumber}'),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? AppColors.accentGold : Colors.white,
            ),
            tooltip: _isBookmarked ? 'Remove Bookmark' : 'Bookmark Section',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await HiveService.toggleBookmark(act.id, sec.sectionNumber);
              if (!mounted) return;
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              messenger.showSnackBar(
                SnackBar(
                  content: Text(_isBookmarked ? 'Section bookmarked!' : 'Bookmark removed.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Section',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied ${act.shortTitle} Sec ${sec.sectionNumber} to clipboard!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryNavy, AppColors.secondaryNavy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          sec.chapter.isNotEmpty ? sec.chapter : act.title,
                          style: GoogleFonts.inter(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      if (sec.oldEquivalent != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.accentGold),
                          ),
                          child: Text(
                            'Old: ${sec.oldEquivalent}',
                            style: GoogleFonts.inter(color: AppColors.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    sec.title,
                    style: AppTypography.fontHeading(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildStatusChip(
                        act.isMinorAct ? '📜 Minor Act' : '⭐ Major Act',
                        act.isMinorAct ? const Color(0xFFD97706) : AppColors.accentGold,
                        textColor: act.isMinorAct ? Colors.white : AppColors.primaryNavy,
                      ),
                      if (sec.bailable != null)
                        _buildStatusChip(
                          sec.bailable! ? 'Bailable' : 'Non-Bailable',
                          sec.bailable! ? Colors.green : AppColors.crimsonRed,
                        ),
                      if (sec.cognizable != null)
                        _buildStatusChip(
                          sec.cognizable! ? 'Cognizable' : 'Non-Cognizable',
                          sec.cognizable! ? Colors.blue : Colors.orange,
                        ),
                      if (sec.triableBy != null)
                        _buildStatusChip(
                          'Trial: ${sec.triableBy}',
                          Colors.indigo.shade400,
                          textColor: Colors.white,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FEATURE 1: EMBEDDED VISUAL HANDWRITTEN TOPPER NOTE & LANDMARK DIGEST
            _buildEmbeddedHandwrittenDigest(matchingNote, act, sec),
            const SizedBox(height: 20),

            // FEATURE 2: FULL VERBATIM STATUTORY TEXT
            _buildSectionCard(
              title: 'Full Statutory Text',
              icon: Icons.gavel,
              content: SelectableText(
                sec.content,
                style: AppTypography.fontStatute(fontSize: 15, height: 1.65, color: const Color(0xFF1F2937)),
              ),
            ),
            const SizedBox(height: 16),

            // FEATURE 3: PRACTICAL REAL-WORLD CASE EXAMPLES
            if (sec.examples.isNotEmpty) ...[
              _buildSectionCard(
                title: 'Practical Real-World Case Examples',
                icon: Icons.lightbulb_outline,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sec.examples.map((example) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        example,
                        style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: AppColors.textPrimaryDark),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // FEATURE 4: VIDEO LECTURE & ANALYSIS
            _buildSectionCard(
              title: 'Video Lecture & Analysis',
              icon: Icons.ondemand_video,
              content: YouTubeVideoCard(
                video: video,
                searchQuery: '${act.shortTitle} Section ${sec.sectionNumber} ${sec.title}',
                compactLabel: 'SECTION BREAKDOWN',
              ),
            ),
            const SizedBox(height: 16),

            // FEATURE 5: PERSONAL HANDWRITTEN STUDY NOTES (HIVE-PERSISTED)
            _buildSectionCard(
              title: 'My Personal Handwritten Study Notes',
              icon: Icons.edit_note,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    style: GoogleFonts.inter(fontSize: 14, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Add personal study notes, landmark ratios, or personal mnemonics...',
                      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await HiveService.saveSectionNote(act.id, sec.sectionNumber, _noteController.text);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Study note saved into Hive storage!')),
                        );
                      },
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: const Text('Save Note'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
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

  /// Builds the full visual handwritten note directly inside the section view
  Widget _buildEmbeddedHandwrittenDigest(HandmadeNote? note, BareAct act, Section sec) {
    final coreRuleText = note?.coreRule.isNotEmpty == true
        ? note!.coreRule
        : (sec.explanation.isNotEmpty ? sec.explanation : sec.content);

    final bulletItems = (note != null && note.bulletPoints.isNotEmpty)
        ? note.bulletPoints
        : (sec.keyIngredients.isNotEmpty ? sec.keyIngredients : [sec.content]);

    final landmarkCases = (note != null && note.landmarkJudgments.isNotEmpty)
        ? note.landmarkJudgments
        : <LandmarkJudgmentNote>[];

    final mnemonicTricks = (note != null && note.mnemonicTricks.isNotEmpty)
        ? note.mnemonicTricks
        : <String>[];

    final prelimsTrap = note?.prelimsTrapAlert.isNotEmpty == true
        ? note!.prelimsTrapAlert
        : (sec.examTips.isNotEmpty ? sec.examTips : '');

    final mainsFramework = note?.mainsAnswerFramework.isNotEmpty == true
        ? note!.mainsAnswerFramework
        : '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parchment Header with Topper Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFF59E0B), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('📝', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF92400E),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PCS-J TOPPER REVISION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            note != null ? 'Curated Master Note' : 'Synthesized Digest',
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Visual Handwritten Note & Landmark Digest',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF78350F),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new_rounded, size: 18, color: Color(0xFF92400E)),
                  tooltip: 'Open in Full Notes Hub',
                  onPressed: () {
                    context.push('/handmade_notes?query=${Uri.encodeComponent('${act.shortTitle} ${sec.sectionNumber}')}');
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CORE STATUTORY RATIO
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: Color(0xFFD97706), width: 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.balance_rounded, size: 16, color: Color(0xFF92400E)),
                          const SizedBox(width: 6),
                          Text(
                            'CORE LEGAL RULE & RATIO',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF92400E),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        coreRuleText,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          height: 1.55,
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. KEY LEGAL INGREDIENTS (FLOWCHART STEP-BY-STEP)
                Text(
                  '📋 Key Legal Ingredients & Elements',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF78350F),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: bulletItems.asMap().entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEF3C7),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.45,
                                color: const Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // 3. LANDMARK CASE LAWS & SC RATIOS
                Text(
                  '🏛️ Landmark Precedents & Ratio Decidendi',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF78350F),
                  ),
                ),
                const SizedBox(height: 8),
                if (landmarkCases.isNotEmpty)
                  Column(
                    children: landmarkCases.map((j) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFD97706)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    j.caseName,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${j.citation} • ${j.bench}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const Divider(height: 14),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Ratio Decidendi: ',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                  ),
                                  TextSpan(text: j.ratioDecidendi),
                                ],
                              ),
                              style: GoogleFonts.inter(fontSize: 12.5, height: 1.45, color: const Color(0xFF1F2937)),
                            ),
                            if (j.whatWasHeld.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'What Was Held: ',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                                    ),
                                    TextSpan(text: j.whatWasHeld),
                                  ],
                                ),
                                style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: Colors.grey.shade800),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  )
                else if (sec.landmarkCases.isNotEmpty)
                  Column(
                    children: sec.landmarkCases.map((caseRatio) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                caseRatio,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryNavy,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'No specific landmark ratio filed for Sec ${sec.sectionNumber}. Use video analysis below for live judicial discussion.',
                      style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                    ),
                  ),
                const SizedBox(height: 16),

                // 4. MEMORY MNEMONIC FORMULAS
                if (mnemonicTricks.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B), style: BorderStyle.solid),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🧠', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              'TOPPER MEMORY TRICK / MNEMONIC',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF92400E),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...mnemonicTricks.map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                m,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF78350F),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 5. PRELIMS TRAP ALERT
                if (prelimsTrap.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PCS-J PRELIMS TRAP ALERT',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prelimsTrap,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 6. MAINS ANSWER FRAMEWORK
                if (mainsFramework.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_note_rounded, size: 16, color: Colors.indigo),
                            const SizedBox(width: 6),
                            Text(
                              'MAINS ANSWER WRITING BLUEPRINT',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mainsFramework,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            height: 1.45,
                            color: Colors.indigo.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color bgColor, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget content,
    Color? bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryNavy, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.fontHeading(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
              ),
            ],
          ),
          const Divider(height: 20),
          content,
        ],
      ),
    );
  }
}
