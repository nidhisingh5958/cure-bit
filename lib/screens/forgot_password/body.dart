import 'package:cure_bit/components/constants.dart';
import 'package:cure_bit/screens/login/login_form.dart';
import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(
            "Forgot Password",
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Please enter your email and we will send you a link to return to your account",
            textAlign: TextAlign.center,
          ),
          ForgotPassForm(),
        ],
      ),
    );
  }
}

class ForgotPassForm extends StatefulWidget {
  const ForgotPassForm({super.key});

  @override
  State<ForgotPassForm> createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  List<String> errors = [];
  String email = '';

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      children: [
        TextFormField(
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
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: CustomSuffixIcon("assets/icons/Mail.png"),
            filled: true,
          ),
        ),
      ],
    ));
  }
}
