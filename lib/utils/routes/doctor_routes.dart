import 'package:CuraDocs/features/doctor/home_screen/_search_screen.dart';
import 'package:CuraDocs/features/doctor/my_patients/all_patients.dart';
import 'package:CuraDocs/features/doctor/my_patients/patient_profile.dart';
import 'package:CuraDocs/features/doctor/settings/private_doc/_account.dart';
import 'package:CuraDocs/features/doctor/settings/private_doc/_edit_personal_details.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/app/auth/auth_middleware.dart';
import 'package:CuraDocs/features/doctor/appointment/_reschedule_screen.dart';
import 'package:CuraDocs/features/doctor/appointment/schedule_screen.dart';
import 'package:CuraDocs/features/doctor/appointment/scheduling_details.dart';
import 'package:CuraDocs/features/doctor/settings/public_doc/_edit_public_profile.dart';
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
import 'package:CuraDocs/features/doctor/settings/public_doc/_public_profile.dart';

List<RouteBase> get doctorRoutes {
  return [
    // Chatbot routes
    GoRoute(
      path: '/doctor/cura-bot',
      name: RouteConstants.doctorChatBot,
      builder: (context, state) => AuthMiddleware(
        requiresAuth: false,
        child: ChatBotAssistantHome(),
      ),
      routes: [
        // Chat with AI
        GoRoute(
          path: 'screen',
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.doctorChatBotScreen,
          builder: (context, state) => AuthMiddleware(
            requiresAuth: false,
            child: DoctorBotScreen(),
          ),
        ),
        GoRoute(
          path: 'history',
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.doctorChatBotHistory,
          builder: (context, state) => AuthMiddleware(
            requiresAuth: false,
            child: DoctorBotHistory(),
          ),
        ),
      ],
    ),

    GoRoute(
      name: RouteConstants.doctorPatientProfile,
      path: '/doctor/patient/profile/:patientCin',
      builder: (context, state) {
        final patientCin = state.pathParameters['patientCin'] ?? '';
        final queryParams = state.uri.queryParameters;

        return PatientProfile(
          patientCin: patientCin,
          // additionalData: queryParams,
        );
      },
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
              builder: (context, state) => AuthMiddleware(
                requiresAuth: false,
                child: DoctorHomeScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'notifications',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorNotifications,
                  builder: (context, state) => AuthMiddleware(
                    requiresAuth: false,
                    child: DoctorNotificationScreen(),
                  ),
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
              builder: (context, state) => AuthMiddleware(
                requiresAuth: false,
                child: MyPatientsScreen(),
              ),
              routes: [
                GoRoute(
                  path: '/doctor/allPatients',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorAllPatients,
                  builder: (context, state) => AuthMiddleware(
                    requiresAuth: false,
                    child: AllPatientsScreen(doctorCIN: state.extra as String),
                  ),
                ),
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
              builder: (context, state) => AuthMiddleware(
                requiresAuth: false,
                child: const DoctorScheduleScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'calendar',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorDailySchedule,
                  builder: (context, state) => AuthMiddleware(
                    requiresAuth: false,
                    child: DoctorCalendarSchedule(),
                  ),
                ),
                GoRoute(
                  path: 'doctor-reschedule-appointment',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorRescheduleAppointment,
                  builder: (context, state) => AuthMiddleware(
                    requiresAuth: false,
                    child: const DoctorRescheduleAppointment(),
                  ),

                  //  {

                  // final appointment = state.extra as AppointmentData;
                  // return DoctorRescheduleAppointment(
                  //   appointment: appointment,
                  // );
                  // },
                ),
                GoRoute(
                    path: 'scheduling-appointment-details',
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouteConstants.doctorSchedulingAppointmentDetails,
                    builder: (context, state) => AuthMiddleware(
                          requiresAuth: false,
                          child: const AppointmentSchedulingDetails(),
                        )

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
        // StatefulShellBranch(
        //   navigatorKey: doctorChatNavigatorKey,
        //   routes: [
        //     GoRoute(
        //       path: '/doctor/chat',
        //       name: RouteConstants.doctorChat,
        //       builder: (context, state) => AuthMiddleware(
        //         requiresAuth: false,
        //         child: const DoctorChatListScreen(),
        //       ),
        //       routes: [
        //         GoRoute(
        //           // Individual Chat Screen
        //           path: 'chat-screen',
        //           parentNavigatorKey: rootNavigatorKey,
        //           name: RouteConstants.doctorChatScreen,
        //           builder: (context, state) => AuthMiddleware(
        //             requiresAuth: false,
        //             child: Builder(
        //               builder: (context) {
        //                 final chat = state.extra as DocChatData;
        //                 return DoctorChatScreen(chat: chat);
        //               },
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),

        // My patients of doctor side
        StatefulShellBranch(
          navigatorKey: doctorProfileNavigatorKey,
          routes: [
            GoRoute(
              path: '/doctor/profile-and-settings',
              name: RouteConstants.doctorProfileSettings,
              builder: (context, state) => AuthMiddleware(
                requiresAuth: false,
                child: const DoctorProfileSettings(),
              ),
              routes: [
                GoRoute(
                  // Settings Screen
                  path: 'security-settings',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorSecuritySettings, // under review
                  builder: (context, state) => AuthMiddleware(
                    requiresAuth: false,
                    child: const DoctorSecurityAndLoginSettings(),
                  ),
                ),
                GoRoute(
                  path: 'doc-edit-public-profile',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorEditPublicProfile,
                  builder: (context, state) => AuthMiddleware(
                    requiresAuth: false,
                    child: DoctorEditPublicProfile(
                      doctorId: state.extra as String,
                    ),
                  ),
                ),
                GoRoute(
                  path: 'doc-public-profile',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorPublicProfile,
                  builder: (context, state) => AuthMiddleware(
                    requiresAuth: false,
                    child: const DoctorPublicProfile(),
                  ),
                ),
                GoRoute(
                  path: 'edit-profile',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorEditProfile,
                  builder: (context, state) => AuthMiddleware(
                    requiresAuth: false,
                    child: const DoctorEditPrivateProfile(),
                  ),
                ),
                GoRoute(
                  path: 'personal-profile',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorPersonalProfile,
                  builder: (context, state) => AuthMiddleware(
                    requiresAuth: false,
                    child: const DoctorPersonalProfile(),
                  ),
                ),
                GoRoute(
                  path: 'profileQR',
                  parentNavigatorKey: rootNavigatorKey,
                  name: RouteConstants.doctorQRCode,
                  builder: (context, state) => AuthMiddleware(
                    requiresAuth: false,
                    child: const DoctorQR(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/doctor/patient-search',
      parentNavigatorKey: rootNavigatorKey,
      name: RouteConstants.doctorPatientSearch,
      builder: (context, state) => AuthMiddleware(
        requiresAuth: false,
        child: PatientSearch(
          doctorCIN: state.extra as String,
        ),
      ),
    ),
  ];
}
