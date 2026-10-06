import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
    GoRoute(
      path: '/prelims',
      builder: (context, state) => const PrelimsScreen(),
    ),
    GoRoute(
      path: '/mains',
      builder: (context, state) => const MainsScreen(),
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
              path: '/case_laws',
              builder: (context, state) => const CaseLawsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/gemini_tab',
              builder: (context, state) => const GeminiAiScreen(),
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
      bottomNavigationBar: _ModernBottomNav(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color activeColor;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.activeColor,
  });
}

class _ModernBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _ModernBottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const _items = [
    _NavItem(
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
      label: 'Home',
      activeColor: AppColors.accentGold,
    ),
    _NavItem(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Bare Acts',
      activeColor: AppColors.accentGold,
    ),
    _NavItem(
      icon: Icons.gavel_outlined,
      selectedIcon: Icons.gavel_rounded,
      label: 'Case Laws',
      activeColor: AppColors.accentGold,
    ),
    _NavItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome_rounded,
      label: 'Nyaya AI',
      activeColor: AppColors.accentGold,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: _items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = selectedIndex == index;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: '${item.label} tab',
                  child: Material(
                    color: Colors.transparent,
                    child: InkResponse(
                      onTap: () => onDestinationSelected(index),
                      highlightShape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(16),
                      splashColor: item.activeColor.withValues(alpha: 0.15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSelected ? 16 : 0,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? item.activeColor.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected ? item.activeColor : Colors.white38,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.inter(
                              color: isSelected ? item.activeColor : Colors.white38,
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
