import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:sales/presentation/widgets/shimmer/app_shimmer.dart';

class AppShimmerOrder extends StatelessWidget {
  const AppShimmerOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmerPrimary(
          height: size.height * 0.30,
          width: size.width,
        ),
        const SizedBox(height: Dimens.px8),
        Row(
          children: [
            Expanded(
              child: AppShimmerPrimary(
                height: 36,
                width: size.width * 0.5,
                radius: 100,
              ),
            ),
          ],
        ),
        const Divider()
      ],
    );
  }
}
