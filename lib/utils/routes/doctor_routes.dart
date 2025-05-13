import 'package:CuraDocs/features/doctor/appointment/patient_profile.dart';
import 'package:CuraDocs/features/doctor/appointment/reschedule_screen.dart';
import 'package:CuraDocs/features/doctor/appointment/schedule_screen.dart';
import 'package:CuraDocs/features/doctor/appointment/scheduling_details.dart';
import 'package:CuraDocs/features/doctor/settings/_edit_profile.dart';
import 'package:CuraDocs/features/doctor/settings/_profile_and_settings.dart';
import 'package:CuraDocs/features/doctor/settings/_qr_screen.dart';
import 'package:CuraDocs/features/doctor/settings/_security_and_login.dart';

import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:CuraDocs/utils/routes/components/navigation_keys.dart';

// DOCTOR
// chat
import 'package:CuraDocs/features/doctor/chat/_chat_screen.dart';
import 'package:CuraDocs/features/doctor/chat/_chat_home.dart';
import 'package:CuraDocs/features/doctor/chat/entities/_chat_data.dart';
// chatbot
import 'package:CuraDocs/features/doctor/curabot/_chat_bot_home.dart';
import 'package:CuraDocs/features/doctor/curabot/_chat_history.dart';
import 'package:CuraDocs/features/doctor/curabot/_chat_with_ai.dart';
// home
import 'package:CuraDocs/features/doctor/home_screen/_home_screen_doc.dart';
import 'package:CuraDocs/features/doctor/home_screen/_notification.dart';
// appointment
import 'package:CuraDocs/features/doctor/appointment/calendar_schedule_screen.dart';
// my patients
import 'package:CuraDocs/features/doctor/my_patients/_patients_screen.dart';
// settings
import 'package:CuraDocs/utils/routes/components/doctor_navigation_bar.dart';
import 'package:CuraDocs/features/doctor/settings/_personal_profile.dart';

List<RouteBase> get doctorRoutes {
  return [
    // Chatbot routes
    GoRoute(
      path: '/doctor/cura-bot',
      name: RouteConstants.doctorChatBot,
      builder: (context, state) => ChatBotAssistantHome(),
      routes: [
        // Chat with AI
        GoRoute(
          path: 'screen',
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.doctorChatBotScreen,
          builder: (context, state) => DoctorBotScreen(),
        ),
        GoRoute(
          path: 'history',
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.doctorChatBotHistory,
          builder: (context, state) => DoctorBotHistory(
              // text: '',
              ),
        ),
      ],
    ),

    // Main app shell with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return DoctorBottomNavigation(navigationShell: navigationShell);
      },
      branches: [
        // Home Branch
        StatefulShellBranch(
          navigatorKey: doctorHomeNavigatorKey,
          routes: [
            GoRoute(
              path: '/doctor/home',
              name: RouteConstants.doctorHome,
              builder: (context, state) => const DoctorHomeScreen(),
              routes: [
                GoRoute(
                  path: 'notifications',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorNotifications,
                  builder: (context, state) => const DoctorNotificationScreen(),
                ),
              ],
            ),
          ],
        ),

        // My patients of doctor side
        StatefulShellBranch(
          navigatorKey: doctorPatientsNavigatorKey,
          routes: [
            GoRoute(
              path: '/doctor/my-patients',
              name: RouteConstants.doctorMyPatients,
              builder: (context, state) => const MyPatientsScreen(),
              routes: [
                // GoRoute(
                //   path: '/doctor/my-patients',
                //   parentNavigatorKey: rootNavigatorKey,
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

        // Bookings Branch
        StatefulShellBranch(
          navigatorKey: doctorBookingsNavigatorKey,
          routes: [
            GoRoute(
              path: '/doctor/schedule',
              name: RouteConstants.doctorSchedule,
              builder: (context, state) => const DoctorScheduleScreen(),
              routes: [
                GoRoute(
                  path: 'calendar',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorScheduleCalendar,
                  builder: (context, state) => const DoctorCalendarSchedule(),
                ),
                GoRoute(
                  path: 'doctor-reschedule-appointment',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorRescheduleAppointment,
                  builder: (context, state) =>
                      const DoctorRescheduleAppointment(),
                  //  {

                  // final appointment = state.extra as AppointmentData;
                  // return DoctorRescheduleAppointment(
                  //   appointment: appointment,
                  // );
                  // },
                ),
                GoRoute(
                  path: 'patient-profile',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorPatientProfile,
                  builder: (context, state) => const DoctorPatientProfile(),
                  // {
                  // final patient = state.extra as PatientData;
                  // return DoctorPatientProfile(patient: patient);
                  // },
                ),
                GoRoute(
                  path: 'scheduling-appointment-details',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorSchedulingAppointmentDetails,
                  builder: (context, state) =>
                      const AppointmentSchedulingDetails(),
                  // {
                  //   final appointment = state.extra as AppointmentData;
                  //   return DoctorSchedulingAppointmentDetails(
                  //     appointment: appointment,
                  //   );
                  // },
                ),
              ],
            ),
          ],
        ),

        // Chat Branch
        StatefulShellBranch(
          navigatorKey: doctorChatNavigatorKey,
          routes: [
            GoRoute(
              path: '/doctor/chat',
              name: RouteConstants.doctorChat,
              builder: (context, state) => const DoctorChatListScreen(),
              routes: [
                GoRoute(
                  // Individual Chat Screen
                  path: 'chat-screen',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorChatScreen,
                  builder: (context, state) {
                    final chat = state.extra as DocChatData;
                    return DoctorChatScreen(chat: chat);
                  },
                ),
              ],
            ),
          ],
        ),

        // My patients of doctor side
        StatefulShellBranch(
          navigatorKey: doctorProfileNavigatorKey,
          routes: [
            GoRoute(
              path: '/doctor/profile-and-settings',
              name: RouteConstants.doctorProfileSettings,
              builder: (context, state) => DoctorProfileSettings(),
              routes: [
                GoRoute(
                  // Settings Screen
                  path: 'security-settings',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorSecuritySettings, // under review
                  builder: (context, state) =>
                      const DoctorSecurityAndLoginSettings(),
                ),
                GoRoute(
                  path: 'edit-profile',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorEditProfile,
                  builder: (context, state) => const DoctorEditProfile(),
                ),
                GoRoute(
                  path: 'personal-profile',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorPersonalProfile,
                  builder: (context, state) => const DoctorPersonalProfile(),
                ),
                GoRoute(
                  path: 'profileQR',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorQRCode,
                  builder: (context, state) => const DoctorQR(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}
