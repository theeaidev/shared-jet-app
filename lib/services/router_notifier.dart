import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:devtodollars/components/dialog_page.dart';
import 'package:devtodollars/components/reset_password_dialog.dart';
import 'package:devtodollars/screens/auth_screen.dart';
import 'package:devtodollars/screens/home_screen.dart';
import 'package:devtodollars/screens/intro_screen.dart';
import 'package:devtodollars/screens/payments_screen.dart';
import 'package:devtodollars/services/auth_notifier.dart';

part 'router_notifier.g.dart';

// This is crucial for making sure that the same navigator is used
// when rebuilding the GoRouter and not throwing away the whole widget tree.
final navigatorKey = GlobalKey<NavigatorState>();
Uri? initUrl = Uri.base; // needed to set intiial url state

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    initialLocation: initUrl?.path, // DO NOT REMOVE
    navigatorKey: navigatorKey,
    redirect: (context, state) async {
      return authState.when(
        data: (user) {
          // build initial path
          // Path variable removed because the routing uses absolute paths now
          final isLoggingIn = state.uri.path == '/login';
          final isIntro = state.uri.path == '/intro';

          if (user == null) {
            if (isLoggingIn || isIntro) {
              return null; // Allowed unauthenticated routes
            }
            return '/intro'; // Otherwise go to intro
          } else {
            if (isLoggingIn || isIntro || state.uri.path == '/loading') {
              return '/'; // If authenticated, cannot visit login/intro/loading
            }
            return null;
          }
        },
        error: (_, __) => "/loading",
        loading: () => "/loading",
      );
    },
    routes: <RouteBase>[
      GoRoute(
        name: 'loading',
        path: '/loading',
        builder: (context, state) {
          return const Center(child: CircularProgressIndicator());
        },
      ),
      GoRoute(
        name: 'intro',
        path: '/intro',
        builder: (context, state) {
          return const IntroScreen();
        },
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) {
          return const AuthScreen();
        },
      ),
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) {
          return const HomeScreen(title: "Share Jet");
        },
        routes: [
          GoRoute(
            name: 'reset',
            path: 'reset',
            pageBuilder: (_, __) {
              return const DialogPage(child: ResetPasswordDialog());
            },
          )
        ],
      ),
      GoRoute(
        name: 'payments',
        path: '/payments',
        builder: (BuildContext context, GoRouterState state) {
          final qp = state.uri.queryParameters;
          return PaymentsScreen(price: qp["price"]);
        },
      ),
    ],
  );
}
