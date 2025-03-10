import 'package:CuraDocs/utils/routes/router.dart';
import 'package:CuraDocs/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final nameProvider = Provider<String>((ref) => 'Cura Docs');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize router (which loads SharedPreferences)
  final router = await routerFuture;

  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({Key? key, required this.router}) : super(key: key);

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
