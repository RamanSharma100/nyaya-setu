import 'package:hive_flutter/hive_flutter.dart';
import '../utils/sanitizer.dart';

class HiveService {
  static const String settingsBoxName = 'user_settings';
  static const String bookmarksBoxName = 'section_bookmarks';
  static const String notesBoxName = 'section_notes';
  static const String flashcardProgressBoxName = 'flashcard_progress';
  static const String mainsDraftsBoxName = 'mains_drafts';

  static Future<void> initHive() async {
    try {
      await Hive.initFlutter();
      await Future.wait([
        _openBoxSafe(settingsBoxName),
        _openBoxSafe(bookmarksBoxName),
        _openBoxSafe(notesBoxName),
        _openBoxSafe(flashcardProgressBoxName),
        _openBoxSafe(mainsDraftsBoxName),
        _openBoxSafe('user_auth_box'),
      ]).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  static Future<void> _openBoxSafe(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      try {
        await Hive.openBox(boxName);
      } catch (_) {
        try {
          await Hive.deleteBoxFromDisk(boxName);
          await Hive.openBox(boxName);
        } catch (_) {}
      }
    }
  }

  static String getSelectedState() {
    if (!Hive.isBoxOpen(settingsBoxName)) return 'DJS';
    try {
      final box = Hive.box(settingsBoxName);
      return box.get('selected_state', defaultValue: 'DJS') as String;
    } catch (_) {
      return 'DJS';
    }
  }

  static Future<void> setSelectedState(String stateCode) async {
    await _openBoxSafe(settingsBoxName);
    try {
      final box = Hive.box(settingsBoxName);
      await box.put('selected_state', Sanitizer.sanitizeUserInput(stateCode));
    } catch (_) {}
  }

  static bool isBookmarked(String actId, String sectionNumber) {
    if (!Hive.isBoxOpen(bookmarksBoxName)) return false;
    try {
      final box = Hive.box(bookmarksBoxName);
      final key = '${actId}_$sectionNumber';
      return box.get(key, defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<void> toggleBookmark(String actId, String sectionNumber) async {
    await _openBoxSafe(bookmarksBoxName);
    try {
      final box = Hive.box(bookmarksBoxName);
      final key = '${actId}_$sectionNumber';
      final current = isBookmarked(actId, sectionNumber);
      await box.put(key, !current);
    } catch (_) {}
  }

  static String getSectionNote(String actId, String sectionNumber) {
    if (!Hive.isBoxOpen(notesBoxName)) return '';
    try {
      final box = Hive.box(notesBoxName);
      final key = '${actId}_$sectionNumber';
      return box.get(key, defaultValue: '') as String;
    } catch (_) {
      return '';
    }
  }

  static Future<void> saveSectionNote(String actId, String sectionNumber, String note) async {
    await _openBoxSafe(notesBoxName);
    try {
      final box = Hive.box(notesBoxName);
      final key = '${actId}_$sectionNumber';
      final cleanNote = Sanitizer.sanitizeUserInput(note);
      await box.put(key, cleanNote);
    } catch (_) {}
  }

  static String getFlashcardStatus(String cardId) {
    if (!Hive.isBoxOpen(flashcardProgressBoxName)) return 'unseen';
    try {
      final box = Hive.box(flashcardProgressBoxName);
      return box.get(cardId, defaultValue: 'unseen') as String;
    } catch (_) {
      return 'unseen';
    }
  }

  static Future<void> updateFlashcardStatus(String cardId, String status) async {
    await _openBoxSafe(flashcardProgressBoxName);
    try {
      final box = Hive.box(flashcardProgressBoxName);
      await box.put(cardId, status);
    } catch (_) {}
  }

  static String getMainsDraft(String questionId) {
    if (!Hive.isBoxOpen(mainsDraftsBoxName)) return '';
    try {
      final box = Hive.box(mainsDraftsBoxName);
      return box.get(questionId, defaultValue: '') as String;
    } catch (_) {
      return '';
    }
  }

  static Future<void> saveMainsDraft(String questionId, String draft) async {
    await _openBoxSafe(mainsDraftsBoxName);
    try {
      final box = Hive.box(mainsDraftsBoxName);
      final cleanDraft = Sanitizer.sanitizeUserInput(draft);
      await box.put(questionId, cleanDraft);
    } catch (_) {}
  }
}
