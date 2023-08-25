import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sales/config/app_assets.dart';
import 'package:sales/config/app_pages.dart';

class AppImagePrimary extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double? radius;
  final BoxFit? fit;
  final bool isOnTap;

  const AppImagePrimary({
    Key? key,
    this.height,
    this.width,
    this.radius,
    this.fit,
    this.isOnTap = false,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String assetName = AppAssets.imgDefaultImage;
    return InkWell(
      onTap: isOnTap
          ? () => Navigator.pushNamed(
                context,
                AppRoutes.photo,
                arguments: {'photo': imageUrl},
              )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 0),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          progressIndicatorBuilder: (_, __, ___) {
            return SizedBox(
              width: width,
              height: height,
              child: Image.asset(
                assetName,
                fit: BoxFit.cover,
              ),
            );
          },
          errorWidget: (_, __, ___) {
            return SizedBox(
              width: width,
              height: height,
              child: Image.asset(
                assetName,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}
