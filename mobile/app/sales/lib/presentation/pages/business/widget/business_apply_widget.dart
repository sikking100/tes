import 'package:api/customer/model.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/widgets/app_bottom_sheet.dart';
import 'package:sales/presentation/widgets/app_image_widget.dart';

class BusinessApplyWidget extends ConsumerWidget {
  final Apply customer;
  const BusinessApplyWidget({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        ref.read(customerStateProvider.notifier).update((state) => Customer(
              id: customer.id,
              name: customer.customer.name,
              phone: customer.customer.phone,
              imageUrl: customer.customer.imageUrl,
            ));
        Navigator.pushNamed(
          context,
          AppRoutes.businessApplyDetail,
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppImagePrimary(
                isOnTap: true,
                imageUrl: customer.customer.imageUrl,
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
                      customer.customer.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.customer.phone,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  AppBottomSheet.showBottomSheetCall(
                    context: context,
                    phone: customer.customer.phone,
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
