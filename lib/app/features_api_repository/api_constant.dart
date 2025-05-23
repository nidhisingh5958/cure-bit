//  appointment
// ignore_for_file: non_constant_identifier_names

//  connect
final String connect_api =
    'https://hc28588xe6.execute-api.us-east-1.amazonaws.com/Dev/connect';

//  appointments
final appointment =
    'https://a7r3s7iyx1.execute-api.us-east-1.amazonaws.com/Dev/appointment';

// patinet routes
final patientBookAppointment = '$appointment/patient/appointment/book';
final rescheduleAppointment_patient =
    '$appointment/patient/appointment/reschedule';
final String patientCancelAppointment =
    '$appointment/patient/appointment/cancel';
final String patientGetAppointments = '$appointment/patient/appointments';

// doctor routes
final rescheduleAppointment_doc = '$appointment/doctor/appointment/reschedule';
final String doctorGetAppointments = '$appointment/doctor';
// final String doctorCancelAppointment =
//     '$appointment/doctor/appointment/cancel';
final String appointmentDone = '$appointment/doctor/appointment/done';

// profile
final String privateProfile =
    'https://g08gqqdfma.execute-api.us-east-1.amazonaws.com/Dev/profile';

final String update_private_doc =
    '$privateProfile/update/doctor_private_profile';
final String update_private_patient =
    '$privateProfile/update/patient_private_profile';

final String refresh_cache_doc =
    '$privateProfile/refresh_cache/private_doctor_profile_data';
final String refresh_cache_patient =
    '$privateProfile/refresh_cache/private_patient_profile_data';

// patient routes

final String patientPublicProfile =
    'https://lxvk0bm3k2.execute-api.us-east-1.amazonaws.com/Dev/patient_profile';

// doctor routes
final String doctorPublicProfile =
    'https://1f3ehj2tli.execute-api.us-east-1.amazonaws.com/Dev/doctor_profile';

//  search
final String searchDoctor_api =
    'https://nf9rfloqn0.execute-api.us-east-1.amazonaws.com/Dev/doctor-search';
final String searchPatient_api =
    'https://iylosoz7m1.execute-api.us-east-1.amazonaws.com/Dev/internal';
