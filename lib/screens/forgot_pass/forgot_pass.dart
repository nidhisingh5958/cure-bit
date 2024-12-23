import 'package:cure_bit/components/constants.dart';
import 'package:cure_bit/screens/login/login_form.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static String routeName = "/forgot_password";

  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Forgot Password",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: const Color.fromARGB(255, 0, 32, 83),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/forgot_pass.png',
                      // height: 40,
                      // width: 50,
                    ),
                    // Spacer(),
                    SizedBox(height: 20),
                    Text(
                      "Forgot Password",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      // pompt text
                      "Please enter your email and we will send you a link to return to your account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(height: 20),
                    // SizedBox(height: SizeConfig.screenHeight * 0.1),
                    ForgotPassForm(),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// forgot password form
class ForgotPassForm extends StatefulWidget {
  const ForgotPassForm({super.key});

  @override
  State<ForgotPassForm> createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> errors = [];
  String email = '';

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
          width: 300,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue!,
            onChanged: (value) {
              if (value.isNotEmpty && errors.contains(kEmailNullError)) {
                setState(() {
                  errors.remove(kEmailNullError);
                });
              } else if (emailValidatorRegExp.hasMatch(value) &&
                  errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.remove(kInvalidEmailError);
                });
              }
            },
            validator: (value) {
              if (value!.isEmpty && !errors.contains(kEmailNullError)) {
                setState(() {
                  errors.remove(kEmailNullError);
                });
              } else if (!emailValidatorRegExp.hasMatch(value) &&
                  !errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.remove(kInvalidEmailError);
                });
              }
              return null;
            },
            // email box
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              labelStyle: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              hintStyle: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              constraints: BoxConstraints(maxWidth: 30),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSuffixIcon("assets/icons/mail.png"),
              filled: true,
            ),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SizedBox(height: 10),
        FormError(errors: errors),
        SizedBox(
          width: double.infinity,
          height: 48,
          //  continue button
          child: ElevatedButton(
            child: Text("Continue"),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // aage kaam hogaa
              }
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        NoAccountText(),
      ],
    ));
  }
}

// no account part
class NoAccountText extends StatelessWidget {
  const NoAccountText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              // Navigator.pushNamed(context, "/register");
            },
            child: const Text(
              "Register",
              style: TextStyle(
                fontSize: 12,
                color: Color.fromARGB(194, 62, 173, 66),
                // decoration: TextDecoration.underline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
