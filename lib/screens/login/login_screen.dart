import 'package:cure_bit/screens/login/body.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  static String routeName = "/login";

  @override
  Widget build(BuildContext context) {
    return Body();
  }





// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   String _email = '';
//   String _password = '';

//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       debugPrint('Email: $_email');
//       debugPrint('Password: $_password');
//       debugPrint('Form Key: $_formKey');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: ListView(
//             children: [
//               const SizedBox(
//                 height: 80,
//               ),
//               Column(
//                 children: [
//                   Image.asset('assets/images/logo.png'),
//                   const SizedBox(height: 20),
//                   const Text("Login"),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 decoration: const InputDecoration(
//                   labelText: 'Username/Email',
//                   hintText: 'Enter your email or username',
//                   filled: true,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 decoration: const InputDecoration(
//                   labelText: 'Password',
//                   hintText: 'Enter your password',
//                   filled: true,
//                 ),
//                 obscureText: true,
//               ),
//               OverflowBar(
//                 children: [
//                   TextButton(
//                     child: const Text('Cancel'),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                   ElevatedButton(
//                     child: const Text('Next'),
//                     onPressed: () {
//                       _submit();
//                       Navigator.pop(context);
//                     },
//                   )
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// child: Center(
            //   child: Form(
            //     key: _formKey,
            //     child: Column(
            //       children: [
            //         TextFormField(
            //           decoration: const InputDecoration(labelText: 'Email'),
            //           keyboardType: TextInputType.emailAddress,
            //           validator: (value) {
            //             if (value == null || value.isEmpty) {
            //               return 'Please enter your email';
            //             }
            //             if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            //               return 'Please enter a valid email';
            //             }
            //             return null;
            //           },
            //           onChanged: (value) {
            //             _email = value;
            //           },
            //         ),
            //         TextFormField(
            //           decoration: const InputDecoration(labelText: 'Password'),
            //           obscureText: true,
            //           validator: (value) {
            //             if (value == null || value.isEmpty) {
            //               return 'Please enter your password';
            //             }
            //             if (value.length < 6) {
            //               return 'Password must be at least 6 characters';
            //             }
            //             return null;
            //           },
            //           onChanged: (value) {
            //             _password = value;
            //           },
            //         ),
            //         const SizedBox(height: 20),
            //         ElevatedButton(
            //           onPressed: _submit,
            //           child: const Text('Sign Up'),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),