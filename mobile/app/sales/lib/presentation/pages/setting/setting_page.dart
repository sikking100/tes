import 'package:common/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/presentation/widgets/app_alert_dialog.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola")),
      body: Kelola(
        urlApp:
            'https://play.google.com/store/apps/details?id=app.dairyfood.sales',
        keluar: () {
          AppActionDialog.show(
              context: context,
              title: "Keluar",
              content: "Apakah anda yakin ingin keluar?",
              onPressNo: () {
                Navigator.pop(context);
              },
              onPressYes: () async {
                Navigator.pop(context);
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  Alerts.dialog(context, content: e.toString());
                }
              },
              isAction: true);
        },
        webviewRoute: AppRoutes.webview,
        profile: () {
          Navigator.of(context).pushNamed(AppRoutes.settingAccount);
        },
        version: "v1.0.0",
      ),
    );
  }
}
