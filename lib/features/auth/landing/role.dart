import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/components/circular_checkbox.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  String selectedRole = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Welcome to CuraDocs',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Choose your role to continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: grey600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              _buildRoleChoice(role: 'Patient'),
              const SizedBox(height: 20),
              _buildRoleChoice(role: 'Doctor'),
              const SizedBox(height: 40),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChoice({required String role}) {
    final bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                role,
                style: TextStyle(
                  color: black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CircularCheckbox(
                isChecked: isSelected,
                size: 24.0,
                onChanged: (bool checked) {
                  if (checked) {
                    setState(() {
                      selectedRole = role;
                    });
                  } else {
                    setState(() {
                      if (selectedRole == role) {
                        selectedRole = '';
                      }
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: selectedRole.isEmpty
            ? null
            : () async {
                // Save the selected role to shared preferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('userRole', selectedRole);

                // Navigate to login with the role
                context.goNamed(
                  RouteConstants.login,
                  extra: {'role': selectedRole},
                );
              },
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
