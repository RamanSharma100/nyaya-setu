import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final geminiAiServiceProvider = Provider((ref) => GeminiAiService());

class GeminiAiMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  GeminiAiMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class GeminiAiService {
  GeminiAiService({Dio? dio});

  Future<String> generateJudicialResponse(String userPrompt) async {
    final cleanPrompt = userPrompt.trim();
    if (cleanPrompt.isEmpty) return 'Please type or speak your legal question.';

    return "✨ **NyayaAI Judicial Assistant - Coming Soon!**\n\n"
        "Live AI judicial synthesis for PCS-J aspirants is currently under development. Stay tuned for upcoming feature updates!";
  }
}
