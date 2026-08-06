import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/curriculum/screens/days_screen.dart';
import '../../features/curriculum/screens/modules_screen.dart';
import '../../features/curriculum/screens/phases_screen.dart';
import '../../features/lesson/screens/lesson_screen.dart';

/// Central GoRouter configuration for the Flutter AI Tutor app.
///
/// All routes use a right-to-left [SlideTransition] animation for a native
/// mobile feel. Route parameters are passed as integers via path parameters.
///
/// Route tree:
/// ```
/// /phases                                           → PhasesScreen
/// /phases/:phaseId/modules                          → ModulesScreen
/// /phases/:phaseId/modules/:moduleId/days           → DaysScreen
/// /phases/:phaseId/modules/:moduleId/days/:day      → LessonScreen
/// ```
@singleton
class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/phases',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/phases',
        name: 'phases',
        pageBuilder: (context, state) =>
            _slide(state, child: const PhasesScreen()),
        routes: [
          GoRoute(
            path: ':phaseId/modules',
            name: 'modules',
            pageBuilder: (context, state) {
              final phaseId = int.parse(state.pathParameters['phaseId']!);
              return _slide(state, child: ModulesScreen(phaseId: phaseId));
            },
            routes: [
              GoRoute(
                path: ':moduleId/days',
                name: 'days',
                pageBuilder: (context, state) {
                  final phaseId = int.parse(state.pathParameters['phaseId']!);
                  final moduleId = int.parse(state.pathParameters['moduleId']!);
                  return _slide(
                    state,
                    child: DaysScreen(phaseId: phaseId, moduleId: moduleId),
                  );
                },
                routes: [
                  GoRoute(
                    path: ':day',
                    name: 'lesson',
                    pageBuilder: (context, state) {
                      final phaseId = int.parse(
                        state.pathParameters['phaseId']!,
                      );
                      final moduleId = int.parse(
                        state.pathParameters['moduleId']!,
                      );
                      final day = int.parse(state.pathParameters['day']!);
                      return _slide(
                        state,
                        child: LessonScreen(
                          phaseId: phaseId,
                          moduleId: moduleId,
                          day: day,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  /// Builds a [CustomTransitionPage] with a right-to-left slide animation.
  CustomTransitionPage<void> _slide(
    GoRouterState state, {
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
    );
  }
}
