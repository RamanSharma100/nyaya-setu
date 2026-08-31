class EnvConfig {
  static const String indianKanoonApiKey = String.fromEnvironment(
    'INDIAN_KANOON_API_KEY',
  );

  static const String indianKanoonBaseUrl = String.fromEnvironment(
    'INDIAN_KANOON_BASE_URL',
    defaultValue: 'https://api.indiankanoon.org',
  );

  static const String huggingFaceToken = String.fromEnvironment(
    'HUGGINGFACE_API_TOKEN',
  );

  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

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

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
}
