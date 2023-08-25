import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:sales/presentation/widgets/shimmer/app_shimmer.dart';

class AppShimmerProduct extends StatelessWidget {
  const AppShimmerProduct({super.key});
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
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.px12),
      ),
      elevation: 1.5,
      shadowColor: theme.highlightColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppShimmerPrimary(
            height: 160,
            width: size.width,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.px10),
            child: Column(
              children: [
                const SizedBox(height: 4),
                textFromFieldShimmer(context, size.width * 0.3),
                const SizedBox(height: 4),
                textFromFieldShimmer(context, size.width * 0.3),
                const SizedBox(height: 4),
                textFromFieldShimmer(context, size.width * 0.3),
                const SizedBox(height: 4),
              ],
            ),
          ),
          AppShimmerPrimary(
            height: 40,
            width: size.width,
          ),
        ],
      ),
    );
  }
}
