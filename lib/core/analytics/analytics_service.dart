import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/env_config.dart';
import '../storage/hive_service.dart';
import 'login_notification_service.dart';

/// Enterprise Analytics & Telemetry Service (PostHog compatible + Local Offline Store)
class AnalyticsService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static const String _metricsBoxName = HiveService.analyticsMetricsBoxName;
  static const String _eventsBoxName = HiveService.analyticsEventsBoxName;

  static String? _cachedDeviceId;

  /// Get or create a persistent anonymous device identifier
  static String get deviceId {
    if (_cachedDeviceId != null) return _cachedDeviceId!;
    try {
      if (Hive.isBoxOpen(_metricsBoxName)) {
        final box = Hive.box(_metricsBoxName);
        var id = box.get('device_id') as String?;
        if (id == null || id.isEmpty) {
          final rand = Random().nextInt(999999);
          id = 'dev_${DateTime.now().millisecondsSinceEpoch}_$rand';
          box.put('device_id', id);
        }
        _cachedDeviceId = id;
        return id;
      }
    } catch (_) {}
    return 'dev_fallback_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Initialize analytics subsystem
  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_metricsBoxName)) {
        await Hive.openBox(_metricsBoxName);
      }
      if (!Hive.isBoxOpen(_eventsBoxName)) {
        await Hive.openBox(_eventsBoxName);
      }
      // Warm up device ID
      final _ = deviceId;
    } catch (e) {
      debugPrint('[Analytics] Init error: $e');
    }
  }

  // --- Metrics Getters ---
  static int get googleLoginsCount {
    if (!Hive.isBoxOpen(_metricsBoxName)) return 0;
    return Hive.box(_metricsBoxName).get('google_login_count', defaultValue: 0) as int;
  }

  static int get guestLoginsCount {
    if (!Hive.isBoxOpen(_metricsBoxName)) return 0;
    return Hive.box(_metricsBoxName).get('guest_login_count', defaultValue: 0) as int;
  }

  static int get totalLoginsCount => googleLoginsCount + guestLoginsCount;

  static int get pageViewsCount {
    if (!Hive.isBoxOpen(_metricsBoxName)) return 0;
    return Hive.box(_metricsBoxName).get('page_views_count', defaultValue: 0) as int;
  }

  static int get buttonClicksCount {
    if (!Hive.isBoxOpen(_metricsBoxName)) return 0;
    return Hive.box(_metricsBoxName).get('button_clicks_count', defaultValue: 0) as int;
  }

  static String get lastLoginType {
    if (!Hive.isBoxOpen(_metricsBoxName)) return 'None';
    return Hive.box(_metricsBoxName).get('last_login_type', defaultValue: 'None') as String;
  }

  static String get lastLoginTimestamp {
    if (!Hive.isBoxOpen(_metricsBoxName)) return 'Never';
    return Hive.box(_metricsBoxName).get('last_login_at', defaultValue: 'Never') as String;
  }

  // --- Core Tracking Methods ---

  /// Tracks an automated or manual page view
  static Future<void> trackPageView(String pageName, [Map<String, dynamic>? properties]) async {
    try {
      if (Hive.isBoxOpen(_metricsBoxName)) {
        final box = Hive.box(_metricsBoxName);
        final current = box.get('page_views_count', defaultValue: 0) as int;
        await box.put('page_views_count', current + 1);
      }

      await trackEvent('\$pageview', {
        'page_name': pageName,
        '\$current_url': pageName,
        ...?properties,
      });
    } catch (e) {
      debugPrint('[Analytics] Pageview tracking error: $e');
    }
  }

  /// Tracks a button click event
  static Future<void> trackButtonClick(
    String buttonId, {
    String? screen,
    Map<String, dynamic>? properties,
  }) async {
    try {
      if (Hive.isBoxOpen(_metricsBoxName)) {
        final box = Hive.box(_metricsBoxName);
        final current = box.get('button_clicks_count', defaultValue: 0) as int;
        await box.put('button_clicks_count', current + 1);
      }

      final Map<String, dynamic> eventProps = {
        'button_id': buttonId,
        ...?properties,
      };
      if (screen != null) {
        eventProps['screen'] = screen;
      }

      await trackEvent('button_clicked', eventProps);
    } catch (e) {
      debugPrint('[Analytics] Button click tracking error: $e');
    }
  }

  /// Records a login (Google OAuth or Guest), increments counters, and triggers email alert
  static Future<void> recordLogin({
    required String method, // 'google' or 'guest'
    String? email,
    String? name,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      if (Hive.isBoxOpen(_metricsBoxName)) {
        final box = Hive.box(_metricsBoxName);
        if (method == 'google') {
          final count = box.get('google_login_count', defaultValue: 0) as int;
          await box.put('google_login_count', count + 1);
        } else {
          final count = box.get('guest_login_count', defaultValue: 0) as int;
          await box.put('guest_login_count', count + 1);
        }
        await box.put('last_login_type', method);
        await box.put('last_login_at', now);
        if (email != null && email.isNotEmpty) {
          await box.put('last_user_email', email);
        }
      }

      // 1. PostHog Event Capture
      await trackEvent('user_logged_in', {
        'login_method': method,
        'user_email': email ?? 'guest_session',
        'user_name': name ?? 'Guest Legal Aspirant',
        'is_guest': method == 'guest',
        'google_logins_total': googleLoginsCount,
        'guest_logins_total': guestLoginsCount,
        'total_logins_all_time': totalLoginsCount,
      });

      // 2. Trigger Email Alert via Notification Service
      await LoginNotificationService.notifyLogin(
        method: method,
        email: email,
        name: name,
        googleCount: googleLoginsCount,
        guestCount: guestLoginsCount,
      );
    } catch (e) {
      debugPrint('[Analytics] Record login error: $e');
    }
  }

  /// Generic PostHog-compatible event capture
  static Future<void> trackEvent(String eventName, [Map<String, dynamic>? properties]) async {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final eventPayload = {
      'event': eventName,
      'timestamp': timestamp,
      'properties': {
        'distinct_id': deviceId,
        '\$lib': 'nyayasetu-flutter',
        '\$lib_version': '1.0.0',
        'platform': defaultTargetPlatform.name,
        ...?properties,
      },
    };

    // 1. Append to local event buffer in Hive (capped at 200 events)
    _saveLocalEvent(eventPayload);

    // 2. If PostHog API Key is configured, dispatch HTTP request asynchronously
    final posthogKey = EnvConfig.posthogApiKey;
    if (posthogKey.isNotEmpty) {
      _dispatchToPostHog(posthogKey, eventPayload);
    }
  }

  static void _saveLocalEvent(Map<String, dynamic> event) {
    try {
      if (!Hive.isBoxOpen(_eventsBoxName)) return;
      final box = Hive.box(_eventsBoxName);
      final list = List<dynamic>.from(box.get('recent_events', defaultValue: <dynamic>[]) as List);
      list.insert(0, jsonEncode(event));
      if (list.length > 200) {
        list.removeRange(200, list.length);
      }
      box.put('recent_events', list);
    } catch (_) {}
  }

  static Future<void> _dispatchToPostHog(String apiKey, Map<String, dynamic> payload) async {
    try {
      final host = EnvConfig.posthogHost.replaceAll(RegExp(r'/+$'), '');
      final endpoint = '$host/capture/';

      final body = {
        'api_key': apiKey,
        'event': payload['event'],
        'properties': payload['properties'],
        'timestamp': payload['timestamp'],
      };

      await _dio.post(
        endpoint,
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } catch (e) {
      debugPrint('[PostHog] Remote capture skipped/error: $e');
    }
  }

  /// Returns recent captured events from local storage
  static List<Map<String, dynamic>> getRecentEvents() {
    if (!Hive.isBoxOpen(_eventsBoxName)) return [];
    try {
      final box = Hive.box(_eventsBoxName);
      final rawList = box.get('recent_events', defaultValue: <dynamic>[]) as List;
      return rawList.map((item) {
        try {
          return jsonDecode(item as String) as Map<String, dynamic>;
        } catch (_) {
          return <String, dynamic>{'event': 'unknown', 'timestamp': ''};
        }
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Google Play Compliance: Permanently wipes local analytics storage
  static Future<void> clearAllAnalytics() async {
    try {
      if (Hive.isBoxOpen(_eventsBoxName)) {
        await Hive.box(_eventsBoxName).clear();
      }
      if (Hive.isBoxOpen(_metricsBoxName)) {
        await Hive.box(_metricsBoxName).clear();
      }
    } catch (_) {}
  }
}
