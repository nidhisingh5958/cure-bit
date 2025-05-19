//  appointment
// ignore_for_file: non_constant_identifier_names

//  appointments
final bookAppointment =
    'https://a7r3s7iyx1.execute-api.us-east-1.amazonaws.com/Dev/appointment';

// patinet routes
final patientBookAppointment = '$bookAppointment/patient/appointment/book';
final rescheduleAppointment_patient =
    '$bookAppointment/patient/appointment/reschedule';
final String patientCancelAppointment =
    '$bookAppointment/patient/appointment/cancel';
final String patientGetAppointments = '$bookAppointment/patient/appointments';

// doctor routes
final rescheduleAppointment_doc =
    '$bookAppointment/doctor/appointment/reschedule';
final String doctorGetAppointments = '$bookAppointment/doctor';
// final String doctorCancelAppointment =
//     '$bookAppointment/doctor/appointment/cancel';
final String appointmentDone = '$bookAppointment/doctor/appointment/done';

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
