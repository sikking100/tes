import 'package:flutter/material.dart';

class AppSquareButtonWidget extends StatelessWidget {
  final Function() onPress;
  final IconData icon;
  final String title;
  const AppSquareButtonWidget(
      {Key? key,
      required this.onPress,
      required this.icon,
      required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(
          const RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey),
          ),
        ),
        foregroundColor: MaterialStateProperty.all(
          Colors.grey,
        ),
        backgroundColor: MaterialStateProperty.all(
          Colors.transparent,
        ),
      ),
      onPressed: onPress,
      icon: Icon(
        icon,
      ),
      label: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
