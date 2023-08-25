import 'package:flutter/material.dart';

class AppAlertDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    required void Function() onPressYes,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        var height = MediaQuery.of(context).size.height;
        var width = MediaQuery.of(context).size.width;
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text(title),
          content: SizedBox(
            height: height - 600,
            width: width - 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Image.asset("assets/ordersuccess.png")),
                Text(
                  content,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: onPressYes,
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}

class AppActionDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    void Function()? onPressNo,
    void Function()? onPressYes,
    required bool isAction,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        if (isAction == false) {
          Future.delayed(
            const Duration(seconds: 3),
            () => Navigator.of(context).pop(),
          );
        }
        return AlertDialog(
          title: Text(title),
          content: Text(
            content,
          ),
          actions: isAction
              ? [
                  OutlinedButton(
                    onPressed: onPressNo,
                    child: const Text('Tidak'),
                  ),
                  ElevatedButton(
                    onPressed: onPressYes,
                    child: const Text('Ya'),
                  ),
                ]
              : [],
        );
      },
    );
  }
}
