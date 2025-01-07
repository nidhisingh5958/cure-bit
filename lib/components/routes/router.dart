import 'package:cure_bit/components/routes/navigation_bar.dart';
import 'package:cure_bit/screens/chat/chat_home.dart';
import 'package:cure_bit/screens/chatbot/chat_bot_home.dart';
import 'package:cure_bit/screens/chatbot/chat_with_ai.dart';
import 'package:cure_bit/screens/chat/chat_screen.dart';
import 'package:cure_bit/screens/document_screen.dart';
import 'package:cure_bit/screens/forgot_pass/forgot_pass.dart';
import 'package:cure_bit/screens/home_screen/home_screen.dart';
import 'package:cure_bit/screens/login/login_screen.dart';
import 'package:cure_bit/screens/onboarding_screen.dart';
import 'package:cure_bit/screens/otp.dart';
import 'package:cure_bit/screens/settings/profile_screen.dart';
import 'package:cure_bit/screens/signUp/sign_up_screen.dart';
import 'package:cure_bit/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cure_bit/components/routes/route_constants.dart';
import '../../screens/chat/entities/chat_data.dart';

// Navigation keys for each branch
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _chatNavigatorKey = GlobalKey<NavigatorState>();
final _chatbotNavigatorKey = GlobalKey<NavigatorState>();
final _documentsNavigatorKey = GlobalKey<NavigatorState>();
final _profileNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  debugLogDiagnostics: true,
  routes: [
    // Auth and onboarding routes (outside shell)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: RouteConstants.splash,
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: RouteConstants.onboarding,
      path: '/onboarding',
      builder: (context, state) => OnboardingScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: RouteConstants.login,
      path: '/login',
      builder: (context, state) => LoginScreen(),
      routes: [
        GoRoute(
          name: RouteConstants.forgotPass,
          path: 'forgot-password',
          builder: (context, state) => ForgotPasswordScreen(),
        ),
        GoRoute(
          name: RouteConstants.signUp,
          path: 'sign-up',
          builder: (context, state) => SignUpScreen(),
        ),
        GoRoute(
          name: RouteConstants.otp,
          path: 'otp',
          builder: (context, state) => OtpScreen(),
        ),
      ],
    ),

    // Main app shell with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavigation(navigationShell: navigationShell);
      },
      branches: [
        // Home Branch
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              name: RouteConstants.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Chat Branch
        StatefulShellBranch(
          navigatorKey: _chatNavigatorKey,
          routes: [
            GoRoute(
              path: '/chat',
              name: RouteConstants.chat,
              builder: (context, state) => const ChatListScreen(),
              routes: [
                GoRoute(
                  path: 'screen',
                  name: RouteConstants.chatScreen,
                  builder: (context, state) {
                    final chat = state.extra as ChatData;
                    return ChatScreen(chat: chat);
                  },
                ),
              ],
            ),
          ],
        ),
        // Chatbot Branch
        StatefulShellBranch(
          navigatorKey: _chatbotNavigatorKey,
          routes: [
            GoRoute(
              path: '/chat-bot',
              name: RouteConstants.chatBot,
              builder: (context, state) => const ChatBotHome(),
              routes: [
                GoRoute(
                  path: 'screen',
                  name: RouteConstants.chatBotScreen,
                  builder: (context, state) => const ChatBotScreen(),
                ),
              ],
            ),
          ],
        ),
        // Documents Branch
        StatefulShellBranch(
          navigatorKey: _documentsNavigatorKey,
          routes: [
            GoRoute(
              path: '/documents',
              name: RouteConstants.documents,
              builder: (context, state) => const DocumentsScreen(),
            ),
          ],
        ),
        // Profile Branch
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              name: RouteConstants.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final bool isAuthenticated = true;
    if (!isAuthenticated &&
        !state.uri.toString().startsWith('/login') &&
        !state.uri.toString().startsWith('/onboarding') &&
        state.uri.toString() != '/') {
      return '/login';
    }
    return null;
  },
);
