import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/argument.dart';
import 'package:leader/cart_provider.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/routes.dart';
import 'package:leader/widget.dart';

final buttonSearchProvider = StateNotifierProvider.autoDispose<ButtonSearch, double>((_) => ButtonSearch());

class ButtonSearch extends StateNotifier<double> {
  ButtonSearch() : super(10) {
    controller = ScrollController();
    controller.addListener(() {
      if (controller.position.userScrollDirection == ScrollDirection.forward) {
        state = 10;
      } else {
        state = -100;
      }
    });
  }
  late final ScrollController controller;
}

final brandFutureProvider = FutureProvider.autoDispose<List<Brand>>((ref) async {
  return ref.read(apiProvider).brand.all();
});

final newProductProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final branch = ref.watch(customerStateProvider);
  final result = await ref.watch(apiProvider).product.find(query: branch.business?.location.branchId ?? '');
  return result.items;
});

final productDiskonProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final branch = ref.watch(customerStateProvider);
  final result = await ref.watch(apiProvider).product.find(query: branch.business?.location.branchId ?? '', sort: 2);
  return result.items;
});

// final productLarisProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
//   final branch = ref.watch(customerStateProvider);
//   final result = await ref.watch(apiProvider).product.find(query: branch.business?.location.branchId ?? '', sort: 1);
//   return result.items;
// });

