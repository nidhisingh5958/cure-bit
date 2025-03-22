// ignore_for_file: non_constant_identifier_names, prefer_function_declarations_over_variables

// Patients
// signup api
final signup_api =
    'https://vv189flpy7.execute-api.us-east-1.amazonaws.com/Dev/auth/patient/signup';

final verify_signup_otp =
    "https://vv189flpy7.execute-api.us-east-1.amazonaws.com/Dev/auth/patient/verify_otp_signup";

// login api
final login_api =
    'https://vv189flpy7.execute-api.us-east-1.amazonaws.com/Dev/auth/patient/login';

final loginWithOtp_api_email =
    'https://vv189flpy7.execute-api.us-east-1.amazonaws.com/Dev/auth/patient/login-otp';

String getLoginWithOtpPhoneApi(String phoneNumber) {
  return 'https://vv189flpy7.execute-api.us-east-1.amazonaws.com/Dev/auth/patient/+$phoneNumber/verify_otp_login_phone';
}

// Doctors
// signup api
final signup_api_doc =
    'https://vv189flpy7.execute-api.us-east-1.amazonaws.com/Dev/auth/doctor/signup';

final verify_signup_otp_doc =
    "https://vv189flpy7.execute-api.us-east-1.amazonaws.com/Dev/auth/doctor/verify_otp_signup";

// login api
final login_api_doc =
    'https://vv189flpy7.execute-api.us-east-1.amazonaws.com/Dev/auth/doctor/login';

final loginWithOtp_api_email_doc =
    'https://vv189flpy7.execute-api.us-east-1.amazonaws.com/Dev/auth/doctor/login-otp';

String loginWithOtp_api_phone_doc(String phoneNumber) {
  return 'https://vv189flpy7.execute-api.us-east-1.amazonaws.com/Dev/auth/doctor/+$phoneNumber/verify_otp_login_phone';
}
