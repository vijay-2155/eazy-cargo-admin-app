import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eaze_my_cargo/features/splash/screens/splash_screen.dart';
import 'package:eaze_my_cargo/features/auth/screens/login_screen.dart';
import 'package:eaze_my_cargo/features/dashboard/screens/home_screen.dart';
import 'package:eaze_my_cargo/features/consignment/screens/consignment_list_screen.dart';
import 'package:eaze_my_cargo/features/consignment/screens/consignment_create_screen.dart';
import 'package:eaze_my_cargo/features/consignment/screens/consignment_monitor_screen.dart';
import 'package:eaze_my_cargo/features/consignment/screens/consignment_detail_screen.dart';
import 'package:eaze_my_cargo/features/truck/screens/truck_list_screen.dart';
import 'package:eaze_my_cargo/features/truck/screens/truck_create_screen.dart';
import 'package:eaze_my_cargo/features/driver/screens/driver_list_screen.dart';
import 'package:eaze_my_cargo/features/driver/screens/driver_create_screen.dart';
import 'package:eaze_my_cargo/features/analytics/screens/analytics_screen.dart';
import 'package:eaze_my_cargo/features/geofence/screens/geofence_screen.dart';
import 'package:eaze_my_cargo/features/notifications/screens/notifications_screen.dart';
import 'package:eaze_my_cargo/core/constants/app_constants.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.routeSplash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppConstants.routeSplash,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SplashScreen(),
      ),
    ),
    GoRoute(
      path: AppConstants.routeLogin,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const LoginScreen(),
        transitionsBuilder: _fadeSlide,
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppConstants.routeHome,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppConstants.routeConsignments,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ConsignmentListScreen(),
          ),
          routes: [
            GoRoute(
              path: 'create',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const ConsignmentCreateScreen(),
                transitionsBuilder: _slideUp,
              ),
            ),
            GoRoute(
              path: 'monitor',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const ConsignmentMonitorScreen(),
                transitionsBuilder: _slideUp,
              ),
            ),
            GoRoute(
              path: 'detail/:id',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: ConsignmentDetailScreen(
                  id: state.pathParameters['id'] ?? '',
                ),
                transitionsBuilder: _fadeSlide,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppConstants.routeTrucks,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TruckListScreen(),
          ),
          routes: [
            GoRoute(
              path: 'create',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const TruckCreateScreen(),
                transitionsBuilder: _slideUp,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppConstants.routeDrivers,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DriverListScreen(),
          ),
          routes: [
            GoRoute(
              path: 'create',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const DriverCreateScreen(),
                transitionsBuilder: _slideUp,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppConstants.routeAnalytics,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AnalyticsScreen(),
          ),
        ),
        GoRoute(
          path: AppConstants.routeGeofence,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: GeofenceScreen(),
          ),
        ),
        GoRoute(
          path: AppConstants.routeNotifications,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: NotificationsScreen(),
          ),
        ),
      ],
    ),
  ],
);

Widget _fadeSlide(
    BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
    ),
  );
}

Widget _slideUp(
    BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
    child: FadeTransition(opacity: animation, child: child),
  );
}

// ─────────────────────────────────────────────────────────────
// Main Shell — wraps content + modern floating bottom nav
// ─────────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: AppConstants.routeHome,
    ),
    _NavItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'Shipments',
      route: AppConstants.routeConsignments,
    ),
    _NavItem(
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping_rounded,
      label: 'Trucks',
      route: AppConstants.routeTrucks,
    ),
    _NavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Drivers',
      route: AppConstants.routeDrivers,
    ),
    _NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Analytics',
      route: AppConstants.routeAnalytics,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return _ModernNavBar(
      items: _navItems,
      selectedIndex: _selectedIndex,
      onItemSelected: (i) {
        setState(() => _selectedIndex = i);
        context.go(_navItems[i].route);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Modern Floating Pill Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────
class _ModernNavBar extends StatefulWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _ModernNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<_ModernNavBar> createState() => _ModernNavBarState();
}

class _ModernNavBarState extends State<_ModernNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnims;

  @override
  void initState() {
    super.initState();
    _scaleControllers = List.generate(
      widget.items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 180),
        lowerBound: 0.85,
        upperBound: 1.0,
        value: 1.0,
      ),
    );
    _scaleAnims = _scaleControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOutBack))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _scaleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    _scaleControllers[index].forward(from: 0.85);
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + bottomPad),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(widget.items.length, (i) {
              final item = widget.items[i];
              final selected = widget.selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onTap(i),
                  child: ScaleTransition(
                    scale: _scaleAnims[i],
                    child: _NavPill(item: item, selected: selected),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Vertical pill — icon on top, label below — NEVER overflows
// ─────────────────────────────────────────────────────────────
class _NavPill extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  const _NavPill({required this.item, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Clean Premium Soft Tint Bubble (active only) ─────
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: selected ? 1.0 : 0.0,
            child: Container(
              width: 72,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Slate-blue-50 tint
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFDBEAFE), // Slate-blue-100 border
                  width: 1,
                ),
              ),
            ),
          ),

          // ── Icon + label column ───────────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  key: ValueKey(selected),
                  size: 22,
                  color: selected
                      ? const Color(0xFF2563EB) // Electric Blue
                      : const Color(0xFF64748B), // Slate-500 unselected
                ),
              ),
              const SizedBox(height: 3),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: selected ? 1.0 : 0.0,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB), // Electric Blue
                    letterSpacing: 0.1,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}



