import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/presentation/pages/cart/provider/cart_provider.dart';
import 'package:sales/presentation/pages/product/product_page.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/pages/product/view/product_search_view.dart';
import 'package:badges/badges.dart' as badge;
import 'package:sales/presentation/widgets/app_smart_refresher_widget.dart';

class ProductAllPage extends ConsumerStatefulWidget {
  final ArgProductList arg;
  const ProductAllPage({super.key, required this.arg});

  @override
  ConsumerState<ProductAllPage> createState() => _ProductAllPageState();
}

class _ProductAllPageState extends ConsumerState<ProductAllPage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productListNotifierProvider(widget.arg));
    final stateproduct =
        ref.watch(productListNotifierProvider(widget.arg).notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('Produk ${widget.arg.title}'),
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
      body: NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.extentAfter == 0.0) {
              setState(
                () {
                  _currentIndex = 1;
                },
              );
            }
            if (notification.metrics.extentBefore == 0.0) {
              setState(
                () {
                  _currentIndex = 0;
                },
              );
            }
          }
          return true;
        },
        child: SmartRefresherWidget(
          controller: stateproduct.controller,
          onRefresh: () => stateproduct.onRefresh(),
          onLoading: () => stateproduct.onLoading(),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(
                  Dimens.px16,
                ),
                sliver: SliverAlignedGrid.count(
                  itemBuilder: (context, index) {
                    return ProductCart(
                      price: product.items[index],
                    );
                  },
                  itemCount: product.items.length,
                  crossAxisCount: 2,
                  mainAxisSpacing: Dimens.px6,
                  crossAxisSpacing: Dimens.px6,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => ProductSearchView.showCustomerSearch(context),
              child: const Icon(Icons.search),
            )
          : null,
    );
  }
}
