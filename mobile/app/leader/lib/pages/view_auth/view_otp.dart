import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/pages/page_auth.dart';
import 'package:common/common.dart';

final otpStateNotifierProvider = StateNotifierProvider.autoDispose<OtpStateNotifier, int>((ref) {
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

class ViewOtp extends ConsumerWidget {
  const ViewOtp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(authStateNotifierProvider);
    final notifier = ref.read(authStateNotifierProvider.notifier);
    final countDown = ref.watch(otpStateNotifierProvider);
    return Otp(
      verifikasi: () => notifier.verify(),
      resend: () => notifier.login(),
      back: () => ref.read(indexStateProvider.notifier).update((_) => 0),
      textEditingController: notifier.otp,
      countDown: countDown,
      isLoading: loading,
    );
  }
}
