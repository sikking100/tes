import 'package:common/function/function.dart';
import 'package:common/widget/alert.dart';
import 'package:customer/pages/auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ViewAuthRegister extends ConsumerWidget {
  const ViewAuthRegister({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(authStateProvider);
    InputDecoration inputDecoration(String text) {
      return InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        fillColor: mTextfieldLoginColor,
        filled: true,
        hintText: text,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 30,
        ),
      );
    }

    return WillPopScope(
      onWillPop: () {
        ref.read(authProvider.notifier).update((state) => 0);
        return Future.value(false);
      },
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              Column(
                children: [
                  Text(
                    'Masukkan data diri Anda.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: ref.read(authStateProvider.notifier).name,
                    decoration: inputDecoration('Nama'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: ref.read(authStateProvider.notifier).phone,
                    decoration: inputDecoration('Nomor HP'),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: ref.read(authStateProvider.notifier).email,
                    decoration: inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () => ref.read(authStateProvider.notifier).register().then((value) async {
                          await Alerts.dialog(context, content: 'Berhasil mendaftar, silakan masuk', title: 'Sukses');
                          ref.read(authProvider.notifier).update((state) => 0);
                          return;
                        }).catchError((e, i) {
                          Alerts.dialog(context, content: e.toString());
                          return;
                        }),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(MediaQuery.of(context).size.width, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: loading ? const CircularProgressIndicator.adaptive() : const Text('Daftar'),
              ),
              const SizedBox(height: 25),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Sudah punya akun?  '),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          ref.read(authProvider.notifier).update((state) => 0);
                        },
                      text: 'Masuk',
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    )
                  ],
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
