import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PomodoroTimerWidget extends StatefulWidget {
  const PomodoroTimerWidget({super.key});

  @override
  State<PomodoroTimerWidget> createState() => _PomodoroTimerWidgetState();
}

class _PomodoroTimerWidgetState extends State<PomodoroTimerWidget> {
  static const int workDuration = 25 * 60;
  static const int breakDuration = 5 * 60;

  int _secondsRemaining = workDuration;
  bool _isRunning = false;
  bool _isWorkMode = true;
  Timer? _timer;
  int _sessionsCompleted = 0;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          _switchMode();
        }
      });
    }
  }

  void _switchMode() {
    setState(() {
      _isRunning = false;
      if (_isWorkMode) {
        _sessionsCompleted++;
        _isWorkMode = false;
        _secondsRemaining = breakDuration;
      } else {
        _isWorkMode = true;
        _secondsRemaining = workDuration;
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isWorkMode = true;
      _secondsRemaining = workDuration;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = _isWorkMode ? workDuration : breakDuration;
    final progress = 1.0 - (_secondsRemaining / totalDuration);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isWorkMode
              ? [AppColors.primaryNavy, AppColors.secondaryNavy]
              : [const Color(0xFF064E3B), const Color(0xFF047857)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _isWorkMode ? Icons.self_improvement : Icons.coffee,
                    color: AppColors.accentGold,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isWorkMode ? 'Judicial Study Focus (25m)' : 'Short Rest Break (5m)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Sessions: $_sessionsCompleted',
                  style: const TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isWorkMode ? AppColors.accentGold : AppColors.emeraldGreen,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_secondsRemaining),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isRunning ? 'FOCUSING' : 'PAUSED',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _toggleTimer,
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(_isRunning ? 'Pause' : 'Start Focus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh, color: Colors.white70),
                tooltip: 'Reset Timer',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
