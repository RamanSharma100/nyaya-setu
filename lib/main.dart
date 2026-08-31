import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_themes.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initHive();

  runApp(
    const ProviderScope(
      child: NyayaSetuApp(),
    ),
  );
}

class NoStretchScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class NyayaSetuApp extends StatelessWidget {
  const NyayaSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NyayaSetu',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: NoStretchScrollBehavior(),
      routerConfig: appRouter,
    );
  }
}
