import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Alerts {
  static Future<void> dialog(BuildContext context, {required String content, String? title, Function()? ok, Function()? cancel}) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title ?? 'Oops'),
          content: Text(content),
          actions: cancel == null
              ? [
                  CupertinoDialogAction(
                    textStyle: const TextStyle(color: Colors.blue),
                    onPressed: ok ?? () => Navigator.pop(context),
                    child: const Text('Ok'),
                  )
                ]
              : [
                  CupertinoDialogAction(
                    textStyle: const TextStyle(color: Colors.red),
                    isDestructiveAction: true,
                    onPressed: cancel,
                    child: const Text('Tidak'),
                  ),
                  CupertinoDialogAction(
                    textStyle: const TextStyle(color: Colors.blue),
                    onPressed: ok ?? () => Navigator.pop(context),
                    child: const Text('Ya'),
                  )
                ],
        ),
      );
    }
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Oops'),
        content: Text(content),
        actions: [
          cancel == null
              ? Container()
              : OutlinedButton(
                  onPressed: cancel,
                  child: const Text('Tidak'),
                ),
          ElevatedButton(
            onPressed: ok ?? () => Navigator.pop(context),
            child: Text(cancel == null ? 'Ok' : 'Ya'),
          )
        ],
      ),
    );
  }
}
