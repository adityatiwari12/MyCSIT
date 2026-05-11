import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/splash_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/pending_screen.dart';
import '../../screens/rejected_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/activities_screen.dart';
import '../../screens/add_activity_screen.dart';
import '../../screens/activity_detail_screen.dart';
import '../../screens/coding_screen.dart';
import '../../screens/add_coding_screen.dart';
import '../../screens/academics_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = _RouterNotifier(ref);
  return GoRouter(
    refreshListenable: routerNotifier,
    initialLocation: '/splash',
    redirect: (context, state) => routerNotifier.redirect(state),
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/pending', builder: (_, __) => const PendingScreen()),
      GoRoute(path: '/rejected', builder: (_, __) => const RejectedScreen()),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(path: 'profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(
            path: 'activities',
            builder: (_, __) => const ActivitiesScreen(),
            routes: [
              GoRoute(path: 'add', builder: (_, __) => const AddActivityScreen()),
              GoRoute(
                path: ':id',
                builder: (_, state) => ActivityDetailScreen(
                  activityId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'coding',
            builder: (_, __) => const CodingScreen(),
            routes: [
              GoRoute(path: 'add', builder: (_, __) => const AddCodingScreen()),
            ],
          ),
          GoRoute(path: 'academics', builder: (_, __) => const AcademicsScreen()),
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
    _ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }

  String? redirect(GoRouterState state) {
    final authAsync = _ref.read(authStateProvider);

    if (authAsync.isLoading) return '/splash';

    final uid = authAsync.valueOrNull?.id;
    if (uid == null) {
      if (state.matchedLocation == '/register') return null;
      return '/login';
    }

    final userAsync = _ref.read(currentUserProvider);
    if (userAsync.isLoading) return '/splash';

    final user = userAsync.valueOrNull;
    if (user == null) return '/splash';

    final loc = state.matchedLocation;
    switch (user.status) {
      case UserStatus.pending:
        return loc == '/pending' ? null : '/pending';
      case UserStatus.rejected:
        return loc == '/rejected' ? null : '/rejected';
      case UserStatus.active:
        const authPages = {'/login', '/register', '/pending', '/rejected', '/splash'};
        return authPages.contains(loc) ? '/home' : null;
    }
  }
}
