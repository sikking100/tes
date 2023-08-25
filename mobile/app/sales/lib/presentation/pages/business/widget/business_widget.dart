import 'dart:developer';

import 'package:api/customer/model.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/widgets/app_bottom_sheet.dart';
import 'package:sales/presentation/widgets/app_image_widget.dart';

class BusinessWidget extends ConsumerWidget {
  final Customer customer;
  const BusinessWidget({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        ref.read(customerStateProvider.notifier).update((state) => customer);
        Navigator.pushNamed(
          context,
          AppRoutes.businessDetail,
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppImagePrimary(
                isOnTap: true,
                imageUrl: customer.imageUrl,
                height: 64,
                width: 64,
                radius: 100,
              ),
              const SizedBox(width: Dimens.px12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ref
                      .read(customerStateProvider.notifier)
                      .update((state) => customer);
                  log(customer.toJson());
                  Navigator.pushNamed(context, AppRoutes.productList,
                      arguments: ArgProductList(title: "Terbaru"));
                },
                icon: const Icon(Icons.add_shopping_cart_rounded),
              ),
              IconButton(
                onPressed: () {
                  AppBottomSheet.showBottomSheetCall(
                    context: context,
                    phone: customer.phone,
                  );
                },
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.phone,
                ),
              ),
            ],
          ),
          const Divider()
        ],
      ),
    );
  }
}
