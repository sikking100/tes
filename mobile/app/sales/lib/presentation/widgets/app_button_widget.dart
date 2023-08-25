import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';

class ButtonPlusMin extends StatelessWidget {
  final Function() onPlus;
  final Function()? onMin;
  final Function()? onTap;
  final String text;
  const ButtonPlusMin({
    Key? key,
    required this.onPlus,
    this.onMin,
    this.onTap,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onMin,
          icon: const Icon(Icons.remove_circle),
          visualDensity: VisualDensity.compact,
          splashRadius: 24,
          color: Colors.black,
        ),
        const SizedBox(width: Dimens.px12),
        InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Center(
              child: Text(text, style: theme.textTheme.titleSmall),
            ),
          ),
        ),
        const SizedBox(width: Dimens.px12),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle),
          visualDensity: VisualDensity.compact,
          splashRadius: 24,
          color: Colors.black,
        ),
      ],
    );
  }
}

class AppButtonLoading extends StatelessWidget {
  const AppButtonLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: 46,
      child: const ElevatedButton(
        onPressed: null,
        child: SizedBox(
          height: Dimens.px16,
          width: Dimens.px16,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }
}

class AppButtonPrimary extends StatelessWidget {
  const AppButtonPrimary({
    Key? key,
    required this.onPressed,
    required this.title,
  }) : super(key: key);

  final void Function() onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: 46,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}

class AppButtonDisable extends StatelessWidget {
  const AppButtonDisable({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: 46,
      child: ElevatedButton(
        onPressed: null,
        child: Text(title),
      ),
    );
  }
}
