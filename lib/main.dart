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

  runApp(ProviderScope(child: MyApp(router: router)));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
      title: 'Cura Docs',
      debugShowCheckedModeBanner: false,
      theme: theme(),
      routerConfig: router,
    );
  }
}
