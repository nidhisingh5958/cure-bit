import 'package:CuraDocs/components/routes/router.dart';
import 'package:CuraDocs/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nameProvider = Provider<String>((ref) => 'Cura Docs');

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cura Docs',
      debugShowCheckedModeBanner: false,
      theme: theme(),
      routerConfig: router,
    );
  }
}
