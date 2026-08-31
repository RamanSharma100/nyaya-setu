import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/huggingface_mcq_client.dart';
import '../../core/storage/hive_service.dart';
import '../../shared/models/mcq.dart';
import '../../shared/widgets/flashcard_swipe_widget.dart';

final huggingFaceClientProvider = Provider((ref) => HuggingFaceLegalMCQClient());

final mcqListProvider = FutureProvider<List<MCQ>>((ref) async {
  final client = ref.read(huggingFaceClientProvider);
  return client.fetchLegalMCQs();
});

class PrelimsScreen extends ConsumerStatefulWidget {
  const PrelimsScreen({super.key});

  @override
  ConsumerState<PrelimsScreen> createState() => _PrelimsScreenState();
}

class _PrelimsScreenState extends ConsumerState<PrelimsScreen> with SingleTickerProviderStateMixin {
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
    setState(() {
      _submittedAnswer = true;
    });
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
      appBar: AppBar(
        title: const Text('Prelims Deck & Timed Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_search),
            tooltip: 'Exam Concept Search',
            onPressed: () => context.push('/concept_search'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Shuffle Questions & Restart',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGold,
          labelColor: AppColors.accentGold,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.style), text: 'Spaced Flashcards'),
            Tab(icon: Icon(Icons.timer), text: 'High-Yield MCQ Quiz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 90.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FlashcardSwipeWidget(
                    flashcards: _sampleCards,
                    onSwipe: (card, mastered) {
                      HiveService.updateFlashcardStatus(card.id, mastered ? 'mastered' : 'review');
                    },
                  ),
                ],
              ),
            ),
          ),
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
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('Failed to load MCQs: $err'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.refresh(mcqListProvider),
                    child: const Text('Retry Fetching OpenNYAI MCQs'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimedMCQQuiz(List<MCQ> mcqs) {
    if (mcqs.isEmpty) {
      return const Center(child: Text('No MCQs returned from live dataset endpoint.'));
    }

    final filteredMcqs = _selectedSubjectFilter == 'All'
        ? mcqs
        : mcqs.where((m) => m.subject == _selectedSubjectFilter).toList();

    final activeList = filteredMcqs.isEmpty ? mcqs : filteredMcqs;

    if (_mcqIndex >= activeList.length) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: AppColors.accentGold, size: 72),
              const SizedBox(height: 16),
              const Text('Quiz Completed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Your Score: $_score / ${activeList.length}',
                style: const TextStyle(fontSize: 20, color: AppColors.emeraldGreen, fontWeight: FontWeight.bold),
              ),
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
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffle & Retake Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentMCQ = activeList[_mcqIndex];
    final filterOptions = ['All', 'Criminal Law', 'Procedure', 'Evidence', 'Civil Law', 'Constitutional Law'];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 90.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterOptions.map((filter) {
                final isSelected = _selectedSubjectFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(filter, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.primaryNavy)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryNavy,
                    backgroundColor: Colors.grey.shade200,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSubjectFilter = filter;
                          _mcqIndex = 0;
                          _score = 0;
                          _submittedAnswer = false;
                          _selectedOptionIndex = -1;
                        });
                        _startTimer();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryNavy, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${currentMCQ.stateExam} (${currentMCQ.subject})',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, color: AppColors.crimsonRed, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$_quizTimeRemaining s',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.crimsonRed,
                      fontFamily: 'Monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_mcqIndex + 1} of ${activeList.length}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  currentMCQ.question,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(currentMCQ.options.length, (index) {
            final optionText = currentMCQ.options[index];
            final isSelected = _selectedOptionIndex == index;
            final isCorrect = currentMCQ.correctIndex == index;

            Color optionBg = Theme.of(context).cardColor;
            Color borderColor = Colors.grey.shade300;

            if (_submittedAnswer) {
              if (isCorrect) {
                optionBg = AppColors.diffAddedBg;
                borderColor = Colors.green;
              } else if (isSelected) {
                optionBg = AppColors.diffRemovedBg;
                borderColor = Colors.red;
              }
            } else if (isSelected) {
              borderColor = AppColors.primaryNavy;
            }

            return GestureDetector(
              onTap: _submittedAnswer
                  ? null
                  : () {
                      setState(() {
                        _selectedOptionIndex = index;
                      });
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: optionBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isSelected ? AppColors.primaryNavy : Colors.grey.shade200,
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        optionText,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          if (!_submittedAnswer) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedOptionIndex != -1 ? _submitAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Answer'),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primaryNavy),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Statutory Explanation (${currentMCQ.sectionRef})',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(currentMCQ.explanation, style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedOptionIndex == currentMCQ.correctIndex) {
                    _score++;
                  }
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
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Next Question ➔'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
