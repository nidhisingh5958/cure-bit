import 'package:CuraDocs/features/auth/screens/signUp/sign_up_screen.dart';
import 'package:CuraDocs/features/auth/landing/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:CuraDocs/features/auth/landing/role.dart';
import 'package:CuraDocs/features/auth/screens/login/forgot_pass.dart';
import 'package:CuraDocs/features/auth/screens/login/login_screen.dart';
import 'package:CuraDocs/features/auth/landing/onboarding_screen.dart';
import 'package:CuraDocs/features/auth/screens/login/otp.dart';

// PATIENT
// appointment
import 'package:CuraDocs/features/patient/appointment/appointment_screen.dart';
import 'package:CuraDocs/features/patient/appointment/book_appointment.dart';
// chatbot
import 'package:CuraDocs/features/patient/curabot/chat_bot_home.dart';
import 'package:CuraDocs/features/patient/curabot/chat_with_ai.dart';
import 'package:CuraDocs/features/patient/curabot/bot_history.dart' as patient;
// chat
import 'package:CuraDocs/features/patient/chat/chat_home.dart';
import 'package:CuraDocs/features/patient/chat/chat_screen.dart';
import '../../features/patient/chat/entities/chat_data.dart';
// documents
import 'package:CuraDocs/features/patient/documents/add_document.dart';
import 'package:CuraDocs/features/patient/documents/document_screen.dart';
import 'package:CuraDocs/features/patient/documents/prescription.dart';
import 'package:CuraDocs/features/patient/documents/test_records.dart';
// home
import 'package:CuraDocs/features/patient/home_screen/home_screen.dart';
import 'package:CuraDocs/features/patient/home_screen/notification.dart';
import 'package:CuraDocs/features/patient/medicine.dart/medicine_screen.dart';
import 'package:CuraDocs/features/patient/home_screen/search_screen.dart';
// settings
import 'package:CuraDocs/utils/routes/patient_navigation_bar.dart';
import 'package:CuraDocs/features/patient/settings/profile_screen.dart';

// DOCTOR
// chatbot
import 'package:CuraDocs/features/doctor/curabot/_chat_bot_home.dart';
import 'package:CuraDocs/features/doctor/curabot/_chat_history.dart';
import 'package:CuraDocs/features/doctor/curabot/_chat_with_ai.dart';
// home
import 'package:CuraDocs/features/doctor/home_screen/_home_screen_doc.dart';
import 'package:CuraDocs/features/doctor/home_screen/_notification.dart';
import 'package:CuraDocs/features/doctor/home_screen/_search_screen.dart';
// appointment
import 'package:CuraDocs/features/doctor/appointment/appointment_screen.dart';
// my patients
import 'package:CuraDocs/features/doctor/my_patients.dart/patients_screen.dart';
// settings
import 'package:CuraDocs/utils/routes/doctor_navigation_bar.dart';
import 'package:CuraDocs/features/doctor/settings/profile_screen.dart';

// Navigation keys for each branch
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
// keys for patient routes
// final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _chatNavigatorKey = GlobalKey<NavigatorState>();
final _documentsNavigatorKey = GlobalKey<NavigatorState>();
final _profileNavigatorKey = GlobalKey<NavigatorState>();
// keys for doctor routes
final _doctorHomeNavigatorKey = GlobalKey<NavigatorState>();
final _doctorChatNavigatorKey = GlobalKey<NavigatorState>();
final _doctorProfileNavigatorKey = GlobalKey<NavigatorState>();
final _doctorPatientsNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  // SharedPreferences keys
  static const String _isFirstLaunchKey = 'isFirstLaunch';
  static const String _isAuthenticatedKey = 'isAuthenticated';
  static const String _userRoleKey = 'userRole';

  static late bool _isFirstLaunch;
  static late bool _isAuthenticated;
  static late String _userRole;

  // Initialize the router with necessary checks
  static Future<GoRouter> initRouter() async {
    // Load preferences
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool(_isFirstLaunchKey) ?? true;
    _isAuthenticated = prefs.getBool(_isAuthenticatedKey) ?? false;
    _userRole = prefs.getString(_userRoleKey) ?? 'Patient';

    // If this is the first launch, set the flag for future
    if (_isFirstLaunch) {
      await prefs.setBool(_isFirstLaunchKey, false);
    }

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/role',
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

// Patients routes
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
            GoRoute(
              path: 'history',
              parentNavigatorKey: _rootNavigatorKey,
              name: RouteConstants.chatBotHistory,
              builder: (context, state) => const patient.BotHistory(),
            ),
          ],
        ),

        // Doctor search
        GoRoute(
          path: '/doctor-search',
          name: RouteConstants.doctorSearch,
          builder: (context, state) => DoctorSearchScreen(
            map: {},
          ),
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
                  path: 'documents',
                  name: RouteConstants.documents,
                  builder: (context, state) => const DocumentScreen(),
                  routes: [],
                ),
              ],
            ),
            // Profile Branch
            StatefulShellBranch(
              navigatorKey: _profileNavigatorKey,
              routes: [
                GoRoute(
                  path: 'profile',
                  name: RouteConstants.profile,
                  builder: (context, state) => ProfileScreen(),
                ),
              ],
            ),
          ],
        ),

