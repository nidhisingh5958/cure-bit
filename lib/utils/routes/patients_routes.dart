import 'package:CureBit/services/features_api_repository/profile/public_profile/doctor/get/doctor_model.dart'
    as model;
import 'package:CureBit/features/patient/appointment/my_appointments/reschedule_appointment.dart';
import 'package:CureBit/features/patient/medical_records/basic_medical_info.dart';
import 'package:CureBit/features/patient/home_screen/qr_screen.dart';
import 'package:CureBit/features/patient/settings/public_profile/edit_public_profile.dart';
import 'package:CureBit/features/patient/settings/public_profile/public_profile.dart';
import 'package:CureBit/features/patient/settings/support/help.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:CureBit/utils/routes/components/navigation_keys.dart';

// PATIENT
// appointment
import 'package:CureBit/features/patient/appointment/appointment_home.dart';
import 'package:CureBit/features/patient/appointment/doctor_profile.dart';
import 'package:CureBit/features/patient/appointment/book_appointment.dart';
import 'package:CureBit/features/patient/appointment/my_appointments/my_appointments.dart';
import 'package:CureBit/features/patient/appointment/favourite_doc.dart';
// chatbot
import 'package:CureBit/features/patient/curabot/chat_bot_home.dart';
import 'package:CureBit/features/patient/curabot/chat_with_ai.dart';
import 'package:CureBit/features/patient/curabot/bot_history.dart' as patient;
// chat
import 'package:CureBit/features/patient/chat/chat_home.dart';
import 'package:CureBit/features/patient/chat/chat_screen.dart';
import '../../features/patient/chat/entities/chat_data.dart';
// documents
import 'package:CureBit/features/patient/medical_records/document_screen.dart';
// home
import 'package:CureBit/features/patient/home_screen/home_screen.dart';
import 'package:CureBit/features/patient/home_screen/notification.dart';
import 'package:CureBit/features/patient/medicine.dart/medicine_screen.dart';
import 'package:CureBit/features/patient/home_screen/search_screen.dart';
// settings
import 'package:CureBit/utils/routes/components/patient_navigation_bar.dart';
import 'package:CureBit/features/patient/settings/account_and_settings.dart';
import 'package:CureBit/features/patient/settings/security_and_login.dart';
import 'package:CureBit/features/patient/settings/private_profile/edit_personal_details.dart';
import 'package:CureBit/features/patient/settings/private_profile/account.dart';

