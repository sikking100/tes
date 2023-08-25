import 'package:customer/pages/auth.dart';
import 'package:flutter/material.dart';
import 'package:common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final ready1Provider = FutureProvider.autoDispose<bool>((_) async {
  await Future.delayed(const Duration(seconds: 2));
  return true;
});

final ready2Provider = FutureProvider.autoDispose<bool>((_) async {
  await Future.delayed(const Duration(seconds: 2));
  return true;
});

class ViewAuthLogin extends ConsumerWidget {
  const ViewAuthLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(authStateProvider);
    final ready1 = ref.watch(ready1Provider);
    final brings = Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: Text(
          "Bringing The World's\nBest Bakery Ingredients\nTo You",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: GoogleFonts.firaSans().fontFamily,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 28,
          ),
        ),
      ),
    );
    return ready1.when(
      data: (data) {
        if (data == false) return brings;
        final ready2 = ref.watch(ready2Provider);
        return Login(
          login: () =>
              ref.read(authStateProvider.notifier).login().then((value) => ref.read(authProvider.notifier).update((state) => 1)).catchError((e, o) {
            Alerts.dialog(context, content: e.toString());
            return 0;
          }),
          imageUrl: 'onlinelogo.png',
          textEditingController: ref.read(authStateProvider.notifier).phone,
          isReady: ready2.when(
            data: (data) => data,
            error: (error, stackTrace) => false,
            loading: () => false,
          ),
          isLoading: res,
          goToRegister: () => ref.read(authProvider.notifier).update((state) => 2),
        );
      },
      error: (error, stackTrace) => brings,
      loading: () => brings,
    );
  }
}
