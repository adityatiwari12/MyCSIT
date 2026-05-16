import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../screens/splash_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/pending_screen.dart';
import '../../screens/rejected_screen.dart';
import '../../screens/premium_main_screen.dart';
import '../../screens/activity_detail_screen.dart';
import '../../screens/coding_activity_detail_screen.dart';
import '../../screens/notifications_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/splash',
    redirect: (context, state) => notifier.redirect(state),
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/pending', builder: (_, __) => const PendingScreen()),
      GoRoute(path: '/rejected', builder: (_, __) => const RejectedScreen()),
      GoRoute(
        path: '/app',
        builder: (_, __) => const PremiumMainScreen(),
        routes: [
          GoRoute(
            path: 'activity/:id',
            builder: (_, state) => ActivityDetailScreen(
              activityId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'coding/:id',
            builder: (_, state) => CodingActivityDetailScreen(
              activityId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(currentStudentProvider, (_, __) => notifyListeners());
  }

  String? redirect(GoRouterState state) {
    final authAsync = _ref.read(authStateProvider);
    final studentAsync = _ref.read(currentStudentProvider);

    final loc = state.matchedLocation;

    // Still loading auth
    if (authAsync.isLoading) return null;

    final user = authAsync.valueOrNull;

    // Not authenticated
    if (user == null) {
      if (loc == '/login' || loc == '/register' || loc == '/splash') {
        return null;
      }
      return '/login';
    }

    // Authenticated — waiting for student profile
    if (studentAsync.isLoading) {
      return loc == '/splash' ? null : '/splash';
    }

    final student = studentAsync.valueOrNull;

    // Student profile not yet available (e.g. DB insert still in progress)
    if (student == null) {
      return loc == '/pending' ? null : '/pending';
    }

    final status = student.status;

    // On auth / splash pages while logged in → redirect by status
    const guestRoutes = {'/login', '/register', '/splash'};
    if (guestRoutes.contains(loc)) {
      return _routeForStatus(status);
    }

    // Enforce status-based routing
    if (status == 'pending' && loc != '/pending') return '/pending';
    if (status == 'rejected' && loc != '/rejected') return '/rejected';
    if (status == 'active' && (loc == '/pending' || loc == '/rejected')) {
      return '/app';
    }

    return null;
  }

  String _routeForStatus(String status) {
    switch (status) {
      case 'active':
        return '/app';
      case 'pending':
        return '/pending';
      case 'rejected':
        return '/rejected';
      default:
        return '/pending';
    }
  }
}
