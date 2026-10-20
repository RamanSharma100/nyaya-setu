import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class AudioBareActItem {
  final String actTitle;
  final String sectionNumber;
  final String sectionTitle;
  final String statutoryText;
  final String judicialSummary;
  final String landmarkRatio;
  final int durationSeconds;

  const AudioBareActItem({
    required this.actTitle,
    required this.sectionNumber,
    required this.sectionTitle,
    required this.statutoryText,
    required this.judicialSummary,
    required this.landmarkRatio,
    this.durationSeconds = 180,
  });
}

class AudioBareActsModal extends StatefulWidget {
  final String? initialAct;
  final String? initialSection;

  const AudioBareActsModal({
    super.key,
    this.initialAct,
    this.initialSection,
  });

  static void show(BuildContext context, {String? act, String? section}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AudioBareActsModal(initialAct: act, initialSection: section),
    );
  }

  @override
  State<AudioBareActsModal> createState() => _AudioBareActsModalState();
}

class _AudioBareActsModalState extends State<AudioBareActsModal> with SingleTickerProviderStateMixin {
  late final List<AudioBareActItem> _playlist;
  late int _currentIndex;
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _playbackSpeed = 1.0;
  String _audioMode = 'Summary'; // 'Statute', 'Summary', 'Ratio'
  Timer? _playbackTimer;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _playlist = _getAudioPlaylist();
    _currentIndex = 0;
    if (widget.initialSection != null) {
      final found = _playlist.indexWhere(
        (i) => i.sectionNumber.toLowerCase() == widget.initialSection!.toLowerCase(),
      );
      if (found != -1) _currentIndex = found;
    }

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startTimer();
      } else {
        _playbackTimer?.cancel();
      }
    });
  }

  void _startTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) return;
      setState(() {
        final currentItem = _playlist[_currentIndex];
        final increment = 0.2 * _playbackSpeed;
        if (_currentPosition + increment >= currentItem.durationSeconds) {
          _currentPosition = 0.0;
          if (_currentIndex < _playlist.length - 1) {
            _currentIndex++;
          } else {
            _isPlaying = false;
            _playbackTimer?.cancel();
          }
        } else {
          _currentPosition += increment;
        }
      });
    });
  }

  void _seekRelative(int seconds) {
    setState(() {
      final maxDur = _playlist[_currentIndex].durationSeconds.toDouble();
      _currentPosition = (_currentPosition + seconds).clamp(0.0, maxDur);
    });
  }

  void _changeSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.25;
      } else if (_playbackSpeed == 1.25) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else if (_playbackSpeed == 2.0) {
        _playbackSpeed = 0.75;
      } else {
        _playbackSpeed = 1.0;
      }
    });
  }

  String _formatTime(double sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = ((sec % 60).toInt()).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final item = _playlist[_currentIndex];
    final activeText = _audioMode == 'Statute'
        ? item.statutoryText
        : _audioMode == 'Summary'
            ? item.judicialSummary
            : item.landmarkRatio;

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
                    color: AppColors.sapphireBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.headphones_rounded, color: Colors.lightBlueAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audio Bare Acts & Ratios',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hands-free PCS-J Section Summarizer',
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  // Current Playing Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.actTitle,
                                style: GoogleFonts.inter(
                                  color: AppColors.accentGold,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Sec ${item.sectionNumber}',
                                style: GoogleFonts.firaCode(
                                  color: Colors.white70,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.sectionTitle,
                          style: GoogleFonts.lora(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Animated Sound Wave
                        Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(24, (i) {
                              return AnimatedBuilder(
                                animation: _waveController,
                                builder: (context, _) {
                                  final wave = _isPlaying
                                      ? (0.2 + 0.8 * ((i % 5 + 1) / 5.0) * ((_waveController.value + (i * 0.05)) % 1.0))
                                      : 0.2;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 1.8),
                                    width: 3.5,
                                    height: (30 * wave).clamp(4.0, 30.0),
                                    decoration: BoxDecoration(
                                      color: _isPlaying ? AppColors.accentGold : Colors.white24,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Mode Selector Pills
                        Row(
                          children: [
                            _buildModeChip('Summary', Icons.auto_stories_rounded),
                            const SizedBox(width: 8),
                            _buildModeChip('Statute', Icons.gavel_rounded),
                            const SizedBox(width: 8),
                            _buildModeChip('Ratio', Icons.account_balance_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress Bar & Controls
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbColor: AppColors.accentGold,
                          activeTrackColor: AppColors.accentGold,
                          inactiveTrackColor: Colors.white12,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        ),
                        child: Slider(
                          value: _currentPosition.clamp(0.0, item.durationSeconds.toDouble()),
                          max: item.durationSeconds.toDouble(),
                          onChanged: (val) {
                            setState(() => _currentPosition = val);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(_currentPosition),
                              style: GoogleFonts.firaCode(color: Colors.white60, fontSize: 11),
                            ),
                            Text(
                              _formatTime(item.durationSeconds.toDouble()),
                              style: GoogleFonts.firaCode(color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Player Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10_rounded, color: Colors.white70, size: 28),
                            tooltip: 'Rewind 10s',
                            onPressed: () => _seekRelative(-10),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 32),
                            onPressed: _currentIndex > 0
                                ? () {
                                    setState(() {
                                      _currentIndex--;
                                      _currentPosition = 0.0;
                                    });
                                  }
                                : null,
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [AppColors.accentGold, Color(0xFFF59E0B)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x66F59E0B),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: AppColors.primaryNavy,
                                size: 34,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
                            onPressed: _currentIndex < _playlist.length - 1
                                ? () {
                                    setState(() {
                                      _currentIndex++;
                                      _currentPosition = 0.0;
                                    });
                                  }
                                : null,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.forward_10_rounded, color: Colors.white70, size: 28),
                            tooltip: 'Forward 10s',
                            onPressed: () => _seekRelative(10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Speed button
                      InkWell(
                        onTap: _changeSpeed,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_playbackSpeed}x Speed',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Synchronized Audio Transcript View
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notes_rounded, color: AppColors.accentGold, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Live Audio Narration Transcript:',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          activeText,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13.5,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section Playlist Picker
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Audio Playlist (${_playlist.length} Key Provisions):',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_playlist.length, (idx) {
                    final p = _playlist[idx];
                    final isCur = idx == _currentIndex;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: isCur ? AppColors.accentGold.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isCur ? AppColors.accentGold : Colors.white12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: isCur ? AppColors.accentGold : Colors.white12,
                          child: Icon(
                            isCur && _isPlaying ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                            size: 14,
                            color: isCur ? AppColors.primaryNavy : Colors.white70,
                          ),
                        ),
                        title: Text(
                          '${p.actTitle} • Sec ${p.sectionNumber}',
                          style: GoogleFonts.inter(
                            color: isCur ? AppColors.accentGold : Colors.white,
                            fontWeight: isCur ? FontWeight.bold : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                        subtitle: Text(
                          p.sectionTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                        ),
                        trailing: Text(
                          _formatTime(p.durationSeconds.toDouble()),
                          style: GoogleFonts.firaCode(color: Colors.white38, fontSize: 10.5),
                        ),
                        onTap: () {
                          setState(() {
                            _currentIndex = idx;
                            _currentPosition = 0.0;
                            _isPlaying = true;
                          });
                          _startTimer();
                        },
                      ),
                    ),
                  );
                }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String mode, IconData icon) {
    final isSelected = _audioMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _audioMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentGold : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.accentGold : Colors.white12,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? AppColors.primaryNavy : Colors.white70,
              ),
              const SizedBox(width: 5),
              Text(
                mode,
                style: GoogleFonts.inter(
                  color: isSelected ? AppColors.primaryNavy : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<AudioBareActItem> _getAudioPlaylist() {
    return const [
      AudioBareActItem(
        actTitle: 'BNS 2023',
        sectionNumber: '103',
        sectionTitle: 'Punishment for Murder (Replaces Sec 302 IPC)',
        statutoryText:
            'Section 103 BNS 2023: Whoever commits murder shall be punished with death or imprisonment for life, and shall also be liable to fine. Sub-section (2) specifically introduces stringent capital penalties for mob lynching on grounds of race, caste, or community.',
        judicialSummary:
            'BNS Section 103 re-codifies IPC Section 302 with a landmark addition: Sub-section (2) introduces a specific statutory offence and capital sentence for mob lynching. In judicial exams, highlight how State of MP v. Ramji Lal principles have now received direct legislative codification.',
        landmarkRatio:
            'Bachan Singh v. State of Punjab (1980) 2 SCC 684: The "Rarest of Rare" doctrine governs capital sentencing under Section 103 BNS. Death penalty can only be awarded when the alternative option of life imprisonment is unquestionably foreclosed.',
        durationSeconds: 165,
      ),
      AudioBareActItem(
        actTitle: 'BNSS 2023',
        sectionNumber: '482',
        sectionTitle: 'Direction for Grant of Bail to Person Apprehending Arrest (Replaces Sec 438 CrPC)',
        statutoryText:
            'Section 482 BNSS 2023 provides direction for anticipatory bail where any person has reason to believe that he may be arrested on an accusation of having committed a non-bailable offence. The High Court or Court of Session may direct his release on bail.',
        judicialSummary:
            'Anticipatory bail under BNSS 482 is a shield against harassment and malicious prosecution, rooted in Article 21. Unlike CrPC 438, BNSS incorporates stringent procedural accountability for police notices under Section 35 before arrest.',
        landmarkRatio:
            'Sushila Aggarwal v. State (NCT of Delhi) (2020) 5 SCC 1: Anticipatory bail should not ordinarily be limited to a fixed time period. It continues till the end of the trial unless special circumstances warrant revocation.',
        durationSeconds: 195,
      ),
      AudioBareActItem(
        actTitle: 'BSA 2023',
        sectionNumber: '61',
        sectionTitle: 'Admissibility of Electronic Records (Replaces Sec 65B IEA)',
        statutoryText:
            'Section 61 BSA 2023 governs electronic evidence. Information contained in an electronic record produced by a computer or semiconductor storage is deemed a document and admissible without further proof of original if statutory certificate criteria are met.',
        judicialSummary:
            'BSA 2023 elevates electronic evidence to parity with primary statutory records. Section 61 and 63 overhaul the contentious certificate requirements of former Section 65B of the Indian Evidence Act.',
        landmarkRatio:
            'Arjun Panditrao Khotkar v. Kailash Kushanrao Gorantyal (2020) 7 SCC 1: Supreme Court settled that production of an electronic certificate is a mandatory condition precedent for admissibility of secondary electronic records.',
        durationSeconds: 180,
      ),
      AudioBareActItem(
        actTitle: 'Contract Act',
        sectionNumber: '56',
        sectionTitle: 'Doctrine of Frustration & Impossibility',
        statutoryText:
            'Section 56 ICA: An agreement to do an act impossible in itself is void. A contract to do an act which, after the contract is made, becomes impossible or by reason of some event unlawful, becomes void when the act becomes impossible or unlawful.',
        judicialSummary:
            'Codifies impossibility and frustration. Does not rely on implied term theory of English law. Discharge under Sec 56 triggers mandatory restitution under Sec 65.',
        landmarkRatio:
            'Satyabrata Ghose v. Mugneeram Bangur & Co. (1954) SCR 310: Impossibility under Sec 56 is not confined to physical or literal impossibility. It includes untoward supervening events upsetting the very foundational basis of the contract.',
        durationSeconds: 150,
      ),
      AudioBareActItem(
        actTitle: 'Property Law (TPA)',
        sectionNumber: '52',
        sectionTitle: 'Doctrine of Lis Pendens',
        statutoryText:
            'Section 52 TPA: During the pendency in any Court of any suit or proceeding which is not collusive and in which any right to immovable property is directly and specifically in question, the property cannot be transferred or otherwise dealt with by any party so as to affect the rights of any other party.',
        judicialSummary:
            'Lis Pendens is based on the equitable maxim "Ut lite pendente nihil innovetur" (During litigation, nothing new should be introduced). Alienation is not void, but subordinated to the final court decree.',
        landmarkRatio:
            'Dev Raj Dogra v. Gyan Chand Jain (1981) 2 SCC 675: Transferee pendente lite is bound by the result of the litigation, stepping exactly into the shoes of the transferor vendor.',
        durationSeconds: 170,
      ),
    ];
  }
}
