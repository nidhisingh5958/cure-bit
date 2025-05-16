// ignore_for_file: non_constant_identifier_names, prefer_function_declarations_over_variables

//  auth
final auth = 'https://5waijy29ki.execute-api.us-east-1.amazonaws.com/Dev/auth';

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

// forgot password api
final resetPassword_api = '$auth/patient/reset_password';
final createNewPassword_api = '$auth/patient/create_new_password';

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

// forgot password api
final resetPassword_api_doc = '$auth/doctor/reset_password';
final createNewPassword_api_doc = '$auth/doctor/create_new_password';
