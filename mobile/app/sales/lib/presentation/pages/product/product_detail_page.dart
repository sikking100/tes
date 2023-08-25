import 'package:api/product/model.dart';
import 'package:badges/badges.dart' as badge;
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/presentation/pages/cart/cart_page.dart';
import 'package:sales/presentation/pages/cart/provider/cart_provider.dart';
import 'package:sales/presentation/pages/order/provider/order_checkout_provider.dart';
import 'package:sales/presentation/pages/product/product_page.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/widgets/app_alert_dialog.dart';
import 'package:sales/presentation/widgets/app_button_widget.dart';
import 'package:sales/presentation/widgets/app_image_widget.dart';
import 'package:sales/presentation/widgets/app_scaffold_messenger.dart';

class ProductDetailPage extends ConsumerWidget {
  final Product price;
  const ProductDetailPage({Key? key, required this.price}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateRead = ref.read(createOrderStateProvider.notifier);
    final stateOrderWatch = ref.watch(createOrderStateProvider);
    final cusWatch = ref.watch(customerStateProvider);
    final stateWatch = ref.watch(cartStateNotifier);
    final statereadNotifier = ref.read(cartStateNotifier.notifier);
    // final List<Discount> itemsDis =
    //     price.price.first.discount.isEmpty ? [] : price.price.first.discount;
    // final dis = itemsDis.isNotEmpty == true ? itemsDis.first.discount : 0;
    int qty =
        stateWatch.where((element) => element.id == price.id).toList().length;
    final totalPrice = ref.watch(cartStateNotifier.notifier).totalProduct();
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final productWatch = price;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Produk'),
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
      body: CustomScrollView(
        slivers: [
          Builder(
            builder: (_) {
              return SliverFillRemaining(
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Dimens.px10),
                      color: theme.highlightColor.withOpacity(0.3),
                      child: AppImagePrimary(
                        isOnTap: true,
                        imageUrl: productWatch.imageUrl,
                        height: size.width * 0.6,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(Dimens.px16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Description(
                            price: price,
                          ),
                          const SizedBox(height: Dimens.px20),
                          Text(
                            'Kategori',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Dimens.px6),
                          Text(productWatch.category.name),
                          const SizedBox(height: Dimens.px20),
                          Text(
                            'Deskripsi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Dimens.px6),
                          Text(productWatch.description),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: theme.scaffoldBackgroundColor,
        elevation: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Dimens.px12),
            ButtonPlusMin(
              onTap: () {
                showBottomSheetUpdateQty(
                  context,
                  price: price,
                  ref: ref,
                );
              },
              onPlus: () {
                statereadNotifier.add(price);
              },
              onMin: () {
                if (qty <= 1) {
                  AppActionDialog.show(
                    context: context,
                    isAction: true,
                    title: "Konfirmasi",
                    content:
                        "Apakah Anda yakin ingin menghapus item ini dari keranjang?",
                    onPressNo: () {
                      Navigator.pop(context);
                    },
                    onPressYes: () {
                      statereadNotifier.remove(price.id);
                      Navigator.pop(context);
                    },
                  );
                } else {
                  statereadNotifier.remove(price.id);
                }
              },
              text: qty.toString(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Material(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(Dimens.px30),
                  ),
                  child: InkWell(
                    onTap: () async {
                      try {
                        if (totalPrice == 0) {
                          throw 'Pilih produk terlebih dahulu.';
                        }
                        if (totalPrice < 50000) {
                          throw 'Belanjaan Anda masih kurang dari ${50000.currency()}.  Belanja lagi yuk!';
                        }
                        stateRead.setState(
                          stateOrderWatch.copyWith(
                            customer: stateOrderWatch.customer.copyWith(
                              addressLngLat: [
                                cusWatch.business!.address.first.lng,
                                cusWatch.business!.address.first.lat
                              ],
                              addressName:
                                  cusWatch.business!.address.first.name,
                            ),
                          ),
                        );
                        Navigator.pushNamed(context, AppRoutes.orderCheckout);
                      } catch (e) {
                        AppScaffoldMessanger.showSnackBar(
                            context: context, message: e.toString());
                        return;
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 46,
                        vertical: Dimens.px16,
                      ),
                      child: Text(
                        'Checkout',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.px16, vertical: Dimens.px6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Sub total', style: theme.textTheme.titleMedium),
                        Text(
                          totalPrice.currency(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Description extends ConsumerWidget {
  const _Description({Key? key, required this.price}) : super(key: key);
  final Product price;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Product product = price;
    // final List<Discount> itemsDis =
    //     price.price.first.discount.isEmpty ? [] : price.price.first.discount;
    // final dis = itemsDis.isNotEmpty == true ? itemsDis.first.discount : 0;
    // final min = itemsDis == null ? itemsDis.first.min : 0;
    // final max = itemsDis == null ? itemsDis.first.max : 0;
    // final stateWatch = ref.watch(cartStateNotifier);
    // int qty =
    //     stateWatch.where((element) => element.id == price.id).toList().length;
    // final priceDis = price.price.first.price - dis;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(Dimens.px10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(Dimens.px16),
          ),
          child: AppImagePrimary(
            isOnTap: true,
            imageUrl: price.brand.imageUrl,
            height: size.width * 0.20,
            width: size.width * 0.20,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: Dimens.px16),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                product.size,
                style: theme.textTheme.titleSmall,
              ),
              TextPrice(
                product: product,
                isFront: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
