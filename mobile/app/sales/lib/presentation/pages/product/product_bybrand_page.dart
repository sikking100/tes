import 'package:badges/badges.dart' as badge;
import 'package:common/constant/constant.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/presentation/pages/cart/provider/cart_provider.dart';
import 'package:sales/presentation/pages/product/product_page.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/widgets/app_empty_widget.dart';
import 'package:sales/presentation/widgets/app_smart_refresher_widget.dart';

class ProductByBrandIdPage extends ConsumerWidget {
  final ArgProductList arg;
  const ProductByBrandIdPage({Key? key, required this.arg}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productListNotifierProvider(arg));
    final stateWatch = ref.watch(productListNotifierProvider(arg).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(arg.title),
        actions: [
          IconButton(
            icon: Builder(builder: (_) {
              final stateWatch = ref.watch(cartStateNotifier);
              final carts = stateWatch.toSet().toList();
              if (carts.isEmpty) {
                return const Icon(Icons.shopping_cart_outlined);
              }
              return badge.Badge(
                badgeContent: Text(carts.length.toString(),
                    style: const TextStyle(color: Colors.white)),
                badgeStyle: const badge.BadgeStyle(
                  badgeColor: Colors.red,
                ),
                child: const Icon(Icons.shopping_cart_outlined),
              );
            }),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.cartPage);
            },
          ),
        ],
      ),
      body: SmartRefresherWidget(
        controller: stateWatch.controller,
        onLoading: () {
          stateWatch.onLoading();
        },
        onRefresh: () {
          stateWatch.onRefresh();
        },
        child: Builder(
          builder: (context) {
            if (stateWatch.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (product.items.isNotEmpty) {
              return AlignedGridView.count(
                physics: const BouncingScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: Dimens.px6,
                crossAxisSpacing: Dimens.px6,
                padding: const EdgeInsets.all(Dimens.px12),
                itemBuilder: (context, index) {
                  return ProductCart(
                    price: product.items[index],
                  );
                },
                itemCount: product.items.length,
              );
            }
            return AppEmptyWidget(
              title: "Belum ada produk ${arg.title}",
            );
          },
        ),
      ),
    );
  }
}
