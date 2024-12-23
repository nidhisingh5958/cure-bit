import 'package:cure_bit/components/routes.dart';
import 'package:cure_bit/screens/onboarding_screen.dart';
import 'package:cure_bit/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PageController()),
      ],
      child: MaterialApp(
        title: 'CureBit',
        debugShowCheckedModeBanner: false,
        theme: theme(),
        initialRoute: OnboardingScreen.routeName,
        routes: routes,
      ),
    );
  }
}
