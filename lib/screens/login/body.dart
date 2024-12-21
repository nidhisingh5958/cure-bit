import 'package:cure_bit/screens/login/login_form.dart';
import 'package:cure_bit/screens/no_account_text.dart';
import 'package:flutter/material.dart';
import 'package:cure_bit/screens/login/social_card.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/icons/logo.png'),
                const SizedBox(height: 20),
                const Text("Login"),
                // SizedBox(height: SizeConfig.screenHeight * 0.08),
                LoginForm(),
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
                // SizedBox(height: SizeConfig.screenHeight * 0.08),
                NoAccountText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
