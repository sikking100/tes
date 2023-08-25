import 'package:flutter/material.dart';
import 'package:common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/presentation/pages/auth/auth_page.dart';

final readyProvider = FutureProvider.autoDispose<bool>((_) async {
  await Future.delayed(const Duration(milliseconds: 1500));
  return true;
});

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(authStateProvider);
    final phoneNumber = ref.read(authStateProvider.notifier).phone;
    return Login(
      login: () {
        // if (phoneNumber.text.length > 10) {
        ref
            .read(authStateProvider.notifier)
            .login()
            .then(
                (value) => ref.read(authProvider.notifier).update((state) => 1))
            .catchError((e, o) {
          Alerts.dialog(context, content: e.toString());
          return 0;
        });
        // }
      },
      imageUrl: 'onlinelogo.png',
      textEditingController: phoneNumber,
      isReady: ref.watch(readyProvider).when(
            data: (data) => data,
            error: (error, stackTrace) => false,
            loading: () => false,
          ),
      isLoading: res,
    );
  }
}
