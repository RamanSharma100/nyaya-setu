import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/env_config.dart';
import '../storage/hive_service.dart';

/// Service responsible for dispatching email alerts whenever a user logs in
class LoginNotificationService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  static const String _auditBoxName = HiveService.loginAlertsAuditBoxName;

  /// Triggered on every Google Sign-In or Guest Access
  static Future<bool> notifyLogin({
    required String method, // 'google' or 'guest'
    String? email,
    String? name,
    required int googleCount,
    required int guestCount,
  }) async {
    final now = DateTime.now();
    final istTime = now.toUtc().add(const Duration(hours: 5, minutes: 30));
    final formattedTime =
        '${istTime.year}-${istTime.month.toString().padLeft(2, '0')}-${istTime.day.toString().padLeft(2, '0')} '
        '${istTime.hour.toString().padLeft(2, '0')}:${istTime.minute.toString().padLeft(2, '0')}:${istTime.second.toString().padLeft(2, '0')} IST';

    final isGoogle = method.toLowerCase() == 'google';
    final userLabel = isGoogle ? '${name ?? 'User'} (${email ?? 'No email'})' : 'Guest Aspirant (Anonymous Session)';
    final subject = isGoogle
        ? '🚨 [NyayaSetu] New Google Login: ${email ?? 'Google User'}'
        : '👤 [NyayaSetu] New Guest Login (Total Guests: $guestCount)';

    final messageBody = StringBuffer()
      ..writeln('🎉 NyayaSetu Authentication Telemetry Alert')
      ..writeln('-------------------------------------------')
      ..writeln('Login Event: ${isGoogle ? 'Google Account Sign-In' : 'Guest Session Started'}')
      ..writeln('User: $userLabel')
      ..writeln('Timestamp: $formattedTime')
      ..writeln('Platform: Android / Mobile')
      ..writeln('-------------------------------------------')
      ..writeln('📊 Aggregate Platform Telemetry:')
      ..writeln('• Total Google Logins: $googleCount')
      ..writeln('• Total Guest Logins:  $guestCount')
      ..writeln('• Total All-Time Logins: ${googleCount + guestCount}')
      ..writeln('-------------------------------------------')
      ..writeln('App Version: NyayaSetu v1.0.0 (Production Release)');

    final webhookUrl = EnvConfig.loginAlertWebhook;
    final alertRecipient = EnvConfig.loginAlertEmail;
    final rawTarget = webhookUrl.isNotEmpty ? webhookUrl : alertRecipient;

    final auditEntry = {
      'timestamp': formattedTime,
      'method': method,
      'user': userLabel,
      'subject': subject,
      'status': 'pending',
      'endpoint': rawTarget.isNotEmpty ? rawTarget : 'None (Logged Locally)',
    };

    if (rawTarget.isEmpty) {
      debugPrint('[LoginNotification] No webhook or email configured. Logging locally.');
      auditEntry['status'] = 'logged_locally_no_webhook';
      _saveAudit(auditEntry);
      return true;
    }

    try {
      final dispatch = _resolveEndpointAndPayload(
        rawTarget: rawTarget,
        subject: subject,
        messageBody: messageBody.toString(),
        userLabel: userLabel,
        method: method,
        email: email,
      );

      final response = await _dio.post(
        dispatch.url,
        data: dispatch.body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final success = response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
      auditEntry['status'] = success ? 'delivered' : 'failed_status_${response.statusCode}';
      _saveAudit(auditEntry);
      return success;
    } catch (e) {
      debugPrint('[LoginNotification] Webhook dispatch error: $e');
      auditEntry['status'] = 'error: $e';
      _saveAudit(auditEntry);
      return false;
    }
  }

  /// Sends a sample test email to verify developer/admin alert setup
  static Future<bool> sendTestAlert({required String targetEndpoint}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final subject = '🔔 [NyayaSetu] Test Login Alert Verification';
      final message = 'Test login alert from NyayaSetu app. Email notifications are functioning properly in India!';

      final dispatch = _resolveEndpointAndPayload(
        rawTarget: targetEndpoint,
        subject: subject,
        messageBody: message,
        userLabel: 'Admin Test Trigger',
        method: 'test',
      );

      final response = await _dio.post(
        dispatch.url,
        data: dispatch.body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final isSuccess = response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
      _saveAudit({
        'timestamp': now,
        'method': 'test',
        'user': 'Admin Test Trigger',
        'subject': subject,
        'status': isSuccess ? 'delivered' : 'failed_status_${response.statusCode}',
        'endpoint': dispatch.url,
      });
      return isSuccess;
    } catch (e) {
      debugPrint('[LoginNotification] Test alert error: $e');
      return false;
    }
  }

  /// Automatically parses raw target: email address, Web3Forms key, Discord, or Webhook URL
  static _DispatchTarget _resolveEndpointAndPayload({
    required String rawTarget,
    required String subject,
    required String messageBody,
    required String userLabel,
    required String method,
    String? email,
  }) {
    final trimmed = rawTarget.trim();

    // 1. Direct Email (FormSubmit Ajax: 100% free, zero-signup, works in India)
    if (!trimmed.startsWith('http') && trimmed.contains('@')) {
      return _DispatchTarget(
        url: 'https://formsubmit.co/ajax/$trimmed',
        body: {
          '_subject': subject,
          'message': messageBody,
          'login_type': method,
          'user': userLabel,
          '_template': 'table',
        },
      );
    }

    // 2. Web3Forms (Access Key or web3forms.com link: works 100% in India)
    final isWeb3FormsKey = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(trimmed);
    if (isWeb3FormsKey || trimmed.contains('web3forms.com')) {
      final key = isWeb3FormsKey ? trimmed : trimmed.split('/').last;
      return _DispatchTarget(
        url: 'https://api.web3forms.com/submit',
        body: {
          'access_key': key,
          'subject': subject,
          'from_name': 'NyayaSetu Platform',
          'name': userLabel,
          'message': messageBody,
        },
      );
    }

    // 3. Discord Webhook
    if (trimmed.contains('discord.com/api/webhooks')) {
      return _DispatchTarget(
        url: trimmed,
        body: {
          'content': '📢 **$subject**\n```\n$messageBody\n```',
        },
      );
    }

    // 4. Google Apps Script / Standard JSON Webhook
    return _DispatchTarget(
      url: trimmed,
      body: {
        'subject': subject,
        '_subject': subject,
        'message': messageBody,
        'login_type': method,
        'user_name': userLabel,
        'user_email': email ?? '',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static void _saveAudit(Map<String, dynamic> entry) {
    try {
      if (!Hive.isBoxOpen(_auditBoxName)) return;
      final box = Hive.box(_auditBoxName);
      final list = List<dynamic>.from(box.get('audit_log', defaultValue: <dynamic>[]) as List);
      list.insert(0, jsonEncode(entry));
      if (list.length > 50) {
        list.removeRange(50, list.length);
      }
      box.put('audit_log', list);
    } catch (_) {}
  }

  /// Retrieves recent login email notification audit logs
  static List<Map<String, dynamic>> getAuditLogs() {
    if (!Hive.isBoxOpen(_auditBoxName)) return [];
    try {
      final box = Hive.box(_auditBoxName);
      final rawList = box.get('audit_log', defaultValue: <dynamic>[]) as List;
      return rawList.map((item) {
        try {
          return jsonDecode(item as String) as Map<String, dynamic>;
        } catch (_) {
          return <String, dynamic>{'subject': 'Unknown', 'status': 'corrupt'};
        }
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

class _DispatchTarget {
  final String url;
  final Map<String, dynamic> body;
  const _DispatchTarget({required this.url, required this.body});
}
