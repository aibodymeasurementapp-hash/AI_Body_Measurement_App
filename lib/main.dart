import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'package:firebase_core/firebase_core.dart';
<<<<<<< HEAD
=======
import 'services/revenuecat_service.dart';
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
<<<<<<< HEAD
  // RevenueCat removed — no initialization needed for Stripe
  runApp(
    const ProviderScope(
=======
  await RevenueCatService.initialize();
  runApp(
    const ProviderScope(   // ← fix: wraps entire app
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
<<<<<<< HEAD
    final router = ref.watch(routerProvider);
=======
    final router = ref.watch(routerProvider);  // ← fix: removed broken hyperlink
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89

    return MaterialApp.router(
      title: 'AI Body Measurement',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}