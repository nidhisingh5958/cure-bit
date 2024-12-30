import 'package:cure_bit/screens/chat_bot_screen.dart';
import 'package:cure_bit/screens/chat_screen.dart';
import 'package:cure_bit/screens/document_screen.dart';
import 'package:cure_bit/screens/forgot_pass/forgot_pass.dart';
import 'package:cure_bit/screens/home_screen.dart';
import 'package:cure_bit/screens/login/login_screen.dart';
import 'package:cure_bit/screens/onboarding_screen.dart';
import 'package:cure_bit/screens/otp.dart';
import 'package:cure_bit/screens/profile_screen.dart';
import 'package:cure_bit/screens/sign_up_screen.dart';
import 'package:cure_bit/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cure_bit/components/routes/route_constants.dart';

class AppRouter {
  GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: RouteConstants.splash,
        path: '/splash',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: SplashScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteConstants.onboarding,
        path: '/onboarding',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: OnboardingScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteConstants.forgotPass,
        path: '/forgot-password',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: ForgotPasswordScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteConstants.login,
        path: '/login',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: LoginScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteConstants.signUp,
        path: '/sign-up',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: SignUpScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteConstants.otp,
        path: '/otp',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: OtpScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteConstants.home,
        path: '/',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: HomeScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteConstants.chatBot,
        path: '/chat-bot',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: ChatBotScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteConstants.chat,
        path: '/chat',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: ChatScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteConstants.profile,
        path: '/profile',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: ProfileScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteConstants.documents,
        path: '/documents',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: DocumentsScreen(),
          );
        },
      ),
    ],
    // redirect: (context, state) {
    //   bool isAuthenticated = true;
    //   if (!isAuthenticated) {
    //     return state.namedLocation(RouteConstants.login);
    //   }
    //   return null;
    // },
  );
}
