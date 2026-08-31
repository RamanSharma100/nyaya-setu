import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../features/auth/login_screen.dart';
import '../../features/bare_acts/bare_acts_screen.dart';
import '../../features/case_laws/case_laws_screen.dart';
import '../../features/concept_search/concept_search_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/gemini_ai/gemini_ai_screen.dart';
import '../../features/mains/mains_screen.dart';
import '../../features/prelims/prelims_screen.dart';
import '../../features/splash/splash_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/concept_search',
      builder: (context, state) => const ConceptSearchScreen(),
    ),
    GoRoute(
      path: '/gemini',
      builder: (context, state) => const GeminiAiScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bare_acts',
              builder: (context, state) => const BareActsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/prelims',
              builder: (context, state) => const PrelimsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mains',
              builder: (context, state) => const MainsScreen(),
            ),
          ],
        ),
        // StatefulShellBranch(
        //   routes: [
        //     GoRoute(
        //       path: '/gemini_tab',
        //       builder: (context, state) => const GeminiAiScreen(),
        //     ),
        //   ],
        // ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/case_laws',
              builder: (context, state) => const CaseLawsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithBottomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        backgroundColor: AppColors.primaryNavy,
        indicatorColor: AppColors.accentGold.withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.accentGold),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.accentGold),
            label: 'Bare Acts',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.quiz, color: AppColors.accentGold),
            label: 'Prelims',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.edit_note, color: AppColors.accentGold),
            label: 'Mains',
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.auto_awesome_outlined, color: Colors.white70),
          //   selectedIcon: Icon(Icons.auto_awesome, color: AppColors.accentGold),
          //   label: 'NyayaAI',
          // ),
          NavigationDestination(
            icon: Icon(Icons.gavel_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.gavel, color: AppColors.accentGold),
            label: 'Case Laws',
          ),
        ],
      ),
    );
  }
}
