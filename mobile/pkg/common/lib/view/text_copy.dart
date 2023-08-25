import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextCopy extends StatelessWidget {
  final String text;
  final bool isColor;
  const TextCopy({super.key, required this.text, this.isColor = true});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$text ',
            style: TextStyle(color: isColor ? mOrderHistoryTitleColor : null),
          ),
          WidgetSpan(
            child: GestureDetector(
              child: const Icon(Icons.copy, size: 17),
              onTap: () => Clipboard.setData(ClipboardData(text: text)).then(
                (value) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil disalin'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
