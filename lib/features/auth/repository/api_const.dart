// ignore_for_file: non_constant_identifier_names, prefer_function_declarations_over_variables

//  auth
final auth = 'https://5waijy29ki.execute-api.us-east-1.amazonaws.com/Dev/auth';

//  appointment
final appointment =
    'https://a7r3s7iyx1.execute-api.us-east-1.amazonaws.com/Dev/appointment';

//  contact us
final contact_us =
    'https://rydsfrzu8d.execute-api.us-east-1.amazonaws.com/Dev/contact';

final signupOtp_api = '$auth/verify_otp_signup';

// Patients
// signup api

final signup_api = '$auth/patient/signup';

final verify_signup_otp = "$auth/patient/verify_otp_signup";

// login api
final login_api = '$auth/patient/login';

final loginWithOtp_api = '$auth/patient/login_otp';

// login with otp api
final verifyLoginWithOtp_api_email = '$auth/patient/verify_otp_login_email';

final verifyLoginWithOtp_api_phone = '$auth/patient/verify_otp_login_phone';

// Doctors
// signup api
final signup_api_doc = '$auth/doctor/signup';

final verify_signup_otp_doc = "$auth/doctor/verify_otp_signup";

// login api
final login_api_doc = '$auth/doctor/login';

final loginWithOtp_api_doc = '$auth/doctor/login_otp';

// login with otp api
final verifyLoginWithOtp_api_email_doc = '$auth/doctor/verify_otp_login_email';

final verifyLoginWithOtp_api_phone_doc = '$auth/doctor/verify_otp_login_phone';
