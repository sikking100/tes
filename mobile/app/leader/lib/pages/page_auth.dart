import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/view_auth/view_login.dart';
import 'package:leader/pages/view_auth/view_otp.dart';

final indexStateProvider = StateProvider.autoDispose<int>((_) {
  return 0;
});

final authStateNotifierProvider = StateNotifierProvider.autoDispose<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier(this.ref) : super(false) {
    phone = TextEditingController();
    otp = TextEditingController();
  }
  late final TextEditingController phone;
  late final TextEditingController otp;
  final AutoDisposeRef ref;
  late final String id;

  @override
  void dispose() {
    super.dispose();
    phone.dispose();
    otp.dispose();
  }

  Future login() async {
    try {
      state = true;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) throw 'Terjadi masalah.  Silakan coba beberapa saat lagi';
      id = await ref.read(apiProvider).auth.login(ReqLogin(app: ApplicationType.leader, fcmToken: fcmToken, phone: phone.text));
      ref.read(indexStateProvider.notifier).update((_) => 1);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  Future verify() async {
    try {
      state = true;
      final result = await ref.read(apiProvider).auth.verify(ReqVerify(id: id, otp: otp.text));
      await FirebaseAuth.instance.signInWithCustomToken(result);
      return;
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }
}

class PageAuth extends ConsumerWidget {
  const PageAuth({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = [const ViewLogin(), const ViewOtp()];
    final index = ref.watch(indexStateProvider);
    return Scaffold(
      body: list[index],
    );
  }
}
