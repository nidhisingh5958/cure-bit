import 'package:cure_bit/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';

  bool remember = false;
  final List<String> errors = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: 20),
          buildPassFormField(),
          SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: Theme.of(context).colorScheme.secondary,
                onChanged: (value) {
                  setState(() {
                    remember = value!;
                  });
                },
              ),
              Text("Remember me"),
              Spacer(),
              Text(
                "Forgot Password",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: 20),
          ElevatedButton(
            child: const Text('Login'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
              } else {
                debugPrint('Form is invalid');
              }
            },
          ),
        ],
      ),
    );
  }

  buildPassFormField() {
    TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue!,
      validator: (value) {
        if (value!.isNotEmpty && !errors.contains(kPassNullError)) {
          setState(() {
            errors.remove(kPassNullError);
          });
        } else if (value.length >= 8 && !errors.contains(kShortPassError)) {
          setState(() {
            errors.remove(kPassNullError);
          });
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon("assets/icons/padlock.png"),
        filled: true,
      ),
    );
  }

  buildEmailFormField() {
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
    );
  }
}

class FormError extends StatelessWidget {
  const FormError({
    super.key,
    required this.errors,
  });

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        errors.length,
        (index) => formErrorText(error: errors[index]),
      ),
    );
  }

  Row formErrorText({error}) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons/Error.png",
          height: 14,
          width: 14,
        ),
        SizedBox(width: 10),
        Text(error),
      ],
    );
  }
}

class CustomSuffixIcon extends StatelessWidget {
  const CustomSuffixIcon(this.svgIcon, {super.key});

  final String svgIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: SvgPicture.asset(svgIcon, height: 18),
    );
  }
}
