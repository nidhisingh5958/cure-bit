import 'package:CuraDocs/components/routes/navigation_bar.dart';
import 'package:CuraDocs/role.dart';
import 'package:CuraDocs/screens/appointment/appointment_screen.dart';
import 'package:CuraDocs/screens/appointment/book_appointment.dart';
import 'package:CuraDocs/screens/chat/chat_home.dart';
import 'package:CuraDocs/screens/chatbot/chat_bot_home.dart';
import 'package:CuraDocs/screens/chatbot/chat_with_ai.dart';
import 'package:CuraDocs/screens/chat/chat_screen.dart';
import 'package:CuraDocs/screens/documents/add_document.dart';
import 'package:CuraDocs/screens/documents/document_screen.dart';
import 'package:CuraDocs/screens/documents/prescription.dart';
import 'package:CuraDocs/screens/documents/test_records.dart';
import 'package:CuraDocs/screens/forgot_pass/forgot_pass.dart';
import 'package:CuraDocs/screens/home_screen/home_screen.dart';
import 'package:CuraDocs/screens/home_screen/notification.dart';
import 'package:CuraDocs/screens/login/login_screen.dart';
import 'package:CuraDocs/screens/medicine.dart/medicine_screen.dart';
import 'package:CuraDocs/screens/onboarding_screen.dart';
import 'package:CuraDocs/screens/otp.dart';
import 'package:CuraDocs/screens/settings/profile_screen.dart';
import 'package:CuraDocs/screens/signUp/sign_up_screen.dart';
import 'package:CuraDocs/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:CuraDocs/components/routes/route_constants.dart';
import '../../screens/chat/entities/chat_data.dart';
import '../../screens/signUp/sign_up_profile.dart';

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
      name: RouteConstants.role,
      path: '/role',
      builder: (context, state) => RoleScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: RouteConstants.signUp,
      path: '/sign-up',
      builder: (context, state) => SignUpScreen(),
      routes: [
        GoRoute(
          name: RouteConstants.signUpProfile,
          path: 'sign-up-profile',
          builder: (context, state) => SignUpProfile(),
        ),
      ],
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
          name: RouteConstants.otp,
          path: 'otp',
          builder: (context, state) => OtpScreen(),
        ),
      ],
    ),

    // Chatbot routes
    GoRoute(
      path: '/chat-bot',
      name: RouteConstants.chatBot,
      builder: (context, state) => const ChatBotHome(),
      routes: [
        // Chat with AI
        GoRoute(
          path: 'screen',
          parentNavigatorKey: _rootNavigatorKey,
          name: RouteConstants.chatBotScreen,
          builder: (context, state) => const ChatBotScreen(),
        ),
      ],
    ),

    GoRoute(
      path: '/appointments',
      name: RouteConstants.appointments,
      builder: (context, state) => const AppointmentScreen(),
      routes: [
        GoRoute(
          // Individual doctor booking screen
          path: 'book-appointment',
          parentNavigatorKey: _rootNavigatorKey,
          name: RouteConstants.bookAppointment,
          builder: (context, state) => DoctorProfile(),
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
              routes: [
                GoRoute(
                  path: 'notifications',
                  parentNavigatorKey: _rootNavigatorKey,
                  name: RouteConstants.notifications,
                  builder: (context, state) => const NotificationScreen(),
                ),
                GoRoute(
                  path: 'medicine-reminder',
                  parentNavigatorKey: _homeNavigatorKey,
                  name: RouteConstants.medicineReminder,
                  builder: (context, state) => ReminderScreen(),
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
              path: '/chat',
              name: RouteConstants.chat,
              builder: (context, state) => const ChatListScreen(),
              routes: [
                GoRoute(
                  // Individual Chat Screen
                  path: 'chat-screen',
                  parentNavigatorKey: _rootNavigatorKey,
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

        // Documents Branch
        StatefulShellBranch(
          navigatorKey: _documentsNavigatorKey,
          routes: [
            GoRoute(
              path: '/documents',
              name: RouteConstants.documents,
              builder: (context, state) => const DocumentScreen(),
              routes: [
                // GoRoute(
                //   path: 'prescription',
                //   parentNavigatorKey: _rootNavigatorKey,
                //   name: RouteConstants.prescription,
                //   builder: (context, state) => const Prescription(),
                // ),
                // GoRoute(
                //   path: 'test-results',
                //   parentNavigatorKey: _rootNavigatorKey,
                //   name: RouteConstants.testRecords,
                //   builder: (context, state) => const TestResults(),
                // ),
              ],
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
