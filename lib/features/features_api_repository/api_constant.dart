//  appointment
// ignore_for_file: non_constant_identifier_names

final bookAppointment =
    'https://a7r3s7iyx1.execute-api.us-east-1.amazonaws.com/Dev/appointment';

//  appointment
// patinet routes
final patientBookAppointment = '$bookAppointment/appointment';
final rescheduleAppointment_patient =
    '$bookAppointment/patient/appointment/reschedule';
final String patientCancelAppointment =
    '$bookAppointment/patient/appointment/cancel';
final String patientGetAppointments = '$bookAppointment/patient/appointments';

// doctor routes
final rescheduleAppointment_doc =
    '$bookAppointment/doctor/appointment/reschedule';
