import 'dart:async';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/presentation/pages/auth/auth_page.dart';

final otpStateNotifierProvider =
    StateNotifierProvider.autoDispose<OtpStateNotifier, int>((ref) {
  return OtpStateNotifier();
});

class OtpStateNotifier extends StateNotifier<int> {
  late Timer _timer;
  OtpStateNotifier() : super(60) {
    init();
  }

  void init() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (state > 0) {
          state -= 1;
          return;
        } else {
          _timer.cancel();
        }
      },
    );
  }

  void reset() {
    state = 60;
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}

class VerificationPage extends ConsumerWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(authStateProvider);
    final res = ref.watch(otpStateNotifierProvider);
    return Otp(
      verifikasi: () {
        if (ref.read(authStateProvider.notifier).otp.text.length == 6) {
          ref
              .read(authStateProvider.notifier)
              .verify()
              .catchError((e) => Alerts.dialog(context, content: e.toString()));
        }
      },
      resend: () => ref
          .read(authStateProvider.notifier)
          .login()
          .then((_) => ref.refresh(otpStateNotifierProvider))
          .catchError((e) {
        Alerts.dialog(context, content: e.toString());
        return 1;
      }),
      back: () {
        ref.read(authProvider.notifier).update((state) => 0);
      },
      isLoading: loading,
      textEditingController: ref.read(authStateProvider.notifier).otp,
      countDown: res,
    );
  }
}
