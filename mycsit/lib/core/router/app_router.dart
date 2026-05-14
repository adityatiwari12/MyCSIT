import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/mock_auth_provider.dart';
import '../../services/mock_auth_service.dart';
import '../../screens/splash_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/login_screen_simple.dart';
import '../../screens/register_screen.dart';
import '../../screens/pending_screen.dart';
import '../../screens/rejected_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/functional_home_screen.dart';
import '../../screens/main_home_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/functional_profile_screen.dart';
import '../../screens/enhanced_profile_screen.dart';
import '../../screens/activities_screen.dart';
import '../../screens/functional_activities_screen.dart';
import '../../screens/add_activity_screen.dart';
import '../../screens/activity_detail_screen.dart';
import '../../screens/coding_screen.dart';
import '../../screens/functional_coding_screen.dart';
import '../../screens/add_coding_screen.dart';
import '../../screens/academics_screen.dart';
import '../../screens/functional_academics_screen.dart';
import '../../screens/premium_main_screen.dart';
import '../../screens/premium_home_screen.dart';
import '../../screens/premium_activities_screen.dart';
import '../../screens/premium_add_entry_screen.dart';
import '../../screens/premium_profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = _RouterNotifier(ref);
  return GoRouter(
    refreshListenable: routerNotifier,
    initialLocation: '/premium',
    redirect: (context, state) => routerNotifier.redirect(state),
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/pending', builder: (_, __) => const PendingScreen()),
      GoRoute(path: '/rejected', builder: (_, __) => const RejectedScreen()),
      GoRoute(
        path: '/home',
        builder: (_, __) => const MainHomeScreen(),
        routes: [
          GoRoute(path: 'profile', builder: (_, __) => const EnhancedProfileScreen()),
          GoRoute(
            path: 'activities',
            builder: (_, __) => const FunctionalActivitiesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const AddActivityScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, __) => ActivityDetailScreen(activityId: ''),
              ),
            ],
          ),
          GoRoute(
            path: 'coding',
            builder: (_, __) => const FunctionalCodingScreen(),
            routes: [
              GoRoute(path: 'add', builder: (_, __) => const AddCodingScreen()),
            ],
          ),
          GoRoute(path: 'academics', builder: (_, __) => const FunctionalAcademicsScreen()),
        ],
      ),
      GoRoute(
        path: '/premium',
        builder: (_, __) => const PremiumMainScreen(),
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
    // Set up the callback for mock auth state changes
    MockAuthService.setAuthStateCallback((user) {
      final notifier = _ref.read(mockAuthStateNotifierProvider.notifier);
      notifier.updateUser(user);
    });
    
    _ref.listen(mockAuthStateNotifierProvider, (_, __) => notifyListeners());
  }

  String? redirect(GoRouterState state) {
    final user = _ref.read(mockCurrentUserProvider);

    if (user == null) {
      if (state.matchedLocation == '/login' || state.matchedLocation == '/register') {
        return null;
      }
      return '/login';
    }

    // User is authenticated, redirect to home if on auth pages
    final loc = state.matchedLocation;
    const authPages = {'/login', '/register', '/splash'};
    return authPages.contains(loc) ? '/home' : null;
  }
}
