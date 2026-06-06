import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/events_screen.dart';
import '../screens/create_event_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/event_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/main_shell.dart';

class RouterNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();
  static final RouterNotifier refreshNotifier = RouterNotifier();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (authProvider.isLoading) return null;
      
      // Basic redirect logic
      if (!authProvider.isAuthenticated) {
        if (state.matchedLocation == '/create-event' || state.matchedLocation == '/dashboard' || state.matchedLocation == '/admin') {
          return '/login';
        }
      }

      // Redirect authenticated users away from login/register
      if (authProvider.isAuthenticated && loggingIn) {
        return '/';
      }
      
      return null;
    },
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/events', builder: (context, state) => const EventsScreen()),
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
          GoRoute(path: '/create-event', builder: (context, state) => const CreateEventScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/event/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventDetailScreen(eventId: id);
        },
      ),
    ],
  );
}
