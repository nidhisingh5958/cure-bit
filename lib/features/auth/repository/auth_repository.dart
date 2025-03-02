import 'package:CuraDocs/features/auth/repository/api_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:CuraDocs/utils/snackbar.dart';

class AuthRepository {
  // Future<User> login(String email, String password) async {
  //   return _authDataSource.login(email, password);
  // }

  Future<void> signinWithPass(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      // Simulate network request
      Response response = await post(Uri.parse(login_api),
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
          headers: {
            'Content-Type': 'application/json',
          });
      await Future.delayed(const Duration(seconds: 1));
      // login logic

      if (response.statusCode == 200) {
        showSnackBar(context: context, message: 'Login successful');
        GoRouter.of(context).go('/home');
      } else {
        showSnackBar(
            context: context, message: 'Login failed. Please try again.');
      }
    } catch (e) {
      print("failed");
      showSnackBar(
          context: context, message: 'Login failed. Please try again.');
    }
  }
}
