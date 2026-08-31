import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FlashcardItem {
  final String id;
  final String actName;
  final String sectionNumber;
  final String title;
  final String keyDetails;
  final String punishmentOrTerm;

  FlashcardItem({
    required this.id,
    required this.actName,
    required this.sectionNumber,
    required this.title,
    required this.keyDetails,
    required this.punishmentOrTerm,
  });
}

class FlashcardSwipeWidget extends StatefulWidget {
  final List<FlashcardItem> flashcards;
  final Function(FlashcardItem card, bool mastered) onSwipe;

  const FlashcardSwipeWidget({
    super.key,
    required this.flashcards,
    required this.onSwipe,
  });

  @override
  State<FlashcardSwipeWidget> createState() => _FlashcardSwipeWidgetState();
}

class _FlashcardSwipeWidgetState extends State<FlashcardSwipeWidget> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  Offset _dragOffset = Offset.zero;

  void _handleSwipe(bool mastered) {
    if (_currentIndex < widget.flashcards.length) {
      widget.onSwipe(widget.flashcards[_currentIndex], mastered);
      setState(() {
        _currentIndex++;
        _showAnswer = false;
        _dragOffset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.flashcards.length) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.emeraldGreen, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Deck Completed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have reviewed all available flashcards in this set.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                  _showAnswer = false;
                  _dragOffset = Offset.zero;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Restart Flashcards'),
            ),
          ],
        ),
      );
    }

    final card = widget.flashcards[_currentIndex];
    final progressText = '${_currentIndex + 1} / ${widget.flashcards.length}';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Flashcard Deck ($progressText)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy),
            ),
            const Row(
              children: [
                Icon(Icons.swipe_left, color: Colors.red, size: 18),
                Text(' Review  ', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                Icon(Icons.swipe_right, color: Colors.green, size: 18),
                Text(' Mastered', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dragOffset += Offset(details.delta.dx, 0);
            });
          },
          onHorizontalDragEnd: (details) {
            if (_dragOffset.dx > 80 || details.velocity.pixelsPerSecond.dx > 300) {
              _handleSwipe(true);
            } else if (_dragOffset.dx < -80 || details.velocity.pixelsPerSecond.dx < -300) {
              _handleSwipe(false);
            } else {
              setState(() => _dragOffset = Offset.zero);
            }
          },
          onTap: () => setState(() => _showAnswer = !_showAnswer),
          child: Transform.translate(
            offset: _dragOffset,
            child: Transform.rotate(
              angle: _dragOffset.dx / 1000,
              child: Container(
                height: 280,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _dragOffset.dx > 40
                        ? [Colors.green.shade700, Colors.green.shade900]
                        : _dragOffset.dx < -40
                            ? [Colors.red.shade700, Colors.red.shade900]
                            : [AppColors.primaryNavy, AppColors.secondaryNavy],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            card.actName,
                            style: const TextStyle(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Icon(Icons.touch_app, color: Colors.white60, size: 20),
                      ],
                    ),
                    if (!_showAnswer) ...[
                      Column(
                        children: [
                          Text(
                            card.sectionNumber,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            card.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Tap card to reveal statutory terms & penalties',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ] else ...[
                      Column(
                        children: [
                          Text(
                            'Term / Punishment:',
                            style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.punishmentOrTerm,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGoldLight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            card.keyDetails,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
                          ),
                        ],
                      ),
                      const Text(
                        'Swipe Right (Mastered) or Left (Review)',
                        style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              onPressed: () => _handleSwipe(false),
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('Needs Review', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _handleSwipe(true),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Mastered'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
