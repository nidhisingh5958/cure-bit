import 'package:CuraDocs/utils/providers/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/features/auth/repository/auth_repository.dart';
import 'auth_providers.dart';

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
    required AuthStateNotifier notifier,
    String? countryCode,
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
