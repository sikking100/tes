import 'package:api/api.dart';
import 'package:badges/badges.dart' as badge;
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'package:sales/config/app_pages.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/presentation/pages/cart/cart_page.dart';
import 'package:sales/presentation/pages/cart/provider/cart_provider.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/pages/product/view/product_search_view.dart';
import 'package:sales/presentation/widgets/app_alert_dialog.dart';
import 'package:sales/presentation/widgets/app_image_widget.dart';
import 'package:sales/presentation/widgets/app_smart_refresher_widget.dart';

final brandStateNotifierProvider =
    StateNotifierProvider.autoDispose<BrandNotifier, List<Brand>>((ref) {
  return BrandNotifier(ref);
});

class BrandNotifier extends StateNotifier<List<Brand>> {
  BrandNotifier(AutoDisposeRef ref) : super([]) {
    api = ref.watch(apiProvider);
    error = '';
    controller = RefreshController(initialRefresh: true);
  }
  late final Api api;
  late String error;
  late final RefreshController controller;

  void onRefresh() async {
    try {
      controller.resetNoData();
      final result = await api.brand.all();
      state = result;
      controller.refreshCompleted();
      return;
    } catch (e) {
      error = e.toString();
      controller.refreshFailed();
    }
  }

  void onLoading() async {
    try {
      controller.loadNoData();
      final result = await api.brand.all();
      state.addAll(result);
      controller.loadComplete();
      return;
    } catch (e) {
      error = e.toString();
      controller.loadFailed();
    }
  }
}

class ProductPage extends ConsumerStatefulWidget {
  final ArgProductList arg;
  const ProductPage({super.key, required this.arg});

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandStateNotifierProvider);
    final brandWatch = ref.watch(brandStateNotifierProvider.notifier);
    final productNew = ref.watch(newProductProvider);
    final productPopular = ref.watch(productLarisProvider);
    final productDiscount = ref.watch(productDiskonProvider);
    final scrollController = ScrollController();

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
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
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => ProductSearchView.showCustomerSearch(context),
              child: const Icon(Icons.search),
            )
          : null,
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
          controller: brandWatch.controller,
          onRefresh: () {
            brandWatch.onRefresh();
          },
          onLoading: () {
            brandWatch.onLoading();
          },
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: Dimens.px16),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: size.height * 0.12,
                    child: ListView.separated(
                      controller: scrollController,
                      shrinkWrap: true,
                      padding:
                          const EdgeInsets.symmetric(horizontal: Dimens.px16),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: size.height * 0.12,
                          child: Card(
                            clipBehavior: Clip.hardEdge,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Dimens.px12,
                              ),
                            ),
                            elevation: 1.5,
                            shadowColor: theme.highlightColor,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.productListByBrand,
                                  arguments: ArgProductList(
                                    title: brand[index].name,
                                    idBrand: brand[index].id,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(Dimens.px10),
                                color: theme.highlightColor.withOpacity(0.3),
                                child: AppImagePrimary(
                                  isOnTap: false,
                                  imageUrl: brand[index].imageUrl,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          width: Dimens.px8,
                        );
                      },
                      itemCount: brand.length,
                    ),
                  ),
                ),
              ),
              productNew.when(
                loading: () => const SliverPadding(
                  padding: EdgeInsets.only(bottom: Dimens.px16),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 350,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                data: (data) {
                  if (data.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox());
                  }
                  return listProduct(
                    context: context,
                    menu: "Produk terbaru",
                    data: data,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.productAllPage,
                      arguments: ArgProductList(title: "Terbaru"),
                    ),
                  );
                },
                error: (error, stackTrace) => SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(error.toString()),
                )),
              ),
              productPopular.when(
                loading: () => const SliverPadding(
                  padding: EdgeInsets.only(bottom: Dimens.px16),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 350,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                data: (data) {
                  if (data.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox());
                  }
                  return listProduct(
                    context: context,
                    menu: "Produk terlaris",
                    data: data,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.productAllPage,
                      arguments: ArgProductList(title: "Terlaris"),
                    ),
                  );
                },
                error: (error, stackTrace) => SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(error.toString()),
                )),
              ),
              productDiscount.when(
                loading: () => const SliverPadding(
                  padding: EdgeInsets.only(bottom: Dimens.px16),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 350,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                data: (data) {
                  if (data.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox());
                  }
                  return listProduct(
                    context: context,
                    menu: "Produk promo",
                    data: data,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.productAllPage,
                      arguments: ArgProductList(title: "Promo"),
                    ),
                  );
                },
                error: (error, stackTrace) => SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(error.toString()),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget listProduct(
    {required BuildContext context,
    required String menu,
    required List<Product> data,
    required Function() onTap}) {
  return SliverPadding(
    padding: const EdgeInsets.symmetric(
      horizontal: Dimens.px16,
    ),
    sliver: SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    menu,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: onTap,
                    child: const Text(
                      "Lihat semua",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: data.isEmpty
                  ? Container()
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: ProductCart(price: data[index]),
                      ),
                      separatorBuilder: (context, index) => const SizedBox(
                        width: 8,
                      ),
                      itemCount: data.length,
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ProductCart extends ConsumerWidget {
  const ProductCart({
    Key? key,
    required this.price,
  }) : super(key: key);
  final Product price;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.productDetail,
                arguments: price,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimens.px10),
                  color: theme.highlightColor.withOpacity(0.3),
                  width: size.width,
                  child: AppImagePrimary(
                    imageUrl: price.imageUrl,
                    height: size.height * 0.16,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Dimens.px8),
                  child: Column(
                    children: [
                      Text(
                        price.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        price.size,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      TextPrice(product: price),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _ButtonCart(price: price),
        ],
      ),
    );
  }
}

