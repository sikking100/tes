import 'package:common/function/function.dart';
import 'package:common/widget/button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  final String imageUrl;
  final TextEditingController textEditingController;
  final void Function()? login;
  final void Function()? goToRegister;
  final FocusNode? node;
  final bool isLoading;

  /// this field is for animation
  /// if it's false, then the animation will show image only
  /// if it's true, then it'll show the phonenumber field
  final bool isReady;

  ///for image that very big
  final EdgeInsets? padding;
  final Widget? dropdown;

  const Login({
    super.key,
    required this.imageUrl,
    required this.textEditingController,
    this.login,
    this.node,
    this.isLoading = false,
    this.goToRegister,
    required this.isReady,
    this.dropdown,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Stack(
        children: [
          AnimatedPositioned(
            top: isReady ? MediaQuery.of(context).size.height * 25 / 100 : MediaQuery.of(context).size.height * 47 / 100,
            duration: const Duration(milliseconds: 800),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Container(padding: padding, child: Image.asset('assets/$imageUrl')),
              ),
            ),
          ),
          AnimatedPositioned(
            bottom: isReady ? 0 : -1000,
            duration: const Duration(milliseconds: 800),
            child: Container(
              padding: const EdgeInsets.all(25),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Masuk dengan Nomor HP',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    focusNode: node,
                    style: Theme.of(context).brightness == Brightness.light ? null : const TextStyle(color: Colors.black),
                    controller: textEditingController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      fillColor: mTextfieldLoginColor,
                      alignLabelWithHint: true,
                      prefixIcon: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          color: mTextfieldLoginNumberColor,
                          borderRadius: BorderRadiusDirectional.only(
                            topStart: Radius.circular(30),
                            bottomStart: Radius.circular(30),
                          ),
                        ),
                        child: Text(
                          '+62',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  dropdown ?? Container(),
                  Text(
                    '6 digit OTP akan dikirim ke HP Anda\nuntuk verifikasi',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(height: 20),
                  Buttons.primary('Login', onPressed: login, isLoading: isLoading),
                  const SizedBox(height: 25),
                  if (goToRegister != null)
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Belum punya akun?  '),
                          TextSpan(
                            recognizer: TapGestureRecognizer()..onTap = goToRegister,
                            text: 'Daftar',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                        style: const TextStyle(fontFamily: 'SegoeUI'),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
