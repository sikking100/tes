import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sales/presentation/widgets/app_scaffold_messenger.dart';

class Copy extends StatelessWidget {
  final String text;
  const Copy({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Dimens.px14,
      width: Dimens.px14,
      child: IconButton(
        splashRadius: 24,
        padding: EdgeInsets.zero,
        iconSize: Dimens.px14,
        color: mArrowIconColor,
        icon: const Icon(Icons.copy),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: text));
          if (text.isNotEmpty) {
            AppScaffoldMessanger.showSnackBar(
                context: context, message: "Berhasil disalin");
          }
        },
      ),
    );
  }
}
