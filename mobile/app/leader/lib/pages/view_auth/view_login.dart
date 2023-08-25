import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_auth.dart';

final ready1Provider = FutureProvider.autoDispose<bool>((_) async {
  await Future.delayed(const Duration(seconds: 2));
  return true;
});

final ready2Provider = FutureProvider.autoDispose<bool>((_) async {
  await Future.delayed(const Duration(seconds: 2));
  return true;
});

class ViewLogin extends ConsumerWidget {
  const ViewLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateNotifierProvider);
    final notifier = ref.read(authStateNotifierProvider.notifier);
    final ready1 = ref.watch(ready1Provider);
    final node = ref.watch(keyboardProvider(context));

    return Login(
      node: node,
      imageUrl: 'logo.png',
      textEditingController: notifier.phone,
      isReady: ready1.when(data: (data) => data, error: (error, stackTrace) => false, loading: () => false),
      login: () => notifier.login().catchError((e) => Alerts.dialog(context, content: e.toString())),
      isLoading: auth,
    );
  }
}
