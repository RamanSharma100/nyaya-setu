import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/gemini_ai_service.dart';
import '../../shared/widgets/web_preview_screen.dart';

class GeminiAiScreen extends ConsumerStatefulWidget {
  const GeminiAiScreen({super.key});

  @override
  ConsumerState<GeminiAiScreen> createState() => _GeminiAiScreenState();
}

class _GeminiAiScreenState extends ConsumerState<GeminiAiScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<GeminiAiMessage> _messages = [
    GeminiAiMessage(
      text:
          "Namaste! I am **NyayaAI Judicial Assistant**.\n\n✨ **Live AI Chat & Voice Assistant - Coming Soon!**\n\nOur full AI judicial synthesis mentor for PCS-J aspirants is currently under development. Stay tuned for upcoming feature updates!",
      isUser: false,
    ),
  ];

  bool _isLoading = false;
  bool _isVoiceListening = false;
  bool _isVoiceSpeaking = false;
  String? _speakingMessageText;
  Timer? _speechTimer;

  final List<String> _presetPrompts = [
    'BNS 103 Mob Lynching penalty & IPC 302 diff',
    'BNSS 173 Zero FIR and e-FIR 3-day signature rule',
    'BSA 63 Electronic record certificate under 63(4)',
    'CPC 11 Res Judicata vs Res Sub-Judice under Sec 10',
    'Art 21 Right to Privacy Puttaswamy ratio',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _speechTimer?.cancel();
    super.dispose();
  }

  void _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading) return;

    _textController.clear();
    setState(() {
      _messages.add(GeminiAiMessage(text: query, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    final geminiService = ref.read(geminiAiServiceProvider);
    final responseText = await geminiService.generateJudicialResponse(query);

    if (!mounted) return;

    setState(() {
      _messages.add(GeminiAiMessage(text: responseText, isUser: false));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _toggleVoiceListening() {
    if (_isVoiceListening) {
      _speechTimer?.cancel();
      setState(() => _isVoiceListening = false);
    } else {
      setState(() {
        _isVoiceListening = true;
        _textController.text = "Listening...";
      });

      _speechTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          _isVoiceListening = false;
          _textController.text = "What is the penalty for Mob Lynching under BNS Section 103?";
        });
      });
    }
  }

  void _speakResponse(String text) {
    if (_isVoiceSpeaking && _speakingMessageText == text) {
      setState(() {
        _isVoiceSpeaking = false;
        _speakingMessageText = null;
      });
      return;
    }

    setState(() {
      _isVoiceSpeaking = true;
      _speakingMessageText = text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.volume_up, color: AppColors.accentGold),
            SizedBox(width: 8),
            Text('NyayaAI Voice Mode: Reading legal response aloud...'),
          ],
        ),
        duration: Duration(seconds: 4),
      ),
    );

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _isVoiceSpeaking = false;
          _speakingMessageText = null;
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.accentGold, size: 20),
            const SizedBox(width: 8),
            Text('NyayaAI Voice Assistant', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.emeraldGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.emeraldGreen),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.emeraldGreen, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text('VOICE ACTIVE', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.primaryNavy,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _presetPrompts.map((prompt) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      side: BorderSide(color: AppColors.accentGold.withValues(alpha: 0.5)),
                      label: Text(prompt, style: GoogleFonts.inter(color: AppColors.accentGold, fontSize: 12)),
                      onPressed: () => _sendMessage(prompt),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGold)),
                  const SizedBox(width: 8),
                  Text('NyayaAI is analyzing statutory provisions...', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          _buildVoiceInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(GeminiAiMessage msg) {
    final isSpeakingThis = _isVoiceSpeaking && _speakingMessageText == msg.text;

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.primaryNavy : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: msg.isUser ? Radius.zero : const Radius.circular(16),
          ),
          border: msg.isUser ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      msg.isUser ? Icons.person : Icons.auto_awesome,
                      size: 16,
                      color: msg.isUser ? AppColors.accentGold : AppColors.primaryNavy,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      msg.isUser ? 'You' : 'NyayaAI Assistant',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: msg.isUser ? AppColors.accentGold : AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
                if (!msg.isUser)
                  IconButton(
                    icon: Icon(
                      isSpeakingThis ? Icons.volume_up : Icons.volume_mute,
                      color: isSpeakingThis ? AppColors.accentGold : Colors.grey,
                      size: 20,
                    ),
                    tooltip: 'Listen Audio Readout',
                    onPressed: () => _speakResponse(msg.text),
                  ),
              ],
            ),
            const Divider(height: 12),
            MarkdownBody(
              data: msg.text,
              selectable: true,
              onTapLink: (text, href, title) {
                if (href != null && href.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebPreviewScreen(
                        initialUrl: href,
                        title: text.isNotEmpty ? text : 'NyayaAI Web Reference',
                      ),
                    ),
                  );
                }
              },
              styleSheet: MarkdownStyleSheet(
                a: GoogleFonts.inter(
                  color: Colors.blue.shade700,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
                p: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: msg.isUser ? Colors.white : AppColors.textPrimaryDark,
                ),
                strong: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: msg.isUser ? AppColors.accentGold : AppColors.primaryNavy,
                ),
                h1: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: msg.isUser ? Colors.white : AppColors.primaryNavy,
                ),
                h2: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: msg.isUser ? Colors.white : AppColors.primaryNavy,
                ),
                listBullet: GoogleFonts.inter(
                  fontSize: 14,
                  color: msg.isUser ? AppColors.accentGold : AppColors.primaryNavy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleVoiceListening,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isVoiceListening ? AppColors.crimsonRed : AppColors.accentGold,
                shape: BoxShape.circle,
                boxShadow: _isVoiceListening
                    ? [BoxShadow(color: AppColors.crimsonRed.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 4)]
                    : [],
              ),
              child: Icon(
                _isVoiceListening ? Icons.mic : Icons.mic_none,
                color: _isVoiceListening ? Colors.white : AppColors.primaryNavy,
                size: 24,
              ),
            ).animate(target: _isVoiceListening ? 1.0 : 0.0).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.15, 1.15),
                  duration: 600.ms,
                ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _sendMessage,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: _isVoiceListening ? 'Listening to speech input...' : 'Ask NyayaAI or tap Mic for Voice...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primaryNavy),
            onPressed: () => _sendMessage(_textController.text),
          ),
        ],
      ),
    );
  }
}
