import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';

class Ribbon extends StatelessWidget {
  const Ribbon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey.shade400,
      ),
    );
  }
}

class WidgetError extends StatelessWidget {
  final String error;
  final void Function()? onPressed;
  const WidgetError({super.key, required this.error, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.px16),
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.px10),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
