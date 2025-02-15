import "package:flutter/material.dart";

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        bottomNavigationBar: BottomNavigationBar(
          items: [],
        ),
        body: Column(
          children: [],
        ));
  }
}
