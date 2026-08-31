class Sanitizer {
  static String sanitizeHtml(String input) {
    if (input.isEmpty) return '';

    String cleaned = input
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
        .replaceAll(RegExp(r'<script\b[^<]*>(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<(iframe|object|embed|applet|style)\b[^<]*>(?:(?!<\/\1>)<[^<]*)*<\/\1>', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bon[a-z]+\s*=\s*("[^"]*"|' r"'[^']*'" r'|[^\s>]+)', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript\s*:', caseSensitive: false), '')
        .replaceAll(RegExp(r'data\s*:\s*text\/html', caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned;
  }

  static String sanitizeSearchQuery(String query) {
    if (query.isEmpty) return '';

    String clean = query
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        .replaceAll(RegExp(r'[<>{}\[\]\\]'), '')
        .trim();

    return clean.length > 100 ? clean.substring(0, 100) : clean;
  }

  static String sanitizeUserInput(String text) {
    if (text.isEmpty) return '';

    return text
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
        .trim();
  }
}
