import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/search/presentation/screens/explore_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/trips/presentation/screens/my_trips_screen.dart';
import '../features/trips/presentation/screens/create_trip_screen.dart';
import '../features/trips/presentation/screens/itinerary_builder_screen.dart';
import '../features/search/presentation/screens/activity_search_screen.dart';
import '../features/budget/presentation/screens/budget_analytics_screen.dart';
import '../shared/widgets/bottom_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final isAuth = authState.value != null;
      final isGoingToAuth = state.matchedLocation == '/auth' || state.matchedLocation == '/onboarding' || state.matchedLocation == '/splash';

      if (!isAuth && !isGoingToAuth) {
        return '/auth';
      }

      if (isAuth && isGoingToAuth) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/create-trip',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateTripScreen(),
      ),
      GoRoute(
        path: '/trip/:id/builder',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ItineraryBuilderScreen(
          tripId: state.pathParameters['id'] ?? '123',
        ),
      ),
      GoRoute(
        path: '/search/activities',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ActivitySearchScreen(
          city: (state.extra as Map<String, dynamic>?)?['city'] ?? 'Destinations',
        ),
      ),
      GoRoute(
        path: '/budget',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BudgetAnalyticsScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) => const NoTransitionPage(child: ExploreScreen()),
          ),
          GoRoute(
            path: '/my-trips',
            pageBuilder: (context, state) => const NoTransitionPage(child: MyTripsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});
