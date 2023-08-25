import 'package:common/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/routes.dart';
import 'package:package_info_plus/package_info_plus.dart';

final versionFutureProvider = FutureProvider.autoDispose<String>((ref) async {
  final res = await PackageInfo.fromPlatform();
  return res.version;
});

class ViewKelola extends ConsumerWidget {
  const ViewKelola({super.key});

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) Navigator.pop(context);
      return;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(versionFutureProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola'),
      ),
      body: Kelola(
        keluar: () => Alerts.dialog(
          context,
          content: 'Anda yakin ingin keluar?',
          title: 'Peringatan',
          cancel: () => Navigator.pop(context),
          ok: () => logout(context).catchError(
            (e) {
              Alerts.dialog(context, content: '$e');
              return;
            },
          ),
        ),
        webviewRoute: Routes.webView,
        profile: () => Navigator.pushNamed(context, Routes.profile),
        version: version.when(
          data: (data) => data,
          error: (error, stackTrace) => error.toString(),
          loading: () => '',
        ),
        urlApp: defaultTargetPlatform == TargetPlatform.android
            ? 'https://play.google.com/store/apps/details?id=app.dairyfood.leader'
            : 'https://apps.apple.com/us/app/dairyfood-leader/id6458691386',
      ),
    );
  }
}
