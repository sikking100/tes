import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Kelola extends StatelessWidget {
  final void Function() keluar;
  final String webviewRoute;
  final void Function()? tema;
  // final Widget? payLater;
  final Widget? orderHistory;
  final void Function() profile;
  // final void Function()? business;
  final String version;
  final bool isBusiness;
  final String urlApp;
  final bool isCustomer;

  const Kelola({
    super.key,
    required this.keluar,
    required this.webviewRoute,
    this.tema,
    // this.payLater,
    this.orderHistory,
    required this.profile,
    required this.version,
    // this.business,
    this.isBusiness = false,
    required this.urlApp,
    this.isCustomer = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.px16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AKUN'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: Text('Kelola ${isBusiness != true ? 'Akun' : 'Bisnis'}'),
              minLeadingWidth: 0,
              horizontalTitleGap: 10,
              minVerticalPadding: 0,
              onTap: profile,
            ),
            const Divider(thickness: 1, height: 0),
            orderHistory ?? Container(),
            // if (business != null) const Divider(thickness: 1, height: 0),
            // if (business != null)
            //   ListTile(
            //     contentPadding: EdgeInsets.zero,
            //     leading: const Icon(Icons.payment),
            //     title: const Text('Bisnis'),
            //     minLeadingWidth: 0,
            //     horizontalTitleGap: 10,
            //     minVerticalPadding: 0,
            //     onTap: business,
            //   ),
            // payLater ?? Container(),
            // if (tema != null) const Divider(thickness: 1, height: 0),
            // if (tema != null) const SizedBox(height: 15),
            // if (tema != null) const Text('KONTEN & AKTIVITAS'),
            // if (tema != null)
            //   ListTile(
            //     onTap: tema,
            //     contentPadding: EdgeInsets.zero,
            //     leading: const Icon(Icons.bedtime_outlined),
            //     title: const Text('Pengaturan Tema'),
            //     minLeadingWidth: 0,
            //     horizontalTitleGap: 10,
            //   ),
            if (tema != null) const Divider(thickness: 1, height: 0),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.star_outline),
              title: const Text('Beri Rating'),
              minLeadingWidth: 0,
              horizontalTitleGap: 10,
              onTap: () async {
                // Navigator.pushNamed(context, webviewRoute, arguments: {'title': 'Beri Rating', 'url': urlApp});
                if (await canLaunchUrl(Uri.parse(urlApp))) {
                  if (defaultTargetPlatform == TargetPlatform.android) {
                    await launchUrl(Uri.parse(urlApp), mode: LaunchMode.externalNonBrowserApplication);
                    return;
                  }
                  final bool nativeAppLaunchSucceeded = await launchUrl(
                    Uri.parse(urlApp),
                    mode: LaunchMode.externalNonBrowserApplication,
                  );
                  if (!nativeAppLaunchSucceeded) {
                    await launchUrl(
                      Uri.parse(urlApp),
                      mode: LaunchMode.inAppWebView,
                    );
                  }
                }
                return;
              },
            ),
            const Divider(thickness: 1, height: 0),
            if (tema != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.share_outlined),
                title: const Text('Bagikan Aplikasi'),
                minLeadingWidth: 0,
                horizontalTitleGap: 10,
                onTap: () async {
                  try {
                    if (defaultTargetPlatform == TargetPlatform.iOS) {
                      final box = context.findRenderObject() as RenderBox?;
                      await Share.share(urlApp, sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
                      return;
                    }
                    await Share.share(urlApp);
                    return;
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Oops.'),
                        content: Text(e.toString()),
                      ),
                    );
                    return;
                  }
                },
              ),
            if (tema != null) const Divider(thickness: 1, height: 0),
            if (isCustomer && defaultTargetPlatform == TargetPlatform.iOS)
              Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Hapus Akun', style: TextStyle(color: Colors.red)),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 10,
                    onTap: () => Navigator.pushNamed(context, webviewRoute, arguments: {'title': 'Hapus Akun', 'url': 'https://dairyfood.app/form'}),
                  ),
                  const Divider(thickness: 1, height: 0),
                ],
              ),
            const SizedBox(height: 15),
            const Text('DUKUNGAN'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.help_outline),
              title: const Text('Pusat Bantuan'),
              minLeadingWidth: 0,
              horizontalTitleGap: 10,
              onTap: () => Navigator.pushNamed(context, webviewRoute, arguments: {'title': 'Pusat Bantuan', 'url': 'https://dairyfood.app/help'}),
            ),
            const Divider(thickness: 1, height: 0),
            const SizedBox(height: 15),
            const Text('TENTANG KAMI'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.assignment_turned_in_outlined),
              title: const Text('Syarat dan Ketentuan'),
              minLeadingWidth: 0,
              horizontalTitleGap: 10,
              onTap: () => Navigator.pushNamed(context, webviewRoute,
                  arguments: {'title': 'Syarat dan Ketentuan', 'url': 'https://dairyfood.app/terms-and-condition'}),
            ),
            const Divider(thickness: 1, height: 0),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.security),
              title: const Text('Kebijakan Privasi'),
              minLeadingWidth: 0,
              horizontalTitleGap: 10,
              onTap: () => Navigator.pushNamed(context, webviewRoute,
                  arguments: {'title': 'Kebijakan Privasi', 'url': 'https://dairyfood.app/privacy-policy'}),
            ),
            const Divider(thickness: 1, height: 0),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Kami'),
              minLeadingWidth: 0,
              horizontalTitleGap: 10,
              onTap: () => Navigator.pushNamed(context, webviewRoute, arguments: {'title': 'Tentang Kami', 'url': 'https://dairyfood.app/about'}),
            ),
            const Divider(thickness: 1, height: 0),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.exit_to_app,
                color: mPrimaryColor,
              ),
              title: const Text(
                'Keluar',
                style: TextStyle(color: mPrimaryColor),
              ),
              onTap: keluar,
              minLeadingWidth: 0,
              horizontalTitleGap: 10,
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(version),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
