import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  static String routeName = "/otp";

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "OTP Verification",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Color.fromARGB(255, 0, 32, 83),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                "We sent your code to +91 898** *****",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                OtpForm(),
                Spacer(),
                OtpForm(),
                Spacer(),
                OtpForm(),
                Spacer(),
                OtpForm(),
                Spacer()
              ],
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              child: Text(
                "Resend OTP Code",
                style: TextStyle(
                  color: Color.fromARGB(255, 67, 132, 237),
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // resend otp code
              },
            ),
            GestureDetector(
              child: Text(
                "I didn't receive the code",
                style: TextStyle(
                  color: Color.fromARGB(255, 116, 161, 235),
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // didn't receive code
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OtpForm extends StatelessWidget {
  const OtpForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Row(
        children: [
          SizedBox(
            height: 68,
            width: 64,
            child: TextFormField(
              onChanged: (value) {
                if (value.length == 1) {
                  FocusScope.of(context).nextFocus();
                }
              },
              onSaved: (pin1) {},
              decoration: const InputDecoration(hintText: '0'),
              style: Theme.of(context).textTheme.titleSmall,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ),
        ],
      ),
    );
  }
}
