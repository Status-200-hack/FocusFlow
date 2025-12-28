import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/screens/onboarding_screen.dart';
import 'package:focusflow/screens/login_screen.dart';
import 'package:focusflow/screens/signup_screen.dart';
import 'package:focusflow/screens/home_screen.dart';
import 'package:focusflow/screens/task_detail_screen.dart';
import 'package:focusflow/screens/focus_screen.dart';
import 'package:focusflow/screens/profile_screen.dart';
import 'package:focusflow/screens/ai_assistant_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final userService = context.read<UserService>();
      final isFirstLaunch = await userService.isFirstLaunch();
      final isAuthenticated = userService.isAuthenticated;

      if (state.matchedLocation == '/') {
        if (isFirstLaunch) return '/onboarding';
        if (!isAuthenticated) return '/login';
        return '/home';
      }

      if (state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/signup')) {
        if (isAuthenticated) return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SignUpScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 0.05), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: '/task/:id',
        pageBuilder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return CustomTransitionPage(
            child: TaskDetailScreen(taskId: taskId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                  ),
                  child: child,
                ),
              ),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 400),
          );
        },
      ),
      GoRoute(
        path: '/focus',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const FocusScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 0.05), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 0.05), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: '/ai',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AiAssistantScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 0.05), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
    ],
  );
}
