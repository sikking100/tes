import 'dart:io';

import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:sales/presentation/widgets/app_button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AppBottomSheet {
  static void showBottomSheetImage({
    required BuildContext context,
    required String title,
    required void Function() onTapGalery,
    required void Function() onTapCamera,
  }) async {
    final theme = Theme.of(context);
    await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimens.px30),
        ),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimens.px12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: Dimens.px10),
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: Dimens.px10),
              ItemBottomSheet(
                title: 'Ambil Gambar',
                iconData: Icons.camera_alt_outlined,
                onTap: onTapCamera,
              ),
              const SizedBox(height: 4),
              ItemBottomSheet(
                title: 'Pilih File',
                iconData: Icons.photo_outlined,
                onTap: onTapGalery,
              ),
            ],
          ),
        );
      },
    );
  }

  static void showBottomSheet({
    required BuildContext context,
    void Function()? onTapCanvassing,
    void Function()? onTapPremier,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: Dimens.px16),
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimens.px30),
                topRight: Radius.circular(Dimens.px30),
              )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Pilih Gudang",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Dimens.px10),
              ItemBottomSheet(
                title: "Kanvas",
                iconData: Icons.local_shipping_outlined,
                onTap: onTapCanvassing,
              ),
              ItemBottomSheet(
                title: "Utama",
                iconData: Icons.warehouse_outlined,
                onTap: onTapPremier,
              ),
              const SizedBox(height: Dimens.px10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimens.px8),
                height: 42,
                width: MediaQuery.of(context).size.width,
                child: AppButtonPrimary(
                    onPressed: () => Navigator.pop(context), title: "Batal"),
              )
            ],
          ),
        );
      },
    );
  }

  static void showBottomSheetCall({
    required BuildContext context,
    required String phone,
  }) async {
    final theme = Theme.of(context);
    await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimens.px30),
        ),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimens.px12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: Dimens.px10),
              Text('Hubungi Menggunakan', style: theme.textTheme.titleLarge),
              const SizedBox(height: Dimens.px10),
              ItemBottomSheet(
                title: 'Telepon',
                iconData: Icons.phone_outlined,
                onTap: () async {
                  Navigator.pop(context);
                  final Uri launchUri = Uri(
                    scheme: 'tel',
                    path: phone,
                  );
                  await launchUrl(launchUri);
                },
              ),
              const SizedBox(height: 4),
              ItemBottomSheet(
                title: 'WhatsApp',
                iconData: Icons.message_outlined,
                onTap: () async {
                  Navigator.pop(context);
                  String url = '';
                  if (Platform.isAndroid) {
                    url = "whatsapp://send?phone=$phone&text=";
                  } else {
                    url = "https://api.whatsapp.com/send?phone=$phone&text=";
                  }
                  await launchUrl(Uri.parse(url));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ItemBottomSheet extends StatelessWidget {
  final String title;
  final IconData iconData;
  final void Function()? onTap;
  final bool danger;
  const ItemBottomSheet({
    Key? key,
    required this.title,
    required this.iconData,
    this.onTap,
    this.danger = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Ink(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.px12,
              vertical: Dimens.px10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(iconData, color: danger ? theme.colorScheme.error : null),
                const SizedBox(width: Dimens.px16),
                Flexible(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: danger ? theme.colorScheme.error : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