class _ButtonCart extends ConsumerWidget {
  const _ButtonCart({Key? key, required this.price}) : super(key: key);
  final Product price;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateWatch = ref.watch(cartStateNotifier);
    final statereadNotifier = ref.read(cartStateNotifier.notifier);

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    int qty =
        stateWatch.where((element) => element.id == price.id).toList().length;
    if (qty == 0) {
      return Material(
        color: theme.primaryColor,
        child: InkWell(
          onTap: () => statereadNotifier.add(price),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.px10,
              vertical: Dimens.px10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_outlined,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'keranjang',
                    maxLines: 1,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        showBottomSheetUpdateQty(
          context,
          price: price,
          ref: ref,
        );
      },
      child: SizedBox(
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: theme.primaryColor,
              child: InkWell(
                onTap: () {
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
                child: const Padding(
                  padding: EdgeInsets.all(Dimens.px10),
                  child: Icon(Icons.remove, color: Colors.white),
                ),
              ),
            ),
            Text(qty.toString()),
            Material(
              color: theme.primaryColor,
              child: InkWell(
                onTap: () {
                  statereadNotifier.add(price);
                },
                child: const Padding(
                  padding: EdgeInsets.all(Dimens.px10),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextPrice extends ConsumerWidget {
  final Product product;
  final bool? isFront;
  final bool isPromo;
  const TextPrice(
      {Key? key,
      required this.product,
      this.isFront = true,
      this.isPromo = false})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartStateNotifier.notifier);
    final c = ref.watch(cartStateNotifier).where((element) {
      return element.productId == product.productId;
    });
    final customer = ref.watch(customerStateProvider);
    final price = product.kPrice(customer.business?.priceList.id);
    Widget dcText() {
      final disc = price.discount;
      if (price.discount.isEmpty) return Container();
      if (disc.length == 1) {
        if (c.length < disc.first.min || c.length > (disc.first.max ?? 0)) {
          return Column(
            crossAxisAlignment: isFront == true
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                '${c.length < (price.discount.first.min) ? 'Min Pembelian ${price.discount.first.min}' : 'Maks Pembelian ${(price.discount.first.max ?? '-')}'}  ',
                maxLines: 1,
              ),
              Text(
                'Disc ${price.discount.first.discount.currency()}',
                maxLines: 1,
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: isFront == true
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                'Min Pembelian ${c.isEmpty ? price.discount.first.min : cart.discount(product.productId).min}',
                style: const TextStyle(
                  color: Colors.red,
                ),
                maxLines: 1,
              ),
              Text(
                'Disc ${cart.discount(product.productId).discount.currency()}',
                style: const TextStyle(
                  color: Colors.red,
                ),
                maxLines: 1,
              ),
            ],
          );
        }
      } else {
        if (c.length < disc.first.min) {
          return Column(
            crossAxisAlignment: isFront == true
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                'Min Pembelian ${disc.first.min}',
                maxLines: 1,
              ),
              Text(
                'Disc ${disc.first.discount.currency()}',
                maxLines: 1,
              ),
            ],
          );
        }
        if (cart.discount(product.productId).discount != 0) {
          return Column(
            crossAxisAlignment: isFront == true
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                '${c.length == cart.discount(product.productId).min ? 'Min Pembelian ${cart.discount(product.productId).min}' : 'Maks Pembelian ${cart.discount(product.productId).max ?? '-'}'} ',
                style: const TextStyle(color: Colors.red),
                maxLines: 1,
              ),
              Text(
                'Disc ${cart.discount(product.productId).discount.currency()}',
                style: const TextStyle(color: Colors.red),
                maxLines: 1,
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: isFront == true
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              'Maks Pembelian ${disc.last.max ?? '-'}',
              maxLines: 1,
            ),
            Text(
              'Disc ${disc.last.discount.currency()}',
              maxLines: 1,
            ),
          ],
        );
      }
    }

    return Column(
      crossAxisAlignment: isFront == true
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        cart.discount(product.productId).discount == 0
            ? Text(
                price.price.currency(),
                maxLines: 1,
              )
            : Text(
                price.price.currency(),
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.black,
                  decorationThickness:
                      Theme.of(context).brightness == Brightness.dark ? 3 : 1.5,
                  fontSize: 13,
                ),
                maxLines: 1,
              ),
        const SizedBox(height: 2),
        cart.discount(product.productId).discount == 0
            ? Container()
            : isFront == true
                ? Text(
                    (price.price - cart.discount(product.productId).discount)
                        .currency(),
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                    maxLines: 1,
                  )
                : Text(
                    (price.price - cart.discount(product.productId).discount)
                        .currency(),
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                    maxLines: 1,
                  ),
        dcText(),
      ],
    );
  }
}

