import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Otp extends StatelessWidget {
  const Otp({super.key});

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
              style: Theme.of(context).textTheme.titleMedium,
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
