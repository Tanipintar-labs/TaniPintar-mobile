import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ProviderScope(child: TaniPintarApp()));
}

class TaniPintarApp extends StatelessWidget {
  const TaniPintarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaniPintar',
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
