import 'package:flutter_test/flutter_test.dart';
import 'package:nyayasetu/core/utils/sanitizer.dart';

void main() {
  group('Sanitizer Unit Tests', () {
    test('sanitizeHtml removes script tags and inline event handlers', () {
      const malicious = '<script>alert("xss")</script><p onload="doEvil()">Hello <b>Legal</b> World</p>';
      final clean = Sanitizer.sanitizeHtml(malicious);

      expect(clean, contains('Hello Legal World'));
      expect(clean, isNot(contains('<script>')));
      expect(clean, isNot(contains('onload=')));
    });

    test('sanitizeSearchQuery strips dangerous tokens and limits length', () {
      const dirtyQuery = '<script>DJS 2024</script> [BNS Section 103] \\';
      final clean = Sanitizer.sanitizeSearchQuery(dirtyQuery);

      expect(clean, equals('scriptDJS 2024/script BNS Section 103'));
      expect(clean.length, lessThanOrEqualTo(100));
    });

    test('sanitizeUserInput strips null bytes and control chars', () {
      const dirtyInput = 'Section 103 Notes\x00\x08 text';
      final clean = Sanitizer.sanitizeUserInput(dirtyInput);

      expect(clean, equals('Section 103 Notes text'));
    });
  });
}
