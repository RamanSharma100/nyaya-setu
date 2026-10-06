import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/india_code_client.dart';
import '../../core/storage/hive_service.dart';
import '../../core/utils/youtube_helper.dart';
import '../../shared/models/state_syllabus.dart';
import '../../shared/widgets/pomodoro_timer_widget.dart';
import '../../shared/widgets/youtube_video_card.dart';
import '../bare_acts/bare_acts_screen.dart';
import '../bare_acts/section_detail_screen.dart';
import '../../shared/models/bare_act.dart';
import '../../shared/widgets/app_monogram_logo.dart';
import '../../core/constants/app_typography.dart';

final selectedStateProvider = StateProvider<String>((ref) {
  return HiveService.getSelectedState();
});

final statesSyllabusProvider = FutureProvider<List<StateSyllabus>>((ref) async {
  final client = ref.read(indiaCodeClientProvider);
  return client.fetchStatesSyllabus();
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final Map<String, bool> _localActsProgress = {};

  @override
  Widget build(BuildContext context) {
    final currentStateCode = ref.watch(selectedStateProvider);
    final syllabusAsync = ref.watch(statesSyllabusProvider);
    final bareActsAsync = ref.watch(bareActsProvider);
    final userProfile = ref.watch(userProfileProvider);
    final featuredVideo = YouTubeHelper.getMatchingVideo('mob lynching');

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        slivers: [
          _buildSliverAppBar(context, userProfile),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                syllabusAsync.when(
                  data: (syllabi) {
                    if (syllabi.isEmpty) return const SizedBox.shrink();
                    final selected = syllabi.where((s) => s.code == currentStateCode).firstOrNull ?? syllabi.first;
                    return _buildStateSelector(syllabi, selected, currentStateCode);
                  },
                  loading: () => const LinearProgressIndicator(
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(AppColors.accentGold),
                  ),
                  error: (e, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),
                _buildSectionHeader('Quick Actions', Icons.apps_rounded),
                const SizedBox(height: 12),
                _buildQuickActionsGrid(context),
                const SizedBox(height: 24),
                bareActsAsync.when(
                  data: (acts) => _buildSectionOfDayCard(context, acts),
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Daily Video Lecture', Icons.play_circle_outline_rounded),
                const SizedBox(height: 12),
                YouTubeVideoCard(
                  video: featuredVideo,
                  searchQuery: 'Bharatiya Nyaya Sanhita landmark sections',
                  compactLabel: 'FEATURED LESSON',
                ),
                const SizedBox(height: 24),
                const PomodoroTimerWidget(),
                const SizedBox(height: 24),
                syllabusAsync.when(
                  data: (syllabi) {
                    if (syllabi.isEmpty) return const SizedBox.shrink();
                    final selected = syllabi.where((s) => s.code == currentStateCode).firstOrNull ?? syllabi.first;
                    return _buildLocalActsProgress(selected, currentStateCode);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                _buildRoadmapCard(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    dynamic userProfile,
  ) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryNavy,
      toolbarHeight: 68,
      titleSpacing: 16,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryNavy, Color(0xFF1A3A5C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppMonogramLogo(size: 38, showGlow: false),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userProfile.isLoggedIn
                      ? 'Welcome back, ${(userProfile.displayName.trim().isNotEmpty) ? userProfile.displayName.trim().split(' ').first : 'Aspirant'}! 👋'
                      : 'Welcome to NyayaSetu 👋',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Crack Your Exam',
                  style: AppTypography.fontHeading(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search_rounded, size: 20, color: Colors.white),
          ),
          tooltip: 'Concept & Video Search',
          onPressed: () => context.push('/concept_search'),
        ),
        if (!userProfile.isLoggedIn)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Semantics(
                button: true,
                label: 'Sign In to NyayaSetu',
                child: FilledButton(
                  onPressed: () => context.go('/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(60, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userProfile.displayName.isNotEmpty
                          ? userProfile.displayName[0].toUpperCase()
                          : 'U',
                      style: AppTypography.fontHeading(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStateSelector(
    List<StateSyllabus> syllabi,
    StateSyllabus selected,
    String currentStateCode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school_rounded, color: AppColors.accentGold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TARGET JUDICIARY EXAM',
                  style: GoogleFonts.inter(
                    color: AppColors.accentGold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selected.code,
                    dropdownColor: AppColors.secondaryNavy,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.accentGold, size: 20),
                    isExpanded: true,
                    isDense: true,
                    style: AppTypography.fontHeading(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    selectedItemBuilder: (context) {
                      return syllabi.map((s) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            s.stateName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: AppTypography.fontHeading(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    items: syllabi.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.code,
                        child: Text(
                          s.stateName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newCode) {
                      if (newCode != null) {
                        ref.read(selectedStateProvider.notifier).state = newCode;
                        HiveService.setSelectedState(newCode);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMiniChip('P: ${selected.examPattern.prelimsMarks}M'),
              const SizedBox(width: 6),
              _buildMiniChip('M: ${selected.examPattern.mainsTotalMarks}M'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: AppColors.accentGold,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryNavy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryNavy),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.sectionTitle,
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.search_rounded,
        title: 'Search',
        subtitle: 'Concepts & Videos',
        gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
        onTap: () => context.push('/concept_search'),
      ),
      _ActionItem(
        icon: Icons.quiz_rounded,
        title: 'Mock Test',
        subtitle: 'Prelims MCQs',
        gradient: const LinearGradient(colors: [Color(0xFF065F46), Color(0xFF10B981)]),
        onTap: () => context.push('/prelims'),
      ),
      _ActionItem(
        icon: Icons.edit_note_rounded,
        title: 'Mains',
        subtitle: 'Answer Writing',
        gradient: const LinearGradient(colors: [Color(0xFF92400E), Color(0xFFD97706)]),
        onTap: () => context.push('/mains'),
      ),
      _ActionItem(
        icon: Icons.auto_awesome_rounded,
        title: 'Nyaya AI',
        subtitle: 'AI Assistant',
        gradient: const LinearGradient(colors: [Color(0xFF5B21B6), Color(0xFF8B5CF6)]),
        onTap: () => context.go('/gemini_tab'),
      ),
      _ActionItem(
        icon: Icons.menu_book_rounded,
        title: 'Bare Acts',
        subtitle: 'BNS, BNSS, BSA',
        gradient: const LinearGradient(colors: [Color(0xFF881337), Color(0xFFBE123C)]),
        onTap: () => context.go('/bare_acts'),
      ),
      _ActionItem(
        icon: Icons.gavel_rounded,
        title: 'Case Laws',
        subtitle: 'SC Judgments',
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
        onTap: () => context.go('/case_laws'),
      ),
    ];

    // Fixed: replaced GridView(shrinkWrap:true) with Column+Row to avoid
    // infinite layout loop inside SliverList.
    final row1 = actions.sublist(0, 3);
    final row2 = actions.sublist(3, 6);

    Widget buildRow(List<_ActionItem> items, int startIndex) {
      return Row(
        children: items.asMap().entries.map((e) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: e.key == 0 ? 0 : 5,
                right: e.key == items.length - 1 ? 0 : 5,
              ),
              child: _buildActionCard(e.value, startIndex + e.key),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        SizedBox(height: 108, child: buildRow(row1, 0)),
        const SizedBox(height: 10),
        SizedBox(height: 108, child: buildRow(row2, 3)),
      ],
    );
  }

  Widget _buildActionCard(_ActionItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: item.gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: item.gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 20),
                ),
                const Spacer(),
                Text(
                  item.title,
                  style: AppTypography.fontHeading(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionOfDayCard(BuildContext context, List<BareAct> acts) {
    if (acts.isEmpty) return const SizedBox.shrink();
    final bnsAct = acts.where((a) => a.shortTitle == 'BNS').firstOrNull ?? acts.firstOrNull;
    if (bnsAct == null || bnsAct.sections.isEmpty) return const SizedBox.shrink();
    final targetSec = bnsAct.sections.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Section of the Day', Icons.lightbulb_outline_rounded),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SectionDetailScreen(bareAct: bnsAct, section: targetSec),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.menu_book_rounded, color: AppColors.accentGold, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                '${bnsAct.shortTitle} • Sec ${targetSec.sectionNumber}',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primaryNavy,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      targetSec.title,
                      style: AppTypography.fontHeading(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      targetSec.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.fontStatute(
                        fontSize: 13,
                        color: AppColors.textMutedDark,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocalActsProgress(StateSyllabus selected, String currentStateCode) {
    final completedCount = _localActsProgress.values.where((v) => v).length;
    final totalCount = selected.localActs.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('${selected.code} Study Progress', Icons.track_changes_rounded),
            Text(
              '$completedCount/$totalCount',
              style: AppTypography.fontHeading(
                fontWeight: FontWeight.w700,
                color: AppColors.accentGold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(AppColors.emeraldGreen),
            minHeight: 7,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}% Complete',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textMutedDark,
          ),
        ),

        const SizedBox(height: 14),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: selected.localActs.asMap().entries.map((entry) {
              final idx = entry.key;
              final act = entry.value;
              final isDone = _localActsProgress[act] ?? false;

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: GestureDetector(
                      onTap: () => setState(() => _localActsProgress[act] = !isDone),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.emeraldGreen : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone ? AppColors.emeraldGreen : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: isDone
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                    title: Text(
                      act,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDone ? AppColors.textMutedDark : AppColors.textPrimaryDark,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textMutedDark,
                      ),
                    ),
                    subtitle: Text(
                      isDone ? '✓ Completed' : 'Tap to mark as done',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDone ? AppColors.emeraldGreen : AppColors.textMutedDark,
                      ),
                    ),
                    onTap: () => setState(() => _localActsProgress[act] = !isDone),
                  ),
                  if (idx < selected.localActs.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Colors.grey.shade100,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRoadmapCard(BuildContext context) {
    final roadmapItems = [
      _RoadmapItem(
        emoji: '🤖',
        title: 'NyayaAI Mains Evaluator',
        desc: 'Instant AI scoring on judicial answers against IRAC rubrics.',
        color: AppColors.violetPurple,
      ),
      _RoadmapItem(
        emoji: '🎧',
        title: 'Audio Bare Acts',
        desc: 'Listen to section summaries and SC ratios on the go.',
        color: AppColors.sapphireBlue,
      ),
      _RoadmapItem(
        emoji: '📊',
        title: 'Performance Analytics',
        desc: 'Subject-wise accuracy & prelims readiness score.',
        color: AppColors.emeraldGreen,
      ),
      _RoadmapItem(
        emoji: '🌐',
        title: 'Full Offline Sync',
        desc: 'Study BNS/BNSS/BSA completely offline.',
        color: AppColors.accentGold,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Platform Roadmap', Icons.rocket_launch_rounded),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryNavy, Color(0xFF1A3A5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: roadmapItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: idx < roadmapItems.length - 1 ? 16 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: item.color.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTypography.fontHeading(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.desc,
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Soon',
                        style: GoogleFonts.inter(
                          color: item.color,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
}

class _RoadmapItem {
  final String emoji;
  final String title;
  final String desc;
  final Color color;

  const _RoadmapItem({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.color,
  });
}