class PageShopping extends ConsumerWidget {
  const PageShopping({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btnSearch = ref.watch(buttonSearchProvider);
    final brand = ref.watch(brandFutureProvider);

    final newProduct = ref.watch(newProductProvider);
    // final larisProduct = ref.watch(productLarisProvider);
    final diskonProduct = ref.watch(productDiskonProvider);
    final cart = ref.watch(cartStateNotifier);
    final customer = ref.watch(customerStateProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Belanja untuk ${customer.name}'),
        leading: BackButton(
          onPressed: () {
            ref.invalidate(cartStateNotifier);
            Navigator.pop(context);
          },
        ),
        actions: const [
          CartWidget(),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator.adaptive(
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () async {
              ref.invalidate(newProductProvider);
              ref.invalidate(productDiskonProvider);
              return;
            },
            child: CustomScrollView(
              controller: ref.read(buttonSearchProvider.notifier).controller,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 12 / 100,
                    child: brand.when(
                      data: (d) => ListView.separated(
                        padding: const EdgeInsets.fromLTRB(13, 20, 13, 0),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final data = d[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, Routes.products, arguments: ArgProductList(idBrand: data.id, title: data.name));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width * 20 / 100,
                              height: MediaQuery.of(context).size.height,
                              decoration: BoxDecoration(
                                color: Theme.of(context).highlightColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black12,
                                ),
                              ),
                              child: data.imageUrl.isNotEmpty ? Image.network(data.imageUrl) : const Center(child: Icon(Icons.inventory)),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(width: 20),
                        itemCount: d.length,
                      ),
                      error: (error, stackTrace) => WidgetError(
                        error: error.toString(),
                        onPressed: () => ref.invalidate(brandFutureProvider),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 400,
                    child: newProduct.when(
                      data: (data) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: Dimens.px10, right: Dimens.px10, top: Dimens.px20),
                              child: InkWell(
                                onTap: () => Navigator.pushNamed(context, Routes.products, arguments: ArgProductList(title: 'Terbaru')),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Terbaru',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const Text('Lihat Semua'),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: data.isEmpty
                                  ? const Center(child: Text('Produk kosong'))
                                  : ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.only(top: 10, left: Dimens.px10, right: Dimens.px10, bottom: 0),
                                      itemBuilder: (context, index) {
                                        final price = data[index];
                                        return SizedBox(
                                          height: 350,
                                          width: MediaQuery.of(context).size.width * 45 / 100,
                                          child: WidgetProduct(
                                            isFront: true,
                                            radius: 15,
                                            productDetail: () => Navigator.pushNamed(context, Routes.product, arguments: ArgProductDetail(price.id)),
                                            name: price.name,
                                            padding: const EdgeInsets.all(Dimens.px16).top,
                                            price: TextPrice(product: price),
                                            sizeProduct: price.size,
                                            image: Image.network(price.imageUrl),
                                            buttonCart: ButtonCart(
                                              isEmpty: cart.where((element) => element.productId == price.productId).isEmpty,
                                              addProduct: () => ref.read(cartStateNotifier.notifier).add(price),
                                              px10: 10,
                                              px4: 4,
                                              buttonColor: mPrimaryColor,
                                              removeProduct: () {
                                                ref.read(doubleProvider.notifier).update((state) {
                                                  state.remove(price.productId);
                                                  return state;
                                                });
                                                ref.read(cartStateNotifier.notifier).remove(price.productId);
                                              },
                                              qty: TextCount(product: price),
                                            ),
                                            padding10: 10,
                                            padding6: 6,
                                            padding16: 16,
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) => const SizedBox(width: 15),
                                      itemCount: data.length,
                                    ),
                            ),
                          ],
                        );
                      },
                      error: (error, stackTrace) => Center(child: Text(error.toString())),
                      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                    ),
                  ),
                ),
                // terlaris di hide untuk sementara
                // SliverToBoxAdapter(
                //   child: SizedBox(
                //     height: 380,
                //     child: larisProduct.when(
                //       data: (data) {
                //         return Column(
                //           children: [
                //             Padding(
                //               padding: const EdgeInsets.only(left: Dimens.px10, right: Dimens.px10, top: Dimens.px20),
                //               child: InkWell(
                //                 onTap: () => Navigator.pushNamed(context, Routes.products, arguments: ArgProductList(title: 'Terlaris')),
                //                 child: Row(
                //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                   children: [
                //                     Text(
                //                       'Terlaris',
                //                       style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                //                     ),
                //                     const Text('Lihat Semua'),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             Expanded(
                //               child: data.isEmpty
                //                   ? const Center(child: Text('Produk kosong'))
                //                   : ListView.separated(
                //                       scrollDirection: Axis.horizontal,
                //                       padding: const EdgeInsets.only(top: 10, left: Dimens.px10, right: Dimens.px10, bottom: 0),
                //                       itemBuilder: (context, index) {
                //                         final price = data[index];

                //                         return SizedBox(
                //                           height: 350,
                //                           width: MediaQuery.of(context).size.width * 45 / 100,
                //                           child: WidgetProduct(
                //                             isFront: true,
                //                             radius: 15,
                //                             productDetail: () => Navigator.pushNamed(context, Routes.product, arguments: ArgProductDetail(price.id)),
                //                             name: price.name,
                //                             padding: const EdgeInsets.all(Dimens.px16).top,
                //                             price: TextPrice(product: price),
                //                             sizeProduct: price.size,
                //                             image: Image.network(price.imageUrl),
                //                             buttonCart: ButtonCart(
                //                               isEmpty: cart.where((element) => element.productId == price.productId).isEmpty,
                //                               addProduct: () => ref.read(cartStateNotifier.notifier).add(price),
                //                               px10: 10,
                //                               px4: 4,
                //                               buttonColor: mPrimaryColor,
                //                               removeProduct: () {
                //                                 ref.read(doubleProvider.notifier).update((state) {
                //                                   state.remove(price.productId);
                //                                   return state;
                //                                 });
                //                                 ref.read(cartStateNotifier.notifier).remove(price.productId);
                //                               },
                //                               qty: TextCount(product: price),
                //                             ),
                //                             padding10: 10,
                //                             padding6: 6,
                //                             padding16: 16,
                //                           ),
                //                         );
                //                       },
                //                       separatorBuilder: (context, index) => const SizedBox(width: 15),
                //                       itemCount: data.length,
                //                     ),
                //             ),
                //           ],
                //         );
                //       },
                //       error: (error, stackTrace) => Center(child: Text(error.toString())),
                //       loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                //     ),
                //   ),
                // ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: Dimens.px10, right: Dimens.px10, bottom: Dimens.px10, top: 20),
                  sliver: SliverToBoxAdapter(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, Routes.products, arguments: ArgProductList(title: 'Promo')),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Promo',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Text('Lihat Semua')
                        ],
                      ),
                    ),
                  ),
                ),
                diskonProduct.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200,
                          child: Center(
                            child: Text('Produk kosong'),
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimens.px12).copyWith(bottom: Dimens.px12),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final price = data[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: WidgetProduct(
                                isFront: true,
                                isFrontImageHeight: 120,
                                radius: 10,
                                productDetail: () => Navigator.pushNamed(context, Routes.product, arguments: ArgProductDetail(price.id)),
                                name: price.name,
                                padding: 10,
                                price: TextPrice(product: price),
                                sizeProduct: price.size,
                                image: Image.network(price.imageUrl),
                                buttonCart: ButtonCart(
                                  isEmpty: cart.where((element) => element.productId == price.productId).isEmpty,
                                  addProduct: () => ref.read(cartStateNotifier.notifier).add(price),
                                  px10: 10,
                                  px4: 4,
                                  buttonColor: mPrimaryColor,
                                  removeProduct: () {
                                    ref.read(doubleProvider.notifier).update((state) {
                                      state.remove(price.productId);
                                      return state;
                                    });
                                    ref.read(cartStateNotifier.notifier).remove(price.productId);
                                  },
                                  qty: TextCount(product: price),
                                ),
                                padding10: 10,
                                padding6: 6,
                                padding16: 16,
                              ),
                            );
                          },
                          childCount: data.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: Dimens.px12,
                          mainAxisSpacing: Dimens.px12,
                          childAspectRatio: (MediaQuery.of(context).size.width / 2) / ((MediaQuery.of(context).size.height + 100) / 2),
                        ),
                      ),
                    );
                    // return SliverList(
                    //   delegate: SliverChildBuilderDelegate(
                    //     (context, index) {
                    //       final price = data[index];
                    //       return Padding(
                    //         padding: const EdgeInsets.only(bottom: 15),
                    //         child: WidgetProduct(
                    //           discount: price.discount != null
                    //               ? price.discount!.items.isEmpty
                    //                   ? 0
                    //                   : price.discount!.items.first.discount
                    //               : 0,
                    //           isFrontImageHeight: 200,
                    //           radius: 10,
                    //           productDetail: () => Navigator.pushNamed(context, Routes.Routes.product, arguments: ArgProductDetail(price.id)),
                    //           name: price.product.name,
                    //           padding: 10,
                    //           price: TextPrice(price: price),
                    //           sizeProduct: price.product.size,
                    //           image: Image.network(price.product.imageUrl),
                    //           buttonCart: ButtonCart(
                    //             isEmpty: cart.where((element) => element.id == price.id).isEmpty,
                    //             addProduct: () => ref.read(cartStateNotifier.notifier).add(price),
                    //             px10: 10,
                    //             px4: 4,
                    //             buttonColor: mPrimaryColor,
                    //             removeProduct: () => ref.read(cartStateNotifier.notifier).remove(price.id),
                    //             qty: TextCount(product: price),
                    //           ),
                    //           padding10: 10,
                    //           padding6: 6,
                    //           padding16: 16,
                    //         ),
                    //       );
                    //     },
                    //     childCount: data.length,
                    //   ),
                    // );
                  },
                  error: (error, stackTrace) => SliverToBoxAdapter(child: Text(error.toString())),
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedPositioned(
            right: btnSearch,
            bottom: 10,
            duration: const Duration(milliseconds: 400),
            child: FloatingActionButton(
              backgroundColor: Colors.red.shade900,
              onPressed: () {
                Navigator.pushNamed(context, Routes.search);
                return;
              },
              child: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
