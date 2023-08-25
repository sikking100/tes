import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:sales/presentation/widgets/shimmer/app_shimmer.dart';

class AppShimmerInvoice extends StatelessWidget {
  const AppShimmerInvoice({Key? key}) : super(key: key);

  Widget textFromFieldShimmer(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmerPrimary(
          height: Dimens.px14,
          width: size.width * 0.4,
        ),
        const SizedBox(height: 4),
        AppShimmerPrimary(
          height: Dimens.px18,
          width: size.width * 0.8,
        ),
        const SizedBox(height: 4),
        AppShimmerPrimary(
          height: Dimens.px18,
          width: size.width * 0.8,
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
      padding: const EdgeInsets.symmetric(
          vertical: Dimens.px10, horizontal: Dimens.px16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.px16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimens.px16),
              textFromFieldShimmer(context),
              const SizedBox(height: Dimens.px16),
            ],
          ),
        ),
      ),
    );
  }
}
