import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmerMapAddress extends StatelessWidget {
  const AppShimmerMapAddress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmerPrimary(
          height: Dimens.px16,
          width: size.width,
        ),
        const SizedBox(height: Dimens.px6),
        AppShimmerPrimary(
          height: Dimens.px16,
          width: size.width * 0.6,
        ),
      ],
    );
  }
}

class AppShimmerPrimary extends StatelessWidget {
  const AppShimmerPrimary({
    Key? key,
    this.child,
    this.height,
    this.width,
    this.radius,
  }) : super(key: key);

  final Widget? child;
  final double? height;
  final double? width;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.onSurface.withOpacity(0.5),
      highlightColor: theme.highlightColor.withOpacity(0.5),
      child: child ??
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(radius ?? 4),
            ),
          ),
    );
  }
}
