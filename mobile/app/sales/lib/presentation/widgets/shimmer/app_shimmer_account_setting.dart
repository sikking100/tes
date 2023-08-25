import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:sales/presentation/widgets/shimmer/app_shimmer.dart';

class AppShimmerAccountSetting extends StatelessWidget {
  const AppShimmerAccountSetting({Key? key}) : super(key: key);

  Widget textFromFieldShimmer(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmerPrimary(
          height: Dimens.px14,
          width: size.width * 0.2,
        ),
        const SizedBox(height: 4),
        AppShimmerPrimary(
          height: Dimens.px18,
          width: size.width * 0.8,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimens.px12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: AppShimmerPrimary(
              height: 120,
              width: 120,
              radius: 100,
            ),
          ),
          const SizedBox(height: Dimens.px30),
          textFromFieldShimmer(context),
          const SizedBox(height: Dimens.px30),
          textFromFieldShimmer(context),
          const SizedBox(height: Dimens.px30),
          textFromFieldShimmer(context),
          const SizedBox(height: Dimens.px30),
          textFromFieldShimmer(context),
          const SizedBox(height: Dimens.px30),
          textFromFieldShimmer(context),
          const SizedBox(height: Dimens.px30),
          textFromFieldShimmer(context),
          const SizedBox(height: Dimens.px30),
          textFromFieldShimmer(context),
          const SizedBox(height: Dimens.px30),
          textFromFieldShimmer(context),
        ],
      ),
    );
  }
}
