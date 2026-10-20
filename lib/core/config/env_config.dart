import '../storage/hive_service.dart';

class EnvConfig {
  static String get indianKanoonApiKey {
    final custom = HiveService.getCustomApiKey('INDIAN_KANOON_API_KEY');
    if (custom.isNotEmpty) return custom;
    return const String.fromEnvironment('INDIAN_KANOON_API_KEY');
  }

  static const String indianKanoonBaseUrl = String.fromEnvironment(
    'INDIAN_KANOON_BASE_URL',
    defaultValue: 'https://api.indiankanoon.org',
  );

  static String get huggingFaceToken {
    final custom = HiveService.getCustomApiKey('HUGGINGFACE_API_TOKEN');
    if (custom.isNotEmpty) return custom;
    return const String.fromEnvironment('HUGGINGFACE_API_TOKEN');
  }

  static String get geminiApiKey {
    final custom = HiveService.getCustomApiKey('GEMINI_API_KEY');
    if (custom.isNotEmpty) return custom;
    return const String.fromEnvironment('GEMINI_API_KEY');
  }

  static const String huggingFaceBaseUrl = String.fromEnvironment(
    'HUGGINGFACE_DATASET_URL',
    defaultValue: 'https://datasets-server.huggingface.co',
  );

  static const String liveLawRssUrl = String.fromEnvironment(
    'LIVELAW_RSS_URL',
    defaultValue: 'https://news.google.com/rss/search?q=Supreme+Court+India+law&hl=en-IN&gl=IN&ceid=IN:en',
  );

  static const String barAndBenchRssUrl = String.fromEnvironment(
    'BAR_AND_BENCH_RSS_URL',
    defaultValue: 'https://news.google.com/rss/search?q=Supreme+Court+India+law&hl=en-IN&gl=IN&ceid=IN:en',
  );

  static const String indiaCodeBaseUrl = String.fromEnvironment(
    'INDIA_CODE_BASE_URL',
    defaultValue: 'https://www.indiacode.nic.in',
  );

  static const String googleClientIdWeb = String.fromEnvironment(
    'GOOGLE_CLIENT_ID_WEB',
    defaultValue: '',
  );

  static const String youtubeApiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
    defaultValue: '',
  );

  // --- PostHog Analytics Telemetry ---
  static String get posthogApiKey {
    final custom = HiveService.getCustomApiKey('POSTHOG_API_KEY');
    if (custom.isNotEmpty) return custom;
    return const String.fromEnvironment('POSTHOG_API_KEY');
  }

  static String get posthogHost {
    final custom = HiveService.getCustomApiKey('POSTHOG_HOST');
    if (custom.isNotEmpty) return custom;
    return const String.fromEnvironment(
      'POSTHOG_HOST',
      defaultValue: 'https://us.i.posthog.com',
    );
  }

  // --- Login Email Notification Webhook / Endpoint ---
  static String get loginAlertWebhook {
    final custom = HiveService.getCustomApiKey('LOGIN_ALERT_WEBHOOK');
    if (custom.isNotEmpty) return custom;
    return const String.fromEnvironment('LOGIN_ALERT_WEBHOOK');
  }

  static String get loginAlertEmail {
    final custom = HiveService.getCustomApiKey('LOGIN_ALERT_EMAIL');
    if (custom.isNotEmpty) return custom;
    return const String.fromEnvironment(
      'LOGIN_ALERT_EMAIL',
      defaultValue: 'techraman100@gmail.com',
    );
  }

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
}

