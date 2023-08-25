import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/presentation/pages/auth/login_page.dart';
import 'package:sales/presentation/pages/auth/verification_page.dart';

final authProvider = StateProvider.autoDispose<int>((_) {
  return 0;
});

final authStateProvider =
    StateNotifierProvider.autoDispose<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier(Ref ref) : super(false) {
    phone = TextEditingController();
    otp = TextEditingController();
    api = ref.watch(apiProvider);
  }

  late final TextEditingController phone;
  late final TextEditingController otp;
  late final Api api;
  late String id;

  Future<void> login() async {
    try {
      state = true;
      await FirebaseMessaging.instance
          .getToken()
          .then(
            (fcm) async => await api.auth.login(
              ReqLogin(
                app: ApplicationType.sales,
                fcmToken: fcm!,
                phone: phone.text,
              ),
            ),
          )
          .then((res) => id = res);
      return;
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<void> verify() async {
    try {
      state = true;
      await api.auth.verify(ReqVerify(id: id, otp: otp.text)).then(
            (res) async =>
                await FirebaseAuth.instance.signInWithCustomToken(res),
          );
      return;
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }
}

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final List<Widget> list = [
    const LoginPage(),
    const VerificationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final res = ref.watch(authProvider);
          return list[res];
        },
      ),
    );
  }
}
