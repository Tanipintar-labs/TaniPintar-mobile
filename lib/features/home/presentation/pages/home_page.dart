import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStateStatus.unauthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: authState.status == AuthStateStatus.loading
            ? const CircularProgressIndicator()
            : IconButton(
                icon: const Icon(Icons.logout, size: 48),
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                },
              ),
      ),
    );
  }
}
