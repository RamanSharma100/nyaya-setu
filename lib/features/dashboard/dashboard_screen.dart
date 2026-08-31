import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/india_code_client.dart';
import '../../core/storage/hive_service.dart';
import '../../shared/models/state_syllabus.dart';
import '../../shared/widgets/pomodoro_timer_widget.dart';
import '../bare_acts/bare_acts_screen.dart';
import '../bare_acts/section_detail_screen.dart';

final selectedStateProvider = StateProvider<String>((ref) {
  return HiveService.getSelectedState();
});

final indiaCodeClientProvider = Provider((ref) => IndiaCodeApiClient());

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
  bool _showGuide = true;

  @override
  Widget build(BuildContext context) {
    final currentStateCode = ref.watch(selectedStateProvider);
    final syllabusAsync = ref.watch(statesSyllabusProvider);
    final bareActsAsync = ref.watch(bareActsProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NyayaSetu Dashboard'),
        actions: [
          if (!userProfile.isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: ElevatedButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.login, size: 14),
                label: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.manage_search),
            tooltip: 'Exam Concept Search',
            onPressed: () => context.push('/concept_search'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'App Guide for Beginners',
            onPressed: () => setState(() => _showGuide = !_showGuide),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Live Data',
            onPressed: () {
              ref.invalidate(statesSyllabusProvider);
              ref.invalidate(bareActsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statesSyllabusProvider);
          ref.invalidate(bareActsProvider);
        },
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 40.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!userProfile.isLoggedIn) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentGold),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_circle,
                        color: AppColors.primaryNavy,
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Browsing in Guest Mode',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sign in to save bookmarks, Mains drafts, and sync study goals across devices.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.login, size: 16),
                        label: const Text('Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
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
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Target Judicial Service Goal:',
                          style: GoogleFonts.inter(
                            color: AppColors.textMutedDark,
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'LIVE REST API',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryNavy,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    syllabusAsync.when(
                      data: (syllabi) {
                        if (syllabi.isEmpty) {
                          return const Text(
                            'No syllabus available',
                            style: TextStyle(color: Colors.white),
                          );
                        }
                        final selectedSyllabus = syllabi.firstWhere(
                          (s) => s.code == currentStateCode,
                          orElse: () => syllabi.first,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedSyllabus.code,
                                dropdownColor: AppColors.secondaryNavy,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.accentGold,
                                ),
                                isExpanded: true,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                items: syllabi.map((s) {
                                  return DropdownMenuItem<String>(
                                    value: s.code,
                                    child: Text(s.stateName),
                                  );
                                }).toList(),
                                onChanged: (newCode) {
                                  if (newCode != null) {
                                    ref
                                            .read(
                                              selectedStateProvider.notifier,
                                            )
                                            .state =
                                        newCode;
                                    HiveService.setSelectedState(newCode);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildMetricChip(
                                  'Prelims: ${selectedSyllabus.examPattern.prelimsMarks} Marks',
                                ),
                                _buildMetricChip(
                                  'Mains: ${selectedSyllabus.examPattern.mainsTotalMarks} Marks',
                                ),
                                _buildMetricChip(
                                  'Neg: ${selectedSyllabus.examPattern.negativeMarking}',
                                ),
                                _buildMetricChip(
                                  '${selectedSyllabus.mainsPapers.length} Mains Papers',
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentGold,
                        ),
                      ),
                      error: (err, stack) => Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Network error: $err',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                ref.refresh(statesSyllabusProvider),
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: AppColors.accentGold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_showGuide) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.school,
                            color: AppColors.primaryNavy,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'How to Master Judicial Prep with NyayaSetu',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _showGuide = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'NyayaSetu provides comprehensive tools for Indian Judicial Service (PCS-J) aspirants:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildGuidePoint(
                        '1. Bare Acts & Law Converter',
                        'Compare 2023 criminal codes (BNS/BNSS/BSA) side-by-side with old IPC/CrPC.',
                      ),
                      _buildGuidePoint(
                        '2. Detailed Case Examples',
                        'Tap any section to view real-world examples, legal elements, and SC ratios.',
                      ),
                      _buildGuidePoint(
                        '3. Prelims Deck & MCQs',
                        'Practice spaced repetition flashcards & timed Hugging Face open datasets.',
                      ),
                      _buildGuidePoint(
                        '4. Mains Answer Writing',
                        'Draft answers with exam timers & self-evaluate against model rubrics.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Text(
                'Live Dynamic Section of the Day',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              bareActsAsync.when(
                data: (acts) {
                  if (acts.isEmpty) return const SizedBox.shrink();
                  final bnsAct = acts.firstWhere(
                    (a) => a.shortTitle == 'BNS',
                    orElse: () => acts.first,
                  );
                  final targetSec = bnsAct.sections.isNotEmpty
                      ? bnsAct.sections.first
                      : null;

                  if (targetSec == null) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SectionDetailScreen(
                            bareAct: bnsAct,
                            section: targetSec,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentGold.withValues(alpha: 0.15),
                            Colors.amber.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryNavy,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${bnsAct.shortTitle} - Section ${targetSec.sectionNumber}',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Details',
                                    style: GoogleFonts.inter(
                                      color: AppColors.primaryNavy,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.primaryNavy,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            targetSec.title,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            targetSec.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accentGold),
                ),
                error: (err, stack) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),
              const PomodoroTimerWidget(),
              const SizedBox(height: 24),

              syllabusAsync.when(
                data: (syllabi) {
                  if (syllabi.isEmpty) return const SizedBox.shrink();
                  final selected = syllabi.firstWhere(
                    (s) => s.code == currentStateCode,
                    orElse: () => syllabi.first,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${selected.code} Local Acts Progress',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${selected.localActs.length} High-Yield Acts',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: selected.localActs.map((act) {
                              final isDone = _localActsProgress[act] ?? false;
                              return CheckboxListTile(
                                value: isDone,
                                activeColor: AppColors.emeraldGreen,
                                title: Text(
                                  act,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(
                                  isDone
                                      ? 'Marked Completed for $currentStateCode'
                                      : 'Tap to mark studied',
                                  style: GoogleFonts.inter(fontSize: 11),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _localActsProgress[act] = val ?? false;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),
              Text(
                '🚀 Upcoming Platform Roadmap',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryNavy, AppColors.secondaryNavy],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRoadmapItem(
                      '🤖 NyayaAI Live Mains Evaluator',
                      'Instant AI feedback & scoring on judicial answer writing against IRAC rubrics.',
                    ),
                    _buildRoadmapItem(
                      '🎧 Audio Bare Acts & Ratio Summaries',
                      'Listen to section numbers, penalties, and landmark Supreme Court ratios on the go.',
                    ),
                    _buildRoadmapItem(
                      '📊 Performance Diagnostic Dashboard',
                      'Subject-wise accuracy breakdown & state-wise prelims readiness score.',
                    ),
                    _buildRoadmapItem(
                      '🌐 Full Offline Database Sync',
                      'Study BNS/BNSS/BSA bare acts and case laws completely offline.',
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Thank you! Your feature suggestion has been recorded for the roadmap.',
                              ),
                              backgroundColor: AppColors.emeraldGreen,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.accentGold,
                          size: 16,
                        ),
                        label: Text(
                          'Suggest a Feature',
                          style: GoogleFonts.inter(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
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

  Widget _buildRoadmapItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.rocket_launch,
            color: AppColors.accentGold,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildGuidePoint(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.emeraldGreen,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(text: desc, style: GoogleFonts.inter(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