List<RouteBase> get patientRoutes {
  return [
    // Chatbot routes
    GoRoute(
      path: '/chat-bot',
      name: RouteConstants.chatBot,
      builder: (context, state) => const ChatBotHome(),
      routes: [
        // Chat with AI
        GoRoute(
          path: 'screen',
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.chatBotScreen,
          builder: (context, state) => const ChatBotScreen(),
        ),
        GoRoute(
          path: 'history',
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.chatBotHistory,
          builder: (context, state) => const patient.BotHistory(),
        ),
      ],
    ),

    GoRoute(
      path: '/help',
      parentNavigatorKey: rootNavigatorKey,
      name: RouteConstants.helpAndSupport,
      builder: (context, state) => HelpScreen(),
    ),

    // Doctor search
    GoRoute(
      path: '/doctor-search',
      name: RouteConstants.doctorSearch,
      builder: (context, state) => DoctorSearchScreen(),
    ),

    GoRoute(
      path: '/doctor-profile',
      name: RouteConstants.doctorProfile,
      builder: (context, state) {
        // Get doctorCin from query parameters or path parameters
        final doctorCin = state.uri.queryParameters['doctorCin'] ??
            state.pathParameters['doctorCin'];

        return DoctorProfile(doctorCin: doctorCin);
      },
    ),

    // Main app shell with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavigation(navigationShell: navigationShell);
      },
      branches: [
        // Home Branch
        StatefulShellBranch(
          navigatorKey: homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              name: RouteConstants.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'notifications',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.notifications,
                  builder: (context, state) => const NotificationScreen(),
                ),
                GoRoute(
                  path: 'medicine-reminder',
                  parentNavigatorKey: homeNavigatorKey,
                  name: RouteConstants.medicineReminder,
                  builder: (context, state) => ReminderScreen(),
                ),
              ],
            ),
          ],
        ),

        // Appointments
        StatefulShellBranch(
          navigatorKey: appointmentsNavigationKey,
          routes: [
            GoRoute(
              path: '/appointments',
              name: RouteConstants.appointmentHome,
              builder: (context, state) => const AppointmentHome(),
              routes: [
                GoRoute(
                  // Individual doctor booking screen
                  path: 'book-appointment',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.bookAppointment,
                  builder: (context, state) {
                    final doctorData = state.extra as model.DoctorProfileModel?;

                    if (doctorData == null) {
                      // Handle null case - redirect to doctors list or show error
                      return const HomeScreen();
                    }

                    return BookAppointmentScreen(
                        doctorData: doctorData.toJson());
                  },
                ),
                GoRoute(
                  path: 'booked-appointments',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.bookedAppointments,
                  builder: (context, state) => const MyAppointments(),
                ),
                GoRoute(
                    path: 'schedule-appointment',
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouteConstants.rescheduleAppointment,
                    builder: (context, state) {
                      // final appointment = state.extra as AppointmentData;
                      return PatientRescheduleAppointment();
                    }),
                GoRoute(
                  path: 'favourites',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.favouriteDoctors,
                  builder: (context, state) => FavouritesPage(),
                ),
              ],
            ),
          ],
        ),

        // Chat Branch
        // StatefulShellBranch(
        //   navigatorKey: chatNavigatorKey,
        //   routes: [
        //     GoRoute(
        //       path: '/chat',
        //       name: RouteConstants.chat,
        //       builder: (context, state) => const ChatListScreen(),
        //       routes: [
        //         GoRoute(
        //           // Individual Chat Screen
        //           path: 'chat-screen',
        //           parentNavigatorKey: rootNavigatorKey,
        //           name: RouteConstants.chatScreen,
        //           builder: (context, state) {
        //             final chat = state.extra as ChatData;
        //             return ChatScreen(chat: chat);
        //           },
        //         ),
        //       ],
        //     ),
        //   ],
        // ),

        // Medical Records Branch
        StatefulShellBranch(
          navigatorKey: documentsNavigatorKey,
          routes: [
            GoRoute(
              path: '/documents',
              name: RouteConstants.documents,
              builder: (context, state) => const DocumentScreen(),
              routes: [
                GoRoute(
                  path: '/patientBasicMedicalInfo',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.patientBasicMedicalInfo,
                  builder: (context, state) => const BasicMedicalInfo(),
                ),
              ],
            ),
          ],
        ),
        // Profile Branch
        StatefulShellBranch(
          navigatorKey: profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile-and-settings',
              name: RouteConstants.profileSettings,
              builder: (context, state) => ProfileScreen(),
              routes: [
                GoRoute(
                  // Settings Screen
                  path: 'security-settings',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.securitySettings,
                  builder: (context, state) => const SecurityAndLoginSettings(),
                ),
                GoRoute(
                  path: 'edit-profile',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.editProfile,
                  builder: (context, state) =>
                      const PatientEditPrivateProfile(),
                ),
                GoRoute(
                  path: 'personal-profile',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.personalProfile,
                  builder: (context, state) => const PersonalProfile(),
                ),
                GoRoute(
                  path: 'public-profile',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.publicProfile,
                  builder: (context, state) => const PatientPublicProfile(),
                ),
                GoRoute(
                    path: 'edit-public-profile',
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouteConstants.editPublicProfile,
                    builder: (context, state) => const EditPublicProfile()),
                GoRoute(
                  path: 'profileQR',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.qrCode,
                  builder: (context, state) => const QrScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}
