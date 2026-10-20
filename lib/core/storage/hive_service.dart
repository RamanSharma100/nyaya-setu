import 'package:hive_flutter/hive_flutter.dart';
import '../utils/sanitizer.dart';

class HiveService {
  static const String settingsBoxName = 'user_settings';
  static const String bookmarksBoxName = 'section_bookmarks';
  static const String notesBoxName = 'section_notes';
  static const String flashcardProgressBoxName = 'flashcard_progress';
  static const String mainsDraftsBoxName = 'mains_drafts';
  static const String handmadeNotesBoxName = 'handmade_note_annotations';
  static const String handmadeNotesBookmarksBoxName = 'handmade_notes_bookmarks';
  static const String localActsProgressBoxName = 'local_acts_progress';
  static const String secureKeysBoxName = 'secure_api_keys';
  static const String offlineSyncBoxName = 'offline_sync_meta';
  static const String analyticsEventsBoxName = 'analytics_events_box';
  static const String analyticsMetricsBoxName = 'analytics_metrics_box';
  static const String loginAlertsAuditBoxName = 'login_alerts_audit_box';

  static Future<void> initHive() async {
    try {
      await Hive.initFlutter();
      await Future.wait([
        _openBoxSafe(settingsBoxName),
        _openBoxSafe(bookmarksBoxName),
        _openBoxSafe(notesBoxName),
        _openBoxSafe(flashcardProgressBoxName),
        _openBoxSafe(mainsDraftsBoxName),
        _openBoxSafe(handmadeNotesBoxName),
        _openBoxSafe(handmadeNotesBookmarksBoxName),
        _openBoxSafe(localActsProgressBoxName),
        _openBoxSafe(secureKeysBoxName),
        _openBoxSafe(offlineSyncBoxName),
        _openBoxSafe('user_auth_box'),
        _openBoxSafe(analyticsEventsBoxName),
        _openBoxSafe(analyticsMetricsBoxName),
        _openBoxSafe(loginAlertsAuditBoxName),
      ]).timeout(const Duration(seconds: 4));
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

  static String getHandmadeNoteAnnotation(String noteId) {
    if (!Hive.isBoxOpen(handmadeNotesBoxName)) return '';
    try {
      final box = Hive.box(handmadeNotesBoxName);
      return box.get(noteId, defaultValue: '') as String;
    } catch (_) {
      return '';
    }
  }

  static Future<void> saveHandmadeNoteAnnotation(String noteId, String annotation) async {
    await _openBoxSafe(handmadeNotesBoxName);
    try {
      final box = Hive.box(handmadeNotesBoxName);
      final clean = Sanitizer.sanitizeUserInput(annotation);
      await box.put(noteId, clean);
    } catch (_) {}
  }

  static bool isHandmadeNoteBookmarked(String noteId) {
    if (!Hive.isBoxOpen(handmadeNotesBookmarksBoxName)) return false;
    try {
      final box = Hive.box(handmadeNotesBookmarksBoxName);
      return box.get(noteId, defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<void> toggleHandmadeNoteBookmark(String noteId) async {
    await _openBoxSafe(handmadeNotesBookmarksBoxName);
    try {
      final box = Hive.box(handmadeNotesBookmarksBoxName);
      final current = isHandmadeNoteBookmarked(noteId);
      await box.put(noteId, !current);
    } catch (_) {}
  }

  // --- Local Acts Syllabus Checklist ---
  static bool isLocalActCompleted(String stateCode, String actName) {
    if (!Hive.isBoxOpen(localActsProgressBoxName)) return false;
    try {
      final box = Hive.box(localActsProgressBoxName);
      final key = '${stateCode}_$actName';
      return box.get(key, defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<void> toggleLocalActCompleted(String stateCode, String actName) async {
    await _openBoxSafe(localActsProgressBoxName);
    try {
      final box = Hive.box(localActsProgressBoxName);
      final key = '${stateCode}_$actName';
      final current = isLocalActCompleted(stateCode, actName);
      await box.put(key, !current);
    } catch (_) {}
  }

  static int getLocalActsCompletedCount(String stateCode, List<String> acts) {
    int count = 0;
    for (final act in acts) {
      if (isLocalActCompleted(stateCode, act)) count++;
    }
    return count;
  }

  // --- Secure In-App API Key Overrides (Protects against APK decompilation) ---
  static String getCustomApiKey(String keyName) {
    if (!Hive.isBoxOpen(secureKeysBoxName)) return '';
    try {
      final box = Hive.box(secureKeysBoxName);
      return box.get(keyName, defaultValue: '') as String;
    } catch (_) {
      return '';
    }
  }

  static Future<void> saveCustomApiKey(String keyName, String value) async {
    await _openBoxSafe(secureKeysBoxName);
    try {
      final box = Hive.box(secureKeysBoxName);
      await box.put(keyName, value.trim());
    } catch (_) {}
  }

  // --- Offline Sync Metadata ---
  static String getLastSyncDate() {
    if (!Hive.isBoxOpen(offlineSyncBoxName)) return 'Never';
    try {
      final box = Hive.box(offlineSyncBoxName);
      return box.get('last_sync_timestamp', defaultValue: 'Never') as String;
    } catch (_) {
      return 'Never';
    }
  }

  static Future<void> recordFullSyncCompleted() async {
    await _openBoxSafe(offlineSyncBoxName);
    try {
      final box = Hive.box(offlineSyncBoxName);
      final now = DateTime.now();
      final formatted = '${now.day}/${now.month}/${now.year} at ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      await box.put('last_sync_timestamp', formatted);
      await box.put('is_full_cached', true);
    } catch (_) {}
  }

  static bool isForceOfflineMode() {
    if (!Hive.isBoxOpen(offlineSyncBoxName)) return false;
    try {
      final box = Hive.box(offlineSyncBoxName);
      return box.get('force_offline_mode', defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setForceOfflineMode(bool enabled) async {
    await _openBoxSafe(offlineSyncBoxName);
    try {
      final box = Hive.box(offlineSyncBoxName);
      await box.put('force_offline_mode', enabled);
    } catch (_) {}
  }
}

