# 📘 Day 40: Declarative Routing with go_router: ShellRoutes & Navigation Guards

**Module 01:** [Navigation Mechanics, Declarative Routing & Navigation Guards](../README.md) • **Phase 05:** [Navigation, Declarative Routing & Deep Linking](../../README.md)

> [!NOTE]
> **Lesson Objective:** Master declarative URL-driven routing with go_router. Learn path/query parameter parsing, multi-tab persistent navigation with StatefulShellRoute.indexedStack, authentication guards with dynamic redirect resolution and refreshListenable, and customized error handling.

**Tags:** `Flutter` `Navigation` `go_router` `Declarative` `ShellRoute` `Guards` `Redirect` `Deep Linking` `Architecture`

---

## 🚦 Prerequisites
Imperative Navigation Mechanics, Transitions & Hero Animations; State Management & BLoC/Cubit Architecture; Flutter Widgets & Layouts.
You should understand the Navigator stack, authentication state management, and widget composition.

## 📖 Overview
In traditional Imperative Navigation (`Navigator 1.0`), routes are pushed and popped explicitly in response to user actions. While effective for simple mobile flows, imperative navigation breaks down in modern multi-platform applications:
- **Web Browser URL Desynchronization**: In a Flutter web app, pushing screens imperatively does not update the browser URL bar or support the browser's native Back, Forward, and Refresh buttons.
- **Deep Linking Fragility**: Directly opening `myapp://products/99` requires manually orchestrating a sequence of imperative `push()` calls to recreate the backstack history.
- **State-Driven Routing**: Routing often depends directly on state (e.g., when the user's authentication token expires, the app should automatically transition to the login route regardless of where the user is).

**Declarative Routing** shifts the mental model: **The UI route is a pure function of application state and URL path**. Instead of telling the framework *how* to transition to a screen, you declare *what* screen corresponds to each URL pattern.

In the Flutter ecosystem, **`package:go_router`** is the official, Google-maintained declarative routing library.

## 📚 Topics Covered
* **1. The Declarative Routing Paradigm**: In a Flutter web app, pushing screens imperatively does not update the browser URL bar or support the browser's native Back, Forward, and...
* **2. Core go_router Architecture**: The starting route path when the app launches (e.g. `'/'`).
* **3. Navigation Guards & Authentication Redirection**: `redirect: (BuildContext context, GoRouterState state)`
* **4. Persistent Shell Navigation: StatefulShellRoute.indexedStack**: Tapping Tab 1, scrolling down 500px, switching to Tab 2, and switching back to Tab 1 must **preserve the 500px scroll position**.

## 🎯 Implementation Objective
Build a production-grade Enterprise App Shell in Flutter using `package:go_router`. Demonstrate declarative route configuration, path parameter parsing (`:id`), query parameter extraction (`?filter=active`), reactive authentication redirect guards via `refreshListenable`, and persistent multi-branch bottom navigation using `StatefulShellRoute.indexedStack`.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const GoRouterEnterpriseApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. REACTIVE AUTHENTICATION STATE
// ─────────────────────────────────────────────────────────────────────────────

class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _userRole = 'Guest';

  bool get isAuthenticated => _isAuthenticated;
  String get userRole => _userRole;

  void login(String role) {
    _isAuthenticated = true;
    _userRole = role;
    notifyListeners(); // Triggers GoRouter re-evaluation via refreshListenable!
  }

  void logout() {
    _isAuthenticated = false;
    _userRole = 'Guest';
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. DECLARATIVE GOROUTER CONFIGURATION
// ─────────────────────────────────────────────────────────────────────────────

class AppRouterConfig {
  final AuthNotifier authNotifier;

  AppRouterConfig(this.authNotifier);

  late final GoRouter router = GoRouter(
    initialLocation: '/home',
    refreshListenable: authNotifier,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authNotifier.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      // 1. Guard protected profile routes
      final isProtected = state.matchedLocation.startsWith('/profile');
      if (!isLoggedIn && isProtected) {
        return '/login?redirect=${state.matchedLocation}';
      }

      // 2. Prevent logged in users from seeing login screen
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null; // Proceed normally
    },
    routes: [
      // Standalone Login Route
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          final returnUrl = state.uri.queryParameters['redirect'];
          return LoginScreen(returnUrl: returnUrl);
        },
      ),

      // Multi-Branch Persistent Shell for Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffoldShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeTabScreen(),
                routes: [
                  // Nested Sub-Route with Path and Query Parameters!
                  GoRoute(
                    path: 'article/:id',
                    name: 'article_detail',
                    builder: (context, state) {
                      final articleId = state.pathParameters['id'] ?? 'unknown';
                      final category = state.uri.queryParameters['cat'] ?? 'general';
                      return ArticleDetailScreen(id: articleId, category: category);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Explore Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                name: 'explore',
                builder: (context, state) => const ExploreTabScreen(),
              ),
            ],
          ),

          // Branch 3: Profile Tab (Protected by Redirect Guard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileTabScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('404 Not Found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text('No route defined for: ${state.uri.path}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: const Text('Return to Safety (Home)'),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. PRESENTATION LAYER & SHELL
// ─────────────────────────────────────────────────────────────────────────────

final globalAuth = AuthNotifier();
final appRouterConfig = AppRouterConfig(globalAuth);

class GoRouterEnterpriseApp extends StatelessWidget {
  const GoRouterEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Declarative go_router Architecture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      routerConfig: appRouterConfig.router,
    );
  }
}

class AppScaffoldShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffoldShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // Houses the persistent IndexedStack of branches!
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          // Switches branches while preserving each branch's scroll & state!
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Feed (Stateful Branch)')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 20,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text('Architecture Article #${index + 1}'),
              subtitle: const Text('Scroll down, switch tabs, return -> Scroll preserved!'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                // Navigate to sub-route with path parameter and query parameter
                context.goNamed(
                  'article_detail',
                  pathParameters: {'id': '${index + 1}'},
                  queryParameters: {'cat': 'flutter_core'},
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final String id;
  final String category;

  const ArticleDetailScreen({super.key, required this.id, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Article #$id')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(6)),
              child: Text('CATEGORY: ${category.toUpperCase()}', style: TextStyle(color: Colors.deepPurple.shade700, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            const SizedBox(height: 16),
            Text('Article #$id Deep Link Details', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'This screen was resolved via declarative path parameters (:id) and query parameters (?cat=). '
              'Notice that the BottomNavigationBar remains visible and active because this is nested inside StatefulShellBranch!',
              style: TextStyle(height: 1.5),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Return to Feed (context.go)'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreTabScreen extends StatelessWidget {
  const ExploreTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Topics')),
      body: const Center(
        child: Text('Explore Tab Content (Independent Navigation Stack)'),
      ),
    );
  }
}

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protected Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log Out',
            onPressed: () => globalAuth.logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user_rounded, size: 72, color: Colors.green),
            const SizedBox(height: 16),
            Text('Welcome, ${globalAuth.userRole}!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('You have accessed a protected route guarded by GoRouter redirect.'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => globalAuth.logout(),
              child: const Text('Sign Out (Triggers Redirect to Login)'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final String? returnUrl;

  const LoginScreen({super.key, this.returnUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication Gate')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_person_rounded, size: 64, color: Colors.deepPurple),
              const SizedBox(height: 16),
              const Text('Sign In Required', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                returnUrl != null ? 'Attempting to access protected route:
$returnUrl' : 'Please sign in to proceed.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  globalAuth.login('Senior Engineer');
                  if (returnUrl != null) {
                    context.go(returnUrl!);
                  } else {
                    context.go('/home');
                  }
                },
                icon: const Icon(Icons.login_rounded),
                label: const Text('Authenticate as Senior Engineer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 💡 Deep-Dive Materials Included

* **3 Interview Prep Scenarios** included
* **Technology Comparisons:** context.go() vs context.push() in go_router, ShellRoute vs StatefulShellRoute.indexedStack
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 39: Imperative Navigation Mechanics, Transitions & Hero Animations](../Day-39/README.md) | [📂 Module Index](../README.md) | [Day 41: Advanced Routing Architectures: Deep Linking & AutoRoute ➡️](../Day-41/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

