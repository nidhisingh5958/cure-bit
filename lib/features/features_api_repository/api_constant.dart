//  appointment
// ignore_for_file: non_constant_identifier_names

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

final String updateEmergencyContactDetails = '';
final String requestEmailChange = '';
final String requestPhoneChange = '';
final String updatePhoneNumber = '';

final String getPatientPrivateProfile = '';

// patient routes
final String getPatientPublicProfile = '';
final String updatePatientPublicProfile =
    'https://lxvk0bm3k2.execute-api.us-east-1.amazonaws.com/Dev/patient_profile';

// doctor routes
final String getDoctorPublicProfile = '';
final String updateDoctorPublicProfile =
    'https://1f3ehj2tli.execute-api.us-east-1.amazonaws.com/Dev/doctor_profile';

//  search
final String searchDoctor_api =
    'https://nf9rfloqn0.execute-api.us-east-1.amazonaws.com/Dev/doctor-search';
final String searchPatient_api =
    'https://iylosoz7m1.execute-api.us-east-1.amazonaws.com/Dev/internal';