// Doctor routes
        // Chatbot routes
        GoRoute(
          path: '/doctor/cura-bot',
          name: RouteConstants.doctorChatBot,
          builder: (context, state) => ChatBotAssistantHome(),
          routes: [
            // Chat with AI
            GoRoute(
              path: 'screen',
              parentNavigatorKey: _rootNavigatorKey,
              name: RouteConstants.doctorChatBotScreen,
              builder: (context, state) => DoctorBotScreen(),
            ),
            GoRoute(
              path: 'history',
              parentNavigatorKey: _rootNavigatorKey,
              name: RouteConstants.doctorChatBotHistory,
              builder: (context, state) => DoctorBotHistory(
                  // text: '',
                  ),
            ),
          ],
        ),

        GoRoute(
          path: '/doctor/schedule',
          name: RouteConstants.doctorSchedule,
          builder: (context, state) => const DoctorScheduleScreen(),
        ),

        // Main app shell with bottom navigation
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return DoctorBottomNavigation(navigationShell: navigationShell);
          },
          branches: [
            // Home Branch
            StatefulShellBranch(
              navigatorKey: _doctorHomeNavigatorKey,
              routes: [
                GoRoute(
                  path: '/doctor/home',
                  name: RouteConstants.doctorHome,
                  builder: (context, state) => const DoctorHomeScreen(),
                  routes: [
                    GoRoute(
                      path: 'notifications',
                      parentNavigatorKey: _rootNavigatorKey,
                      name: RouteConstants.doctorNotifications,
                      builder: (context, state) =>
                          const DoctorNotificationScreen(),
                    ),
                  ],
                ),
              ],
            ),

            // Chat Branch
            StatefulShellBranch(
              navigatorKey: _doctorChatNavigatorKey,
              routes: [
                GoRoute(
                  path: '/doctor/chat',
                  name: RouteConstants.doctorChat,
                  builder: (context, state) => const ChatListScreen(),
                  routes: [
                    GoRoute(
                      // Individual Chat Screen
                      path: 'chat-screen',
                      parentNavigatorKey: _rootNavigatorKey,
                      name: RouteConstants.doctorChatScreen,
                      builder: (context, state) {
                        final chat = state.extra as ChatData;
                        return ChatScreen(chat: chat);
                      },
                    ),
                  ],
                ),
              ],
            ),

            // My patients of doctor side
            StatefulShellBranch(
              navigatorKey: _doctorPatientsNavigatorKey,
              routes: [
                GoRoute(
                  path: '/doctor/my-patients',
                  name: RouteConstants.doctorMyPatients,
                  builder: (context, state) => const PatientsListScreen(),
                  routes: [
                    // GoRoute(
                    //   path: '/doctor/my-patients',
                    //   parentNavigatorKey: _rootNavigatorKey,
                    //   name: RouteConstants.doctorMyPatients,
                    //   builder: (context, state) {
                    //     final chat = state.extra as ChatData;
                    //     return ChatScreen(chat: chat);
                    //   },
                    // ),
                  ],
                ),
              ],
            ),

            // My patients of doctor side
            StatefulShellBranch(
              navigatorKey: _doctorProfileNavigatorKey,
              routes: [
                GoRoute(
                  path: '/doctor/profile',
                  name: RouteConstants.doctorProfile,
                  builder: (context, state) => DoctorProfileScreen(),
                  routes: [
                    // GoRoute(
                    //   path: '/doctor/my-patients',
                    //   parentNavigatorKey: _rootNavigatorKey,
                    //   name: RouteConstants.doctorMyPatients,
                    //   builder: (context, state) {
                    //     final chat = state.extra as ChatData;
                    //     return ChatScreen(chat: chat);
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
          ],
          // Redirect logic
          redirect: (BuildContext context, GoRouterState state) {
            // Always allow access to splash screen
            if (state.matchedLocation == '/') {
              return null;
            }

            // Check if user is trying to access auth routes
            final isGoingToAuthRoute = state.matchedLocation == '/login' ||
                state.matchedLocation.startsWith('/login/') ||
                state.matchedLocation == '/sign-up' ||
                state.matchedLocation == '/onboarding' ||
                state.matchedLocation == '/role';

            // If authenticated, prevent going to auth routes
            if (_isAuthenticated && isGoingToAuthRoute) {
              // Redirect to the appropriate dashboard based on role
              return _userRole == 'Doctor' ? '/doctor/home' : '/home';
            }

            // If not authenticated, prevent access to protected routes
            if (!_isAuthenticated && !isGoingToAuthRoute) {
              // First-time users should see onboarding
              if (_isFirstLaunch) {
                return '/onboarding';
              }
              // Send to role selection first
              return '/role';
            }

            // No redirects needed
            return null;
          },
        ),
      ],
      refreshListenable: AuthStateNotifier(),
    );
  }

  // Method to set user as authenticated
  static Future<void> setAuthenticated(bool value, [String? role]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAuthenticatedKey, value);
    _isAuthenticated = value;

    // If role is provided, save it
    if (role != null) {
      await prefs.setString(_userRoleKey, role);
      _userRole = role;
    }

    // Notify listeners to refresh the router
    AuthStateNotifier().notifyListeners();
  }

  // Method to get the current user role
  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey) ?? 'Patient';
  }
}

// Class to notify the router when auth state changes
class AuthStateNotifier extends ChangeNotifier {
  static final AuthStateNotifier _instance = AuthStateNotifier._internal();

  factory AuthStateNotifier() => _instance;

  AuthStateNotifier._internal();

  // Override to prevent potential memory issues
  @override
  void dispose() {
    // Don't call super.dispose() as this is a singleton
  }
}

// Initialize the router
final routerFuture = AppRouter.initRouter();
