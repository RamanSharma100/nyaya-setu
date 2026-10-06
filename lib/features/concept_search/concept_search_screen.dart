import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/network/concept_aggregator_service.dart';
import '../../core/utils/youtube_helper.dart';
import '../../shared/widgets/youtube_video_card.dart';
import '../bare_acts/section_detail_screen.dart';

final dynamicConceptSearchProvider = FutureProvider.family<List<DynamicConceptItem>, String>((ref, query) async {
  final service = ref.read(conceptAggregatorServiceProvider);
  return service.searchConceptsDynamically(query);
});

class ConceptSearchScreen extends ConsumerStatefulWidget {
  const ConceptSearchScreen({super.key});

  @override
  ConsumerState<ConceptSearchScreen> createState() => _ConceptSearchScreenState();
}

class _ConceptSearchScreenState extends ConsumerState<ConceptSearchScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _searchFocusController;
  bool _searchFocused = false;

  final List<String> _quickSearches = [
    'Res Judicata',
    'Zero FIR',
    'Mob Lynching',
    'Article 21',
    'Habeas Corpus',
    'POCSO',
    'Bail Conditions',
    'BNS 103',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(dynamicConceptSearchProvider(_searchQuery));
    final bool hasQuery = _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero search AppBar
          SliverAppBar(
            expandedHeight: hasQuery ? 120 : 220,
            pinned: true,
            snap: true,
            floating: true,
            backgroundColor: AppColors.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
              onPressed: () => Navigator.maybePop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                onPressed: () => ref.invalidate(dynamicConceptSearchProvider(_searchQuery)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildSearchHeader(hasQuery),
            ),
          ),

          // Quick search chips (when no query)
          if (!hasQuery)
            SliverToBoxAdapter(
              child: _buildQuickSearchSection(),
            ),

          // Results
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            sliver: searchResultsAsync.when(
              data: (items) {
                if (items.isEmpty && hasQuery) {
                  return SliverToBoxAdapter(child: _buildEmptyState());
                }
                if (!hasQuery) {
                  return SliverToBoxAdapter(child: _buildStartSearchState());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildConceptCard(context, items[index], index);
                    },
                    childCount: items.length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(child: _buildLoadingState()),
              error: (err, _) => SliverToBoxAdapter(child: _buildErrorState()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(bool hasQuery) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryNavy, Color(0xFF1A3A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative element
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGold.withValues(alpha: 0.07),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!hasQuery) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.psychology_rounded, color: AppColors.accentGold, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Concept & Video Engine',
                          style: AppTypography.fontHeading(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'LIVE',
                            style: GoogleFonts.inter(
                              color: AppColors.emeraldGreen,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search any concept → get statutes, SC cases & videos',
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                  ],
                  // Search field
                  _buildSearchField(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _searchFocused ? Colors.white : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _searchFocused ? AppColors.accentGold : Colors.white.withValues(alpha: 0.2),
          width: _searchFocused ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(Icons.search_rounded, color: AppColors.accentGold, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              onTap: () => setState(() => _searchFocused = true),
              onTapOutside: (_) => setState(() => _searchFocused = false),
              style: GoogleFonts.inter(
                color: _searchFocused ? AppColors.textPrimaryDark : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Res Judicata, BNS 103, Zero FIR...',
                hintStyle: GoogleFonts.inter(
                  color: _searchFocused ? Colors.grey.shade400 : Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                filled: false,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.close_rounded, color: Colors.grey, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'QUICK SEARCHES',
                style: GoogleFonts.inter(
                  color: AppColors.textMutedDark,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickSearches.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = entry.value;
                  setState(() => _searchQuery = entry.value);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_rounded, size: 13, color: AppColors.textMutedDark),
                      const SizedBox(width: 5),
                      Text(
                        entry.value,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: 50 * entry.key)).fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildConceptCard(BuildContext context, DynamicConceptItem item, int index) {
    final video = YouTubeHelper.getMatchingVideo(item.conceptName);

    return GestureDetector(
      onTap: () => _openConceptDetailModal(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.conceptName,
                          style: AppTypography.fontHeading(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accentGold, Color(0xFFF5E27A)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.examCategory,
                          style: GoogleFonts.inter(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.crimsonRed.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.actAndSection,
                          style: GoogleFonts.inter(
                            color: AppColors.crimsonRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Tap to explore  →',
                        style: GoogleFonts.inter(
                          color: AppColors.textMutedDark,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.definition,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ],
              ),
            ),

            // YouTube card at bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: YouTubeVideoCard(
                video: video,
                searchQuery: item.conceptName,
                compactLabel: 'CONCEPT LECTURE',
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 80 * index)).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStartSearchState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryNavy.withValues(alpha: 0.05),
                  AppColors.primaryNavy.withValues(alpha: 0.02),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded, size: 48, color: AppColors.primaryNavy),
          ),
          const SizedBox(height: 16),
          Text(
            'Search any legal concept',
            style: AppTypography.fontHeading(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try "Res Judicata", "BNS 103", or "Zero FIR"\nto get statutes, cases & video explanations',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textMutedDark,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: AppTypography.fontHeading(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Try different keywords like\n"Habeas Corpus" or "Article 21"',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.textMutedDark, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppColors.accentGold,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Searching live database...',
            style: GoogleFonts.inter(color: AppColors.textMutedDark, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.crimsonRed.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.crimsonRed),
          ),
          const SizedBox(height: 16),
          Text(
            'Connection Error',
            style: AppTypography.fontHeading(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(dynamicConceptSearchProvider(_searchQuery)),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _openConceptDetailModal(BuildContext context, DynamicConceptItem item) {
    final video = YouTubeHelper.getMatchingVideo(item.conceptName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.88,
            maxChildSize: 0.96,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Handle
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.conceptName,
                                style: AppTypography.fontHeading(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.crimsonRed.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.actAndSection,
                                  style: GoogleFonts.inter(
                                    color: AppColors.crimsonRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 18),
                          ),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 20, indent: 20, endIndent: 20),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalSectionLabel('📹 Video Lecture'),
                          const SizedBox(height: 8),
                          YouTubeVideoCard(
                            video: video,
                            searchQuery: item.conceptName,
                          ),
                          const SizedBox(height: 20),

                          _buildModalSectionLabel('📋 Statutory Summary'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.bgLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              item.definition,
                              style: GoogleFonts.inter(fontSize: 14, height: 1.6),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (item.practicalExamples.isNotEmpty) ...[
                            _buildModalSectionLabel('💡 Real-World Scenarios'),
                            const SizedBox(height: 8),
                            ...item.practicalExamples.asMap().entries.map((e) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldGreen.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.emeraldGreen.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${e.key + 1}',
                                          style: AppTypography.fontHeading(
                                            color: AppColors.emeraldGreen,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        e.value,
                                        style: GoogleFonts.inter(fontSize: 13, height: 1.5),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                          ],

                          _buildModalSectionLabel('⚖️ Landmark SC Precedent'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.sapphireBlue.withValues(alpha: 0.06),
                                  AppColors.sapphireBlue.withValues(alpha: 0.02),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.sapphireBlue.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.gavel_rounded, color: AppColors.sapphireBlue, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item.landmarkCase,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryNavy,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.caseRatio,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Action buttons
                          Row(
                            children: [
                              if (item.rawAct != null && item.rawSection != null) ...[
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(modalContext);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SectionDetailScreen(
                                            bareAct: item.rawAct!,
                                            section: item.rawSection!,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.menu_book_rounded, size: 16),
                                    label: const Text('Full Section'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryNavy,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(modalContext);
                                    context.push('/mains');
                                  },
                                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                                  label: const Text('Practice Mains'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentGold,
                                    foregroundColor: AppColors.primaryNavy,
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildModalSectionLabel(String label) {
    return Text(
      label,
      style: AppTypography.fontHeading(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryNavy,
      ),
    );
  }
}
