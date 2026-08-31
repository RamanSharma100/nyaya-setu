import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/storage/hive_service.dart';

class MainsQuestion {
  final String id;
  final String subject;
  final int marks;
  final String questionText;
  final String modelAnswerFacts;
  final String modelAnswerIssues;
  final String modelAnswerSections;
  final String modelAnswerRatios;
  final String modelAnswerDecision;

  MainsQuestion({
    required this.id,
    required this.subject,
    required this.marks,
    required this.questionText,
    required this.modelAnswerFacts,
    required this.modelAnswerIssues,
    required this.modelAnswerSections,
    required this.modelAnswerRatios,
    required this.modelAnswerDecision,
  });
}

class MainsScreen extends ConsumerStatefulWidget {
  const MainsScreen({super.key});

  @override
  ConsumerState<MainsScreen> createState() => _MainsScreenState();
}

class _MainsScreenState extends ConsumerState<MainsScreen> {
  final TextEditingController _draftController = TextEditingController();
  bool _showModelAnswer = false;
  int _selectedQuestionIndex = 0;

  Timer? _examTimer;
  int _timerSeconds = 45 * 60;
  bool _isTimerRunning = false;

  final List<MainsQuestion> _questions = [
    MainsQuestion(
      id: 'mains_01',
      subject: 'Criminal Law (BNS & BNSS)',
      marks: 20,
      questionText:
          'A group of five persons armed with lathis attacked X on the suspicion of cattle theft, resulting in X\'s death. Discuss the penal liability of the accused persons under Bharatiya Nyaya Sanhita (BNS), 2023. Highlight how the legal position under BNS Section 103 differs from Section 302 of repealed IPC 1860.',
      modelAnswerFacts:
          'A five-person group armed with weapons assaulted X on suspicion of theft, causing fatal injuries on the spot.',
      modelAnswerIssues:
          'Whether all five accused are liable for Murder and Mob Lynching under BNS Section 103(2) and Section 3(5) joint liability.',
      modelAnswerSections:
          'BNS Section 103(1) [Murder], BNS Section 103(2) [Mob Lynching by 5+ persons], BNS Section 3(5) [Common Intention].',
      modelAnswerRatios:
          '1. Tehseen S. Poonawalla v. Union of India (2018) 9 SCC 501 (Mandatory anti-lynching guidelines).\n2. Bachan Singh v. State of Punjab (1980) 2 SCC 684.',
      modelAnswerDecision:
          'The accused are guilty of murder under Section 103(2) BNS. Since 5 persons acted in concert on ground of suspicion, each member is punishable with Death or Life Imprisonment.',
    ),
    MainsQuestion(
      id: 'mains_02',
      subject: 'Constitutional Law',
      marks: 20,
      questionText:
          'Critically analyze the scope of Article 21 of the Constitution of India in light of Justice K.S. Puttaswamy (2017) judgment. Is the Right to Privacy absolute or subject to reasonable restrictions?',
      modelAnswerFacts:
          'Petitioner challenged mandatory collection of biometric data under Aadhaar claiming violation of personal autonomy.',
      modelAnswerIssues:
          'Whether Privacy is a fundamental right under Article 21 and what test applies to state restrictions.',
      modelAnswerSections:
          'Article 21 (Right to Life & Personal Liberty), Article 14, Article 19.',
      modelAnswerRatios:
          '1. Justice K.S. Puttaswamy v. Union of India (2017) 10 SCC 1 (9-Judge Bench).\n2. Maneka Gandhi v. Union of India (1978) 1 SCC 248.',
      modelAnswerDecision:
          'Right to Privacy is an intrinsic fundamental right under Article 21. However, it is not absolute and can be restricted by law satisfying the 3-fold proportionality test (Legitimate State Aim, Need/Necessity, Proportionality).',
    ),
    MainsQuestion(
      id: 'mains_03',
      subject: 'Procedure (BNSS 2023)',
      marks: 15,
      questionText:
          'Explain the statutory provisions governing Zero FIR and e-FIR under Section 173 of Bharatiya Nagarik Suraksha Sanhita (BNSS), 2023. What is the mandatory timeframe for signature verification on electronic FIRs?',
      modelAnswerFacts:
          'Informant lodged an electronic complaint regarding armed robbery outside territorial limits of the police station.',
      modelAnswerIssues:
          'Validity of Zero FIR registration regardless of jurisdiction and legal requirement of 3-day signature verification.',
      modelAnswerSections:
          'BNSS Section 173(1), BNSS Section 173 Proviso.',
      modelAnswerRatios:
          '1. Lalita Kumari v. Govt. of U.P. (2014) 2 SCC 1 (Mandatory registration of FIR in cognizable cases).\n2. State of Andhra Pradesh v. Punati Ramulu (1994).',
      modelAnswerDecision:
          'Registration of Zero FIR is mandatory under BNSS Section 173 regardless of jurisdiction. An e-FIR must be signed within 3 days to be formally taken on record.',
    ),
    MainsQuestion(
      id: 'mains_04',
      subject: 'Civil Law (CPC 1908)',
      marks: 20,
      questionText:
          'Distinguish between Res Judicata (Section 11 CPC) and Res Sub-Judice (Section 10 CPC). Explain the doctrine of Constructive Res Judicata under Explanation IV to Section 11.',
      modelAnswerFacts:
          'Plaintiff P filed a second suit on the same property title after failing to raise an available defence in former suit.',
      modelAnswerIssues:
          'Whether the second suit is barred by Constructive Res Judicata under Explanation IV to Section 11 CPC.',
      modelAnswerSections:
          'CPC Section 10 [Stay of Suit], CPC Section 11 [Res Judicata], Explanation IV.',
      modelAnswerRatios:
          '1. Daryao v. State of U.P. (1961) AIR SC 1457.\n2. Satyadhyan Ghosal v. Deorajin Debi (1960) AIR SC 941.',
      modelAnswerDecision:
          'Section 10 stays trial of pending suit; Section 11 bars trial of decided suit. Any ground which might and ought to have been made a ground of defence in former suit is barred by Constructive Res Judicata under Explanation IV.',
    ),
    MainsQuestion(
      id: 'mains_05',
      subject: 'Evidence Law (BSA 2023)',
      marks: 15,
      questionText:
          'Discuss the admissibility of electronic records under Section 63 of Bharatiya Sakshya Adhiniyam (BSA), 2023. Is the electronic certificate under Section 63(4) mandatory in all criminal trials?',
      modelAnswerFacts:
          'Prosecution relied on CCTV footage and WhatsApp text logs without producing an electronic certificate under BSA 63(4).',
      modelAnswerIssues:
          'Whether electronic records without a Section 63(4) certificate are admissible as secondary documentary evidence.',
      modelAnswerSections:
          'BSA Section 63(1), BSA Section 63(4), BSA Section 2.',
      modelAnswerRatios:
          '1. Arjun Panditrao Khotkar v. Kailash Kushanrao Gorantyal (2020) 7 SCC 1.\n2. Anvar P.V. v. P.K. Basheer (2014) 10 SCC 473.',
      modelAnswerDecision:
          'Electronic certificate under BSA Section 63(4) is mandatory whenever secondary electronic records are produced. In absence of certificate, CCTV and digital logs are completely inadmissible.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedDraft();
    });
  }

  void _loadSavedDraft() {
    try {
      if (_selectedQuestionIndex >= 0 && _selectedQuestionIndex < _questions.length) {
        final q = _questions[_selectedQuestionIndex];
        final saved = HiveService.getMainsDraft(q.id);
        if (mounted) {
          _draftController.text = saved;
        }
      }
    } catch (_) {}
  }

  void _switchQuestion(int newIndex) async {
    try {
      final currentQ = _questions[_selectedQuestionIndex];
      await HiveService.saveMainsDraft(currentQ.id, _draftController.text);
      if (mounted) {
        setState(() {
          _selectedQuestionIndex = newIndex;
          _showModelAnswer = false;
        });
        _loadSavedDraft();
      }
    } catch (_) {}
  }

  void _generateAiMainsQuestion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ NyayaAI Mains Question Generator & Live Evaluator - Coming Soon!'),
        backgroundColor: AppColors.primaryNavy,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _examTimer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      setState(() => _isTimerRunning = true);
      _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timerSeconds > 0) {
          setState(() => _timerSeconds--);
        } else {
          _examTimer?.cancel();
          setState(() => _isTimerRunning = false);
        }
      });
    }
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    _draftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_selectedQuestionIndex];
    final draftText = _draftController.text;
    final wordCount = draftText.trim().isEmpty ? 0 : draftText.trim().split(RegExp(r'\s+')).length;
    final charCount = draftText.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mains Answer Writing Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.accentGold),
            tooltip: 'Generate Fresh AI Mains Question',
            onPressed: _generateAiMainsQuestion,
          ),
          IconButton(
            icon: const Icon(Icons.manage_search),
            tooltip: 'Exam Concept Search',
            onPressed: () => context.push('/concept_search'),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Draft',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await HiveService.saveMainsDraft(currentQ.id, _draftController.text);
              messenger.showSnackBar(
                const SnackBar(content: Text('Mains draft saved to Hive storage!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...List.generate(_questions.length, (idx) {
                    final q = _questions[idx];
                    final isSelected = _selectedQuestionIndex == idx;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text('Q${idx + 1}: ${q.subject.split(' ')[0]}'),
                        selectedColor: AppColors.primaryNavy,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) => _switchQuestion(idx),
                      ),
                    );
                  }),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16, color: AppColors.accentGold),
                    label: Text('Generate AI Q', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryNavy)),
                    backgroundColor: AppColors.accentGold.withValues(alpha: 0.2),
                    onPressed: _generateAiMainsQuestion,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryNavy, AppColors.secondaryNavy],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.accentGold, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            'Q${_selectedQuestionIndex + 1} of ${_questions.length} • ${currentQ.subject} (${currentQ.marks} Marks)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _toggleTimer,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_isTimerRunning ? Icons.pause_circle : Icons.play_circle, color: AppColors.accentGoldLight),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimer(_timerSeconds),
                              style: GoogleFonts.firaCode(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentQ.questionText,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15, height: 1.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _selectedQuestionIndex > 0 ? () => _switchQuestion(_selectedQuestionIndex - 1) : null,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Prev / Skip'),
                ),
                OutlinedButton.icon(
                  onPressed: _selectedQuestionIndex < _questions.length - 1 ? () => _switchQuestion(_selectedQuestionIndex + 1) : null,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Next / Skip'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildCounterBadge('Words: $wordCount'),
                    const SizedBox(width: 8),
                    _buildCounterBadge('Chars: $charCount'),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _showModelAnswer = !_showModelAnswer),
                  icon: Icon(_showModelAnswer ? Icons.visibility_off : Icons.verified),
                  label: Text(_showModelAnswer ? 'Hide Rubric' : 'Model Answer Rubric'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showModelAnswer ? AppColors.crimsonRed : AppColors.emeraldGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _draftController,
              maxLines: 12,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.inter(fontSize: 15, height: 1.6),
              decoration: InputDecoration(
                hintText:
                    'Draft your judicial answer here following standard format:\n1. Brief Facts & Issues\n2. Applicable Statutory Provisions\n3. Landmark Supreme Court Ratio Decidendi\n4. Final Decision...',
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            if (_showModelAnswer) ...[
              Text('Model Answer & Evaluation Rubric', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              _buildRubricSection('1. Facts & Premise', currentQ.modelAnswerFacts, Colors.blue.shade50),
              _buildRubricSection('2. Frame of Issues', currentQ.modelAnswerIssues, Colors.purple.shade50),
              _buildRubricSection('3. Applicable Sections', currentQ.modelAnswerSections, Colors.amber.shade50),
              _buildRubricSection('4. Landmark Ratios Decidendi', currentQ.modelAnswerRatios, Colors.green.shade50),
              _buildRubricSection('5. Final Holding & Decision', currentQ.modelAnswerDecision, Colors.teal.shade50),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCounterBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
    );
  }

  Widget _buildRubricSection(String title, String content, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 14)),
          const SizedBox(height: 4),
          Text(content, style: GoogleFonts.inter(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
