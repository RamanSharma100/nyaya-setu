import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/network/huggingface_mcq_client.dart';
import '../../core/storage/hive_service.dart';
import '../../shared/models/mcq.dart';
import '../../shared/widgets/flashcard_swipe_widget.dart';

final huggingFaceClientProvider = Provider(
  (ref) => HuggingFaceLegalMCQClient(),
);

final mcqListProvider = FutureProvider<List<MCQ>>((ref) async {
  final client = ref.read(huggingFaceClientProvider);
  return client.fetchLegalMCQs();
});

class PrelimsScreen extends ConsumerStatefulWidget {
  const PrelimsScreen({super.key});

  @override
  ConsumerState<PrelimsScreen> createState() => _PrelimsScreenState();
}

class _PrelimsScreenState extends ConsumerState<PrelimsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedOptionIndex = -1;
  bool _submittedAnswer = false;
  int _mcqIndex = 0;
  int _score = 0;
  Timer? _quizTimer;
  int _quizTimeRemaining = 60;
  String _selectedSubjectFilter = 'All';

  final List<FlashcardItem> _sampleCards = [
    FlashcardItem(
      id: 'card_01',
      actName: 'BNS 2023',
      sectionNumber: 'Section 103',
      title: 'Punishment for Murder & Mob Lynching',
      keyDetails: 'Replaces IPC 302. Sub-section (2) explicitly penalizes group murders by 5+ members.',
      punishmentOrTerm: 'Death or Life Imprisonment, and Fine',
    ),
    FlashcardItem(
      id: 'card_02',
      actName: 'BNSS 2023',
      sectionNumber: 'Section 173',
      title: 'Information in Cognizable Cases (Zero FIR & e-FIR)',
      keyDetails: 'Replaces CrPC 154. Mandates signature on e-FIR within 3 days.',
      punishmentOrTerm: 'Mandatory registration regardless of jurisdiction',
    ),
    FlashcardItem(
      id: 'card_03',
      actName: 'BSA 2023',
      sectionNumber: 'Section 63',
      title: 'Admissibility of Electronic Records',
      keyDetails: 'Replaces IEA 65B. Requires electronic certificate for server/mobile logs.',
      punishmentOrTerm: 'Primary Documentary Evidence',
    ),
    FlashcardItem(
      id: 'card_04',
      actName: 'CPC 1908',
      sectionNumber: 'Section 11',
      title: 'Res Judicata',
      keyDetails: 'Bars re-litigation of issues decided between same parties under competent jurisdiction.',
      punishmentOrTerm: 'Plenary Procedural Bar',
    ),
    FlashcardItem(
      id: 'card_05',
      actName: 'Constitution',
      sectionNumber: 'Article 32',
      title: 'Remedies for Enforcement of Fundamental Rights',
      keyDetails: 'Heart and Soul of the Constitution. Powers to issue 5 Writs.',
      punishmentOrTerm: 'Supreme Court Writ Jurisdiction',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startTimer();
  }

  void _startTimer() {
    _quizTimer?.cancel();
    _quizTimeRemaining = 60;
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_quizTimeRemaining > 0) {
        setState(() => _quizTimeRemaining--);
      } else {
        _submitAnswer();
      }
    });
  }

  void _submitAnswer() {
    if (_submittedAnswer) return;
    _quizTimer?.cancel();
    setState(() => _submittedAnswer = true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quizTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mcqAsync = ref.watch(mcqListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Practice & Mock Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_search_rounded),
            tooltip: 'Concept Search',
            onPressed: () => context.push('/concept_search'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Restart Quiz',
            onPressed: () {
              ref.invalidate(mcqListProvider);
              setState(() {
                _mcqIndex = 0;
                _score = 0;
                _submittedAnswer = false;
                _selectedOptionIndex = -1;
              });
              _startTimer();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(11),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primaryNavy,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '📚  Flashcards'),
                Tab(text: '⏱️  MCQ Quiz'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Flashcard tab
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFlashcardHeader(),
                const SizedBox(height: 16),
                FlashcardSwipeWidget(
                  flashcards: _sampleCards,
                  onSwipe: (card, mastered) {
                    HiveService.updateFlashcardStatus(
                      card.id,
                      mastered ? 'mastered' : 'review',
                    );
                  },
                ),
              ],
            ),
          ),

          // MCQ Quiz tab
          mcqAsync.when(
            data: (mcqs) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(mcqListProvider);
                setState(() {
                  _mcqIndex = 0;
                  _score = 0;
                  _submittedAnswer = false;
                  _selectedOptionIndex = -1;
                });
                _startTimer();
              },
              child: _buildTimedMCQQuiz(mcqs),
            ),
            loading: () => _buildLoadingState(),
            error: (err, stack) => _buildErrorState(err),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryNavy, Color(0xFF1A3A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.style_rounded, color: AppColors.accentGold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spaced Repetition Flashcards',
                  style: AppTypography.fontHeading(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Swipe right to master • Left to review later',
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.emeraldGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${_sampleCards.length} cards',
              style: GoogleFonts.inter(
                color: AppColors.emeraldGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryNavy, Color(0xFF1A3A5C)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentGold,
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Fetching live MCQs...',
            style: GoogleFonts.inter(color: AppColors.textMutedDark, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.crimsonRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.crimsonRed),
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: AppTypography.fontHeading(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Could not fetch live MCQ dataset.\nCheck your connection and retry.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textMutedDark, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(mcqListProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimedMCQQuiz(List<MCQ> mcqs) {
    if (mcqs.isEmpty) {
      return Center(
        child: Text(
          'No MCQs available from the live dataset.',
          style: GoogleFonts.inter(color: AppColors.textMutedDark),
        ),
      );
    }

    final filteredMcqs = _selectedSubjectFilter == 'All'
        ? mcqs
        : mcqs.where((m) => m.subject == _selectedSubjectFilter).toList();
    final activeList = filteredMcqs.isEmpty ? mcqs : filteredMcqs;

    if (_mcqIndex >= activeList.length) {
      return _buildQuizCompleted(activeList.length);
    }

    final currentMCQ = activeList[_mcqIndex];
    final filterOptions = ['All', 'Criminal Law', 'Procedure', 'Evidence', 'Civil Law', 'Constitutional Law'];
    final timerProgress = _quizTimeRemaining / 60.0;
    final isTimeLow = _quizTimeRemaining <= 15;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: filterOptions.map((filter) {
                final isSelected = _selectedSubjectFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        setState(() {
                          _selectedSubjectFilter = filter;
                          _mcqIndex = 0;
                          _score = 0;
                          _submittedAnswer = false;
                          _selectedOptionIndex = -1;
                        });
                        _startTimer();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryNavy : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryNavy : Colors.grey.shade300,
                            width: 1.2,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: AppColors.primaryNavy.withValues(alpha: 0.2), blurRadius: 8)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textMutedDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Progress & Timer header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Q ${_mcqIndex + 1}',
                          style: AppTypography.fontHeading(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        Text(
                          ' of ${activeList.length}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '✓ $_score Correct',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.emeraldGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (_mcqIndex + 1) / activeList.length,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primaryNavy),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Timer circle
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(52, 52),
                      painter: _TimerPainter(
                        progress: timerProgress,
                        color: isTimeLow ? AppColors.crimsonRed : AppColors.emeraldGreen,
                      ),
                    ),
                    Text(
                      '$_quizTimeRemaining',
                      style: AppTypography.fontHeading(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isTimeLow ? AppColors.crimsonRed : AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Subject badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.sapphireBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.sapphireBlue.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${currentMCQ.stateExam} • ${currentMCQ.subject}',
              style: GoogleFonts.inter(
                color: AppColors.sapphireBlue,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              currentMCQ.question,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: AppColors.textPrimaryDark,
              ),
            ),
          ).animate(key: ValueKey(_mcqIndex)).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 14),

          // Options
          ...List.generate(currentMCQ.options.length, (index) {
            return _buildOptionTile(currentMCQ, index);
          }),

          const SizedBox(height: 20),

          // Submit / Next button
          if (!_submittedAnswer)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedOptionIndex != -1 ? _submitAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _selectedOptionIndex != -1 ? 'Submit Answer' : 'Select an Option',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else ...[
            // Explanation card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.sapphireBlue.withValues(alpha: 0.08),
                    AppColors.sapphireBlue.withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sapphireBlue.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.sapphireBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.info_outline_rounded, color: AppColors.sapphireBlue, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Explanation • ${currentMCQ.sectionRef}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: AppColors.sapphireBlue,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentMCQ.explanation,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedOptionIndex == currentMCQ.correctIndex) _score++;
                  setState(() {
                    _mcqIndex++;
                    _submittedAnswer = false;
                    _selectedOptionIndex = -1;
                  });
                  _startTimer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next Question',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile(MCQ currentMCQ, int index) {
    final optionText = currentMCQ.options[index];
    final isSelected = _selectedOptionIndex == index;
    final isCorrect = currentMCQ.correctIndex == index;

    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade200;
    Color textColor = AppColors.textPrimaryDark;
    Color indexBg = Colors.grey.shade100;
    Color indexText = AppColors.textMutedDark;
    IconData? trailingIcon;

    if (_submittedAnswer) {
      if (isCorrect) {
        bgColor = AppColors.emeraldGreen.withValues(alpha: 0.08);
        borderColor = AppColors.emeraldGreen;
        textColor = AppColors.emeraldGreen;
        indexBg = AppColors.emeraldGreen;
        indexText = Colors.white;
        trailingIcon = Icons.check_circle_rounded;
      } else if (isSelected) {
        bgColor = AppColors.crimsonRed.withValues(alpha: 0.06);
        borderColor = AppColors.crimsonRed;
        textColor = AppColors.crimsonRed;
        indexBg = AppColors.crimsonRed;
        indexText = Colors.white;
        trailingIcon = Icons.cancel_rounded;
      }
    } else if (isSelected) {
      bgColor = AppColors.primaryNavy.withValues(alpha: 0.05);
      borderColor = AppColors.primaryNavy;
      textColor = AppColors.primaryNavy;
      indexBg = AppColors.primaryNavy;
      indexText = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: _submittedAnswer ? null : () => setState(() => _selectedOptionIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected && !_submittedAnswer
                ? [BoxShadow(color: AppColors.primaryNavy.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: indexBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: AppTypography.fontHeading(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: indexText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  optionText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: isCorrect ? AppColors.emeraldGreen : AppColors.crimsonRed,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 60 * index)).fadeIn(duration: 250.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildQuizCompleted(int total) {
    final percentage = total > 0 ? (_score / total * 100).round() : 0;
    final isExcellent = percentage >= 80;
    final isGood = percentage >= 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy animation
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: isExcellent
                    ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFF5E27A)])
                    : isGood
                        ? const LinearGradient(colors: [AppColors.emeraldGreen, AppColors.emeraldLight])
                        : const LinearGradient(colors: [AppColors.sapphireBlue, Color(0xFF60A5FA)]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isExcellent ? AppColors.accentGold : AppColors.emeraldGreen).withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 48),
            ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 800.ms),

            const SizedBox(height: 24),

            Text(
              isExcellent ? '🎉 Outstanding!' : isGood ? '👍 Well Done!' : '📖 Keep Practicing!',
              style: AppTypography.fontHeading(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryDark,
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3, end: 0),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$_score',
                        style: AppTypography.fontHeading(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryNavy,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Text(
                          '/ $total',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$percentage% Accuracy',
                    style: GoogleFonts.inter(
                      color: isExcellent
                          ? AppColors.accentGold
                          : isGood
                              ? AppColors.emeraldGreen
                              : AppColors.sapphireBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn().scale(),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(mcqListProvider);
                setState(() {
                  _mcqIndex = 0;
                  _score = 0;
                  _submittedAnswer = false;
                  _selectedOptionIndex = -1;
                });
                _startTimer();
              },
              icon: const Icon(Icons.shuffle_rounded),
              label: const Text('Try Again with New Questions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _TimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 3;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_TimerPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
