import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cure_bit/components/routes/route_constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String rePassword = '';
  bool _isChecked = false;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Print the values to the debug console
      debugPrint('Name: $name');
      debugPrint('Email: $email');
      // debugPrint('Phone Number: $phoneNumber');
      debugPrint('Password: $password');
      debugPrint('Re-password: $rePassword');

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const SignupProfilePage()),
      // );
      Navigator.pushNamed(context, '/signup_profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.black,
        width: 1.0,
        style: BorderStyle.solid,
        strokeAlign: BorderSide.strokeAlignCenter,
      ),
    );

    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 246, 245, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assests/images/Logo.jpg'),
              height: 90,
            ),
            const SizedBox(height: 10),
            const Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 350,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextFormField(
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        fillColor: Color.fromRGBO(244, 246, 245, 1),
                        filled: true,
                        enabledBorder: border,
                        focusedBorder: border,
                        hintText: 'John Doe',
                        prefixIcon: Icon(
                          Icons.person,
                        ),
                        prefixIconColor: Color.fromRGBO(105, 190, 217, 1),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        name = value!;
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'DoeJohn@Gmail.com',
                        fillColor: Color.fromRGBO(244, 246, 245, 1),
                        filled: true,
                        enabledBorder: border,
                        focusedBorder: border,
                        prefixIcon: Icon(
                          Icons.email,
                        ),
                        prefixIconColor: Color.fromRGBO(105, 190, 217, 1),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        email = value!;
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: '........',
                        fillColor: Color.fromRGBO(244, 246, 245, 1),
                        filled: true,
                        enabledBorder: border,
                        focusedBorder: border,
                        prefixIcon: Icon(Icons.lock_outline),
                        prefixIconColor: Color.fromRGBO(105, 190, 217, 1),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        password = value!;
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Re-Enter Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: '........',
                        fillColor: Color.fromRGBO(244, 246, 245, 1),
                        filled: true,
                        enabledBorder: border,
                        focusedBorder: border,
                        prefixIcon: Icon(Icons.lock_outline),
                        prefixIconColor: Color.fromRGBO(105, 190, 217, 1),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please re-enter your password';
                        }
                        // if (value != password) {
                        //   return 'Passwords do not match';
                        // }
                        return null;
                      },
                      onSaved: (value) {
                        rePassword = value!;
                      },
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isChecked = newValue ??
                                  false; // Update state when checkbox is clicked
                            });
                          },
                        ),
                        // Text(
                        //   _isChecked ? 'Checked' : 'Unchecked',
                        //   style: TextStyle(fontSize: 20),
                        // ),
                        const Text('I agree with Terms and Privacy Policy')
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(105, 190, 217, 1),
                minimumSize: const Size(200, 50),
                maximumSize: const Size(300, 50),
              ),
              child: const Text('Sign Up'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have account?'),
                GestureDetector(
                  onTap: () {
                    context.go(RouteConstants.signUp);
                  },
                  child: Text(
                    " Login",
                    style: const TextStyle(
                      color: Color.fromRGBO(105, 190, 217, 1),
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.green,
                      decorationThickness: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserInputForm extends StatefulWidget {
  const UserInputForm({super.key});

  @override
  State<UserInputForm> createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String phoneNumber = '';
  String password = '';
  String rePassword = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Print the values to the debug console
      debugPrint('Name: $name');
      debugPrint('Email: $email');
      debugPrint('Phone Number: $phoneNumber');
      debugPrint('Password: $password');
      debugPrint('Re-password: $rePassword');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User  Input Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Re-password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please re-enter your password';
                  }
                  if (value != password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onSaved: (value) {
                  rePassword = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Login???
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});
//   @override
//   // _SignupPageState createState() => _SignupPageState();
//   State <SignUpScreen> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignUpScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _email = '';
//   String _password = '';
//
//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       // Process the data (e.g., send to server)
//       debugPrint('Email: $_email');
//       debugPrint('Password: $_password');
//       debugPrint('Form Key: $_formKey');
//       // You can also navigate to another page or show a success message
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Signup'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                     return 'Please enter a valid email';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   _email = value;
//                 },
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   _password = value;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submit,
//                 child: const Text('Sign Up'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