// class TextPrice extends ConsumerWidget {
//   final PriceList price;
//   final bool? isFront;
//   final bool isPromo;
//   const TextPrice(
//       {Key? key,
//       required this.price,
//       this.isFront = true,
//       this.isPromo = false})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final cart = ref.watch(cartStateNotifier.notifier);
//     final c =
//         ref.watch(cartStateNotifier).where((element) => element.id == price.id);
//     Widget dcText() {
//       final disc = price.discount;
//       if (price.discount.isEmpty) return Container();
//       if (disc.length == 1) {
//         if (c.length < disc.first.min || c.length > (disc.first.max ?? 0)) {
//           return Column(
//             crossAxisAlignment: isFront == true
//                 ? CrossAxisAlignment.center
//                 : CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '${c.length < (price.discount.first.min) ? 'Min Pembelian ${price.discount.first.min}' : 'Maks Pembelian ${(price.discount.first.max ?? '-')}'}  ',
//               ),
//               Text(
//                 'Disc ${price.discount.first.discount.currency()}',
//               ),
//             ],
//           );
//         } else {
//           return Column(
//             crossAxisAlignment: isFront == true
//                 ? CrossAxisAlignment.center
//                 : CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Min Pembelian ${c.isEmpty ? price.discount.first.min : cart.discount(price.id).min}',
//                 style: const TextStyle(
//                   color: Colors.red,
//                 ),
//               ),
//               Text(
//                 'Disc ${cart.discount(price.id).discount.currency()}',
//                 style: const TextStyle(
//                   color: Colors.red,
//                 ),
//               ),
//             ],
//           );
//         }
//       } else {
//         if (c.length < disc.first.min) {
//           return Column(
//             crossAxisAlignment: isFront == true
//                 ? CrossAxisAlignment.center
//                 : CrossAxisAlignment.start,
//             children: [
//               Text('Min Pembelian ${disc.first.min}'),
//               Text('Disc ${disc.first.discount.currency()}'),
//             ],
//           );
//         }
//         if (cart.discount(price.id).discount != 0) {
//           return Column(
//             crossAxisAlignment: isFront == true
//                 ? CrossAxisAlignment.center
//                 : CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '${c.length == cart.discount(price.id).min ? 'Min Pembelian ${cart.discount(price.id).min}' : 'Maks Pembelian ${cart.discount(price.id).max ?? '-'}'} ',
//                 style: const TextStyle(color: Colors.red),
//               ),
//               Text('Disc ${cart.discount(price.id).discount.currency()}',
//                   style: const TextStyle(color: Colors.red)),
//             ],
//           );
//         }
//         return Column(
//           crossAxisAlignment: isFront == true
//               ? CrossAxisAlignment.center
//               : CrossAxisAlignment.start,
//           children: [
//             Text('Maks Pembelian ${disc.last.max ?? '-'}'),
//             Text('Disc ${disc.last.discount.currency()}'),
//           ],
//         );
//       }
//     }

//     return Column(
//       crossAxisAlignment: isFront == true
//           ? CrossAxisAlignment.center
//           : CrossAxisAlignment.start,
//       children: [
//         cart.discount(price.id).discount == 0
//             ? Text(price.price.currency())
//             : Text(
//                 price.price.currency(),
//                 style: TextStyle(
//                   decoration: TextDecoration.lineThrough,
//                   decorationColor: Colors.black,
//                   decorationThickness:
//                       Theme.of(context).brightness == Brightness.dark ? 3 : 1.5,
//                   fontSize: 13,
//                 ),
//               ),
//         const SizedBox(height: 2),
//         cart.discount(price.id).discount == 0
//             ? Container()
//             : isFront == true
//                 ? Text(
//                     (price.price - cart.discount(price.id).discount).currency(),
//                     style: const TextStyle(
//                       color: Colors.red,
//                     ),
//                   )
//                 : Text(
//                     (price.price - cart.discount(price.id).discount).currency(),
//                     style: const TextStyle(
//                       color: Colors.red,
//                     ),
//                   ),
//         dcText(),
//       ],
//     );
//   }
// }
