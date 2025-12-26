import 'package:go_router/go_router.dart';
import 'package:d_hawk/screens/auth/login_screen.dart';
import 'package:d_hawk/screens/auth/register_screen.dart';
import 'package:d_hawk/screens/auth/forgot_password_screen.dart';
import 'package:d_hawk/screens/home/dashboard_screen.dart';
import 'package:d_hawk/screens/security/threats_screen.dart';
import 'package:d_hawk/screens/security/threat_detail_screen.dart';
import 'package:d_hawk/screens/security/scan_screen.dart';
import 'package:d_hawk/screens/security/scan_history_screen.dart';
import 'package:d_hawk/screens/monitoring/monitoring_screen.dart';
import 'package:d_hawk/screens/reports/reports_screen.dart';
import 'package:d_hawk/screens/analytics/analytics_screen.dart';
import 'package:d_hawk/screens/settings/settings_screen.dart';
import 'package:d_hawk/screens/profile/profile_screen.dart';
import 'package:d_hawk/core/utils/storage_helper.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = StorageHelper.getToken() != null;
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/threats',
        builder: (context, state) => const ThreatsScreen(),
      ),
      GoRoute(
        path: '/threat-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ThreatDetailScreen(threatId: id);
        },
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: '/scan-history',
        builder: (context, state) => const ScanHistoryScreen(),
      ),
      GoRoute(
        path: '/monitoring',
        builder: (context, state) => const MonitoringScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}

