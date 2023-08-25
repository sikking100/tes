import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sales/config/app_assets.dart';

class AppEmptyWidget extends StatelessWidget {
  const AppEmptyWidget({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AppAssets.animEmpty,
            width: size.width * 0.4,
            height: size.width * 0.4,
          ),
          Text(
            title,
            style: theme.textTheme.subtitle1,
          ),
        ],
      ),
    );
  }
}
