import 'package:courier/common/constant.dart';
import 'package:courier/common/widget.dart';
import 'package:courier/firebase/auth.dart';
import 'package:courier/function/function.dart';
import 'package:courier/presentation/page/page_home.dart';
import 'package:courier/presentation/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewKelola extends StatelessWidget {
  const ViewKelola({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola'),
      ),
      body: Padding(
        padding: mPadding,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AKUN'),
              ListTile(
                shape: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.1,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: const Text('Kelola Akun'),
                minLeadingWidth: 0,
                horizontalTitleGap: 10,
                minVerticalPadding: 0,
                onTap: () => Navigator.pushNamed(context, Routes.editProfile),
              ),
              ListTile(
                shape: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.1,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history_outlined),
                title: const Text('Riwayat Pengantaran'),
                minLeadingWidth: 0,
                horizontalTitleGap: 10,
                minVerticalPadding: 0,
                onTap: () => Navigator.pushNamed(context, Routes.riwayat),
              ),
              ListTile(
                shape: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.1,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.star_outline),
                title: const Text('Beri Rating'),
                minLeadingWidth: 0,
                horizontalTitleGap: 10,
                onTap: () async {
                  await launchs('https://play.google.com/store/apps/details?id=app.dairyfood.courier');
                },
              ),
              const SizedBox(height: 15),
              const Text('DUKUNGAN'),
              ListTile(
                shape: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.1,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.help_outline),
                title: const Text('Pusat Bantuan'),
                minLeadingWidth: 0,
                horizontalTitleGap: 10,
                onTap: () => Navigator.pushNamed(context, Routes.webview, arguments: 'https://dairyfood.app/help'),
              ),
              const SizedBox(height: 15),
              const Text('TENTANG KAMI'),
              ListTile(
                shape: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.1,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.file_copy_outlined),
                title: const Text('Syarat dan Ketentuan'),
                minLeadingWidth: 0,
                horizontalTitleGap: 10,
                onTap: () => Navigator.pushNamed(context, Routes.webview, arguments: 'https://dairyfood.app/terms-and-condition'),
              ),
              ListTile(
                shape: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.1,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Kebijakan Privasi'),
                minLeadingWidth: 0,
                horizontalTitleGap: 10,
                onTap: () => Navigator.pushNamed(context, Routes.webview, arguments: 'https://dairyfood.app/privacy-policy'),
              ),
              ListTile(
                shape: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.1,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: const Text('Tentang Kami'),
                minLeadingWidth: 0,
                horizontalTitleGap: 10,
                onTap: () => Navigator.pushNamed(context, Routes.webview, arguments: 'https://dairyfood.app/about'),
              ),
              Consumer(
                builder: (context, ref, child) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.exit_to_app,
                    color: mPrimaryColor,
                  ),
                  title: const Text(
                    'Keluar',
                    style: TextStyle(color: mPrimaryColor),
                  ),
                  minLeadingWidth: 0,
                  horizontalTitleGap: 10,
                  onTap: () => warning(
                    context,
                    title: 'Peringatan',
                    errorText: 'Anda yakin ingin keluar?',
                    onPressed: () async {
                      Auth.instance.signOut().then(
                        (value) {
                          ref.invalidate(userStateProvider);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
