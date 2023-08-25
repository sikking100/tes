import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:sales/presentation/widgets/shimmer/app_shimmer.dart';

class AppShimmerCustomer extends StatelessWidget {
  const AppShimmerCustomer({super.key});

  Widget textFromFieldShimmer(BuildContext context, double widht) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmerPrimary(
          height: Dimens.px18,
          width: widht,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      child: Column(
        children: [
          Row(
            children: [
              const AppShimmerPrimary(
                height: 60,
                width: 60,
                radius: 100,
              ),
              const SizedBox(width: Dimens.px8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textFromFieldShimmer(context, size.width * 0.3),
                    const SizedBox(height: 4),
                    textFromFieldShimmer(context, size.width * 0.5),
                    const SizedBox(height: 4),
                    textFromFieldShimmer(context, size.width * 0.5),
                  ],
                ),
              ),
              const SizedBox(width: Dimens.px8),
              const AppShimmerPrimary(
                height: 40,
                width: 40,
                radius: 100,
              ),
              const SizedBox(width: Dimens.px8),
              const AppShimmerPrimary(
                height: 40,
                width: 40,
                radius: 100,
              ),
            ],
          ),
          const Divider()
        ],
      ),
    );
  }
}
