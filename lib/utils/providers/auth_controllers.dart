import 'package:CuraDocs/utils/providers/auth_providers.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/app/auth/auth_repository.dart';

// login
final loginControllerProvider = Provider((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return LoginController(authRepo);
});

class LoginController {
  final AuthRepository _authRepository;

  LoginController(this._authRepository);

  Future<void> signIn({
    required BuildContext context,
    required String input,
    required String password,
    required String role,
    String? countryCode,
    required AuthStateNotifier notifier,
  }) async {
    await _authRepository.signInWithPass(
      context,
      input,
      password,
      role,
      notifier: notifier,
      countryCode: countryCode,
    );
  }
}

// signup
final signUpControllerProvider = Provider((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return SignUpController(authRepo);
});

class SignUpController {
  final AuthRepository _authRepository;

  SignUpController(this._authRepository);

  Future<void> signUp({
    required BuildContext context,
    required String firstName,
    required String lastName,
    required String email,
    required String countryCode,
    required String phoneNumber,
    required String password,
    required String role,
    required AuthStateNotifier notifier,
  }) async {
    await _authRepository.signUp(
      context,
      firstName,
      lastName,
      email,
      countryCode,
      phoneNumber,
      password,
      role,
      notifier,
    );
  }

  Future<bool> sendSignupOtp({
    required BuildContext context,
    required String identifier,
    String? countryCode,
  }) {
    return _authRepository.signupOtp(context, identifier, countryCode);
  }

  Future<bool> verifySignupOtp({
    required BuildContext context,
    required String identifier,
    required String plainOtp,
    String? countryCode,
  }) {
    return _authRepository.verifySignupOtp(
        context, identifier, plainOtp, countryCode);
  }
}

// login with otp
final loginWithOtpControllerProvider = Provider<OtpController>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return OtpController(authRepo);
});

class OtpController {
  final AuthRepository _authRepo;
  OtpController(this._authRepo);

  Future<void> sendOtp({
    required BuildContext context,
    required String identifier,
    required String role,
    String? countryCode,
  }) async {
    await _authRepo.sendOtp(context, identifier, role,
        countryCode: countryCode);
  }

  Future<void> verifyOtp({
    required BuildContext context,
    required String identifier,
    required String otp,
    required String role,
    required AuthStateNotifier notifier,
  }) async {
    await _authRepo.verifyOtp(
      context,
      identifier,
      otp,
      role,
      notifier,
    );
  }
}

// Forgot password controller
final forgotPasswordControllerProvider = Provider((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return ForgotPasswordController(authRepo);
});

class ForgotPasswordController {
  final AuthRepository _authRepository;
  String? _resetToken;

  ForgotPasswordController(this._authRepository);

  // Getter for the reset token
  String? get resetToken => _resetToken;

  // Request password reset and get token
  Future<bool> requestPasswordReset({
    required BuildContext context,
    required String email,
    required String role,
  }) async {
    _resetToken =
        await _authRepository.requestPasswordReset(context, email, role);
    return _resetToken != null;
  }

  // Complete the password reset with the new password
  Future<void> completePasswordReset({
    required BuildContext context,
    required String email,
    required String newPassword,
    required String role,
    required AuthStateNotifier notifier,
  }) async {
    if (_resetToken == null) {
      showSnackBar(
          context: context,
          message:
              'Reset token is missing. Please request a new password reset.');
      return;
    }

    await _authRepository.resetPassword(
      context: context,
      identifier: email,
      password: newPassword,
      role: role,
      notifier: notifier,
    );
  }
}
