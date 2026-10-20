import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/handmade_notes_service.dart';
import '../../core/storage/hive_service.dart';
import '../../shared/models/handmade_note.dart';
import '../../shared/widgets/search_bar.dart';
import '../../shared/widgets/youtube_video_card.dart';
import '../../shared/widgets/windowing_infinite_scroll_list.dart';

class HandmadeNotesScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  final String? initialQuery;
  final bool isEmbedded;

  const HandmadeNotesScreen({
    super.key,
    this.initialFilter,
    this.initialQuery,
    this.isEmbedded = false,
  });

  @override
  ConsumerState<HandmadeNotesScreen> createState() => _HandmadeNotesScreenState();
}

class _HandmadeNotesScreenState extends ConsumerState<HandmadeNotesScreen> {
  late String _selectedFilter;
  late String _searchQuery;
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  final Map<String, TextEditingController> _annotationControllers = {};

  final List<String> _filters = [
    'All',
    'Minor Acts',
    'Major Acts',
    'Contract (ICA)',
    'Specific Relief (SRA)',
    'Limitation Act',
    'NI Act',
    'TPA',
    'POCSO',
    'BNS 2023',
    'BNSS 2023',
    'BSA 2023',
    'Constitution',
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'All';
    _searchQuery = widget.initialQuery ?? '';
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    for (final c in _annotationControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(handmadeNotesProvider);

    return Scaffold(
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Handmade Notes & Digests'),
                  Text(
                    'Topper notes, landmark ratios & video lectures',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_rounded),
            tooltip: 'Sync Live Notes from Internet',
            onPressed: () {
              ref.invalidate(handmadeNotesProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syncing live notes from OpenNyAI & Central Legal APIs...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Search notes, landmark cases, ratios, or sections...',
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      final isMinorPill = filter == 'Minor Acts';
                      final isMajorPill = filter == 'Major Acts';

                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          selected: isSelected,
                          checkmarkColor: Colors.white,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isMinorPill) const Text('📜 ') else if (isMajorPill) const Text('⭐ '),
                              Text(filter),
                            ],
                          ),
                          selectedColor: isMinorPill
                              ? const Color(0xFFD97706)
                              : isMajorPill
                                  ? AppColors.primaryNavy
                                  : AppColors.primaryNavy,
                          backgroundColor: Colors.grey.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedFilter = filter);
                            if (_scrollController.hasClients) {
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Notes List
          Expanded(
            child: notesAsync.when(
              data: (allNotes) {
                final filtered = allNotes.where((note) {
                  if (!HandmadeNotesService.matchesFilter(note, _selectedFilter)) return false;
                  return HandmadeNotesService.matchesSearch(note, _searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No notes match "$_searchQuery"'
                                : 'No notes found for "$_selectedFilter"',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try clearing your search or switching to "All" or "Major Acts".',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          if (_searchQuery.isNotEmpty || _selectedFilter != 'All') ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryNavy,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                  _selectedFilter = 'All';
                                });
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Reset Search & Filters'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return WindowingInfiniteScrollList<HandmadeNote>(
                  items: filtered,
                  pageSize: 4,
                  controller: _scrollController,
                  itemLabel: 'topper notes',
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
                  itemBuilder: (context, note, index) => _buildHandmadeNoteCard(note, index),
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.accentGold),
                    SizedBox(height: 16),
                    Text('Loading Judicial Notes & Landmark Judgments...'),
                  ],
                ),
              ),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text('Failed to load notes: $err'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.refresh(handmadeNotesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandmadeNoteCard(HandmadeNote note, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMinor = note.isMinorAct;

    if (!_annotationControllers.containsKey(note.id)) {
      _annotationControllers[note.id] = TextEditingController(text: note.userAnnotation);
    }
    final annotationController = _annotationControllers[note.id]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMinor
              ? (isDark ? Colors.amber.withValues(alpha: 0.3) : const Color(0xFFFDE68A))
              : (isDark ? Colors.blue.withValues(alpha: 0.25) : const Color(0xFFE2E8F0)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left notebook red margin line for realistic handwritten pad aesthetic
          Positioned(
            left: 28,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1.5,
              color: isDark ? Colors.red.withValues(alpha: 0.25) : const Color(0xFFFCA5A5).withValues(alpha: 0.6),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(40, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag Bar
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isMinor
                              ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7))
                              : (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isMinor ? Icons.menu_book_rounded : Icons.star_rounded,
                              size: 13,
                              color: isMinor
                                  ? (isDark ? Colors.amber : const Color(0xFF92400E))
                                  : (isDark ? Colors.lightBlueAccent : const Color(0xFF1E40AF)),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                isMinor ? 'MINOR ACT • ${note.actShortTitle}' : 'MAJOR ACT • ${note.actShortTitle}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                  color: isMinor
                                      ? (isDark ? Colors.amber : const Color(0xFF92400E))
                                      : (isDark ? Colors.lightBlueAccent : const Color(0xFF1E40AF)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        note.sectionNumber,
                        style: GoogleFonts.firaCode(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Spacer(),
                    // Bookmark action
                    IconButton(
                      icon: Icon(
                        note.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: note.isBookmarked ? AppColors.accentGold : Colors.grey,
                        size: 20,
                      ),
                      tooltip: note.isBookmarked ? 'Remove Bookmark' : 'Bookmark Note',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        await HiveService.toggleHandmadeNoteBookmark(note.id);
                        ref.invalidate(handmadeNotesProvider);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Note Title with Yellow Highlighter look
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.amber.withValues(alpha: 0.15)
                        : const Color(0xFFFEF08A).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    note.title,
                    style: GoogleFonts.lora(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Core Handwritten Rule Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📌', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note.coreRule,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                            color: isDark ? Colors.amber.shade200 : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Topper Checklist / Key Ingredients
                Text(
                  'Key Ingredients & Handwritten Points:',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                ...note.bulletPoints.map(
                  (pt) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade600)),
                        Expanded(
                          child: Text(
                            pt,
                            style: GoogleFonts.inter(fontSize: 12.5, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Landmark Judgments Section
                if (note.landmarkJudgments.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.gavel_rounded, size: 16, color: AppColors.accentGold),
                      const SizedBox(width: 6),
                      Text(
                        'Landmark Judgments & Ratio Decidendi (${note.landmarkJudgments.length}):',
                        style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...note.landmarkJudgments.map((j) => _buildLandmarkJudgmentCard(j, isDark)),
                ],

                // Topper Mnemonics
                if (note.mnemonicTricks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_rounded, size: 15, color: Color(0xFF059669)),
                            const SizedBox(width: 6),
                            Text(
                              'Topper Mnemonic & Formula:',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...note.mnemonicTricks.map(
                          (m) => Text(
                            m,
                            style: GoogleFonts.firaCode(fontSize: 11.5, height: 1.35, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Prelims Trap Alert
                if (note.prelimsTrapAlert.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.redAccent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            note.prelimsTrapAlert,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Video Lecture Card
                const SizedBox(height: 14),
                YouTubeVideoCard(
                  video: note.videoLecture,
                  searchQuery: note.videoSearchQuery.isNotEmpty ? note.videoSearchQuery : '${note.title} Judiciary',
                  compactLabel: 'VIDEO LECTURE',
                ),

                // User's Personal Handwritten Study Annotation
                const SizedBox(height: 16),
                _buildAnnotationSection(note, annotationController, isDark),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms);
  }

  Widget _buildLandmarkJudgmentCard(LandmarkJudgmentNote j, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  j.caseName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.blue.shade300 : const Color(0xFF1E3A8A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${j.year}',
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            j.citation,
            style: GoogleFonts.firaCode(fontSize: 11, color: Colors.grey),
          ),
          if (j.bench.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Bench: ${j.bench}',
              style: GoogleFonts.inter(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.grey.shade500),
            ),
          ],
          const SizedBox(height: 6),
          // Ratio Decidendi Quote
          Container(
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.accentGold, width: 2.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ratio Decidendi:',
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                ),
                Text(
                  j.ratioDecidendi,
                  style: GoogleFonts.lora(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          if (j.whatWasHeld.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Held: ${j.whatWasHeld}',
              style: GoogleFonts.inter(fontSize: 11.5, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnnotationSection(HandmadeNote note, TextEditingController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, size: 16, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                'My Personal Study Notes & Ratios:',
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 3,
            style: GoogleFonts.caveat(
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Write your handwritten notes, memory cues, or citations here...',
              hintStyle: GoogleFonts.inter(fontSize: 11.5, fontStyle: FontStyle.italic, color: Colors.grey),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_rounded, size: 14),
              label: const Text('Save Note', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 30),
              ),
              onPressed: () async {
                await HiveService.saveHandmadeNoteAnnotation(note.id, controller.text);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Personal study note saved into notebook storage!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
