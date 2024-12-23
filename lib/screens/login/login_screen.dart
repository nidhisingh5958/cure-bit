import 'package:cure_bit/screens/login/login_form.dart';
import 'package:flutter/material.dart';
import 'package:cure_bit/screens/forgot_pass/forgot_pass.dart';

class LoginScreen extends StatelessWidget {
  static String routeName = "/login";

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Image.asset(
                  'assets/icons/login.png',
                  height: 100,
                ),
                const SizedBox(height: 20),
                // const Text("Login"),
                // SizedBox(height: SizeConfig.screenHeight * 0.08),
                LoginForm(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialCard(
                      icon: 'assets/icons/google.png',
                      press: () {},
                    ),
                    SocialCard(
                      icon: 'assets/icons/yahoo.png',
                      press: () {},
                    ),
                    SocialCard(
                      icon: 'assets/icons/outlook.png',
                      press: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                NoAccountText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialCard extends StatelessWidget {
  const SocialCard({
    required this.icon,
    required this.press,
    super.key,
  });

  final String icon;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(8),
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 135, 162, 242),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Image.asset(
          icon,
        ),
      ),
    );
  }
}
