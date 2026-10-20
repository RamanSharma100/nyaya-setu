import 'package:flutter/material.dart';
import 'analytics_service.dart';

/// Automatically captures page/screen views upon route transitions
class AnalyticsRouteObserver extends NavigatorObserver {
  void _sendScreenView(Route<dynamic>? route) {
    try {
      if (route == null) return;
      final screenName = route.settings.name ?? route.settings.arguments?.toString();
      if (screenName != null && screenName.isNotEmpty) {
        AnalyticsService.trackPageView(screenName, {
          'route_name': screenName,
          'route_type': route.runtimeType.toString(),
        });
      }
    } catch (_) {}
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sendScreenView(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _sendScreenView(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _sendScreenView(previousRoute);
  }
}
