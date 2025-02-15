import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.cyan,
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.all(50.0),
          child: Text(
            'Project X',
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromRGBO(244, 246, 245, 1),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          Center(
            child: Text(
              'Help ScreenHelpScreen',
              style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(117, 117, 117, 1),
              ),
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: Text(
              'Feel Free to contact our Customer support',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ),
          Center(
            child: Text(
              'team for any queries or issues at',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              'Email: support@projectx.com',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
