import 'package:CuraDocs/features/auth/repository/token/token_lifeguard.dart';
import 'package:CuraDocs/utils/routes/router.dart';
import 'package:CuraDocs/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nameProvider = Provider<String>((ref) => 'Cura Docs');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CuraDocs()));
}

class CuraDocs extends ConsumerStatefulWidget {
  const CuraDocs({super.key});

  @override
  ConsumerState<CuraDocs> createState() => _CuraDocsState();
}

class _CuraDocsState extends ConsumerState<CuraDocs>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start token lifeguard service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tokenLifeguardProvider).startPeriodicRefresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop token lifeguard service
    ref.read(tokenLifeguardProvider).stopPeriodicRefresh();
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh token when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      ref.read(tokenLifeguardProvider).forceRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncRouter = ref.watch(routerFutureProvider);

    return asyncRouter.when(
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error: $error')),
        ),
      ),
      data: (router) => MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        title: 'Cura Docs',
        theme: theme(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
