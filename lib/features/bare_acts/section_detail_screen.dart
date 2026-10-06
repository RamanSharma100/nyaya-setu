import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/storage/hive_service.dart';
import '../../core/utils/youtube_helper.dart';
import '../../shared/models/bare_act.dart';
import '../../shared/widgets/youtube_video_card.dart';

class SectionDetailScreen extends StatefulWidget {
  final BareAct bareAct;
  final Section section;

  const SectionDetailScreen({
    super.key,
    required this.bareAct,
    required this.section,
  });

  @override
  State<SectionDetailScreen> createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends State<SectionDetailScreen> {
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          sec.chapter,
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
                          AppColors.accentGold,
                          textColor: AppColors.primaryNavy,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // YouTube Video Breakdown Card
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
            _buildSectionCard(
              title: 'Full Statutory Text',
              icon: Icons.gavel,
              content: SelectableText(
                sec.content,
                style: AppTypography.fontStatute(fontSize: 15, height: 1.65, color: const Color(0xFF1F2937)),
              ),
            ),
            const SizedBox(height: 16),
            if (sec.explanation.isNotEmpty) ...[
              _buildSectionCard(
                title: 'Explanation & Legislative Intent',
                icon: Icons.info_outline,
                content: Text(sec.explanation, style: GoogleFonts.inter(fontSize: 14, height: 1.5)),
                bgColor: Colors.amber.shade50,
              ),
              const SizedBox(height: 16),
            ],
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
            if (sec.keyIngredients.isNotEmpty) ...[
              _buildSectionCard(
                title: 'Key Legal Ingredients & Elements',
                icon: Icons.checklist,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sec.keyIngredients.map((ingredient) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.emeraldGreen, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(ingredient, style: GoogleFonts.inter(fontSize: 14, height: 1.4, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (sec.landmarkCases.isNotEmpty) ...[
              _buildSectionCard(
                title: 'Landmark Supreme Court Ratios',
                icon: Icons.account_balance,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sec.landmarkCases.map((caseRatio) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.star, color: AppColors.primaryNavy, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              caseRatio,
                              style: GoogleFonts.inter(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.primaryNavy),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (sec.examTips.isNotEmpty) ...[
              _buildSectionCard(
                title: 'PCS-J High-Yield Exam Guidance',
                icon: Icons.school,
                content: Text(
                  sec.examTips,
                  style: GoogleFonts.inter(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.primaryNavy),
                ),
                bgColor: AppColors.accentGold.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 16),
            ],
            _buildSectionCard(
              title: 'My Personal Study Notes',
              icon: Icons.edit_note,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    style: GoogleFonts.inter(fontSize: 14, height: 1.5),
                    decoration: const InputDecoration(
                      hintText: 'Add personal study notes, landmark ratios, or mnemonics...',
                      border: OutlineInputBorder(),
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
                      icon: const Icon(Icons.save),
                      label: const Text('Save Note'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
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
