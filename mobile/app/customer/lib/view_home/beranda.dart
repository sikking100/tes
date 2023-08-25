import 'package:api/api.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:common/constant/constant.dart';
import 'package:customer/argument.dart';
import 'package:customer/cart.dart';
import 'package:customer/main_controller.dart';
import 'package:customer/routes.dart';
import 'package:customer/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:api/banner/new_model.dart' as b;
import 'package:common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final branchProvider = StateProvider<Branch>((_) {
  return const Branch();
});

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

final bannerProvider = FutureProvider<List<b.Banner>>((ref) async {
  return ref.read(apiProvider).banner.findExternal();
});

final bannerStateProvider = StateProvider<int>((ref) {
  return 0;
});

final brandFutureProvider = FutureProvider.autoDispose<List<Brand>>((ref) async {
  return ref.read(apiProvider).brand.all();
});

final newProductProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final branch = ref.read(branchProvider);
  logger.info(branch.id);
  final result = await ref.read(apiProvider).product.find(query: branch.id);
  (result);

  return result.items;
});

final productDiskonProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final branch = ref.read(branchProvider);
  final result = await ref.read(apiProvider).product.find(query: branch.id, sort: 2);
  return result.items;
});

// final productLarisProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
//   final branch = ref.read(branchProvider);
//   final result = await ref.read(apiProvider).product.find(query: branch.id, sort: 1);
//   return result.items;
// });

class ViewHomeBeranda extends ConsumerWidget {
  const ViewHomeBeranda({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btnSearch = ref.watch(buttonSearchProvider);
    final banners = ref.watch(bannerProvider);
    final bannerIndicator = ref.watch(bannerStateProvider);
    final brand = ref.watch(brandFutureProvider);
    final newProduct = ref.watch(newProductProvider);
    // final larisProduct = ref.watch(productLarisProvider);
    final diskonProduct = ref.watch(productDiskonProvider);
    final cart = ref.watch(cartStateNotifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Image.asset('assets/icon.png', height: 24),
        ),
        actions: const [CartWidget()],
      ),
      body: Stack(
        children: [
          RefreshIndicator.adaptive(
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () async {
              ref.invalidate(productDiskonProvider);
              // ref.invalidate(productLarisProvider);
              ref.invalidate(newProductProvider);
              return;
            },
            child: CustomScrollView(
              controller: ref.read(buttonSearchProvider.notifier).controller,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 30 / 100,
                    child: banners.when(
                      data: (data) {
                        if (data.isEmpty) return const Center(child: Text('Banner Kosong'));
                        return Stack(
                          children: [
                            CarouselSlider.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index, realIndex) => Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(data[index].imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              options: CarouselOptions(
                                viewportFraction: 1.0,
                                aspectRatio: 16 / 9,
                                height: MediaQuery.of(context).size.height,
                                autoPlay: true,
                                onPageChanged: (index, reason) => ref.read(bannerStateProvider.notifier).update((state) => index),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              bottom: 10,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    data.length,
                                    (index) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        // border: Border.all(),
                                        color: bannerIndicator == index ? Colors.red : Colors.white,
                                      ),
                                      height: 8,
                                      width: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      error: (error, stackTrace) => Center(
                        child: Text(error.toString()),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  ),
                ),
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
                              Navigator.pushNamed(context, Routes.listProduct, arguments: ArgProductList(idBrand: data.id, title: data.name));
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
                                onTap: () => Navigator.pushNamed(context, Routes.listProduct, arguments: ArgProductList(title: 'Terbaru')),
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
                                            productDetail: () =>
                                                Navigator.pushNamed(context, Routes.productDetail, arguments: ArgProductDetail(price.id)),
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
                                              removeProduct: () => ref.read(cartStateNotifier.notifier).remove(price.productId),
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
                // terlaris di hide dulu
                // SliverToBoxAdapter(
                //   child: SizedBox(
                //     height: 400,
                //     child: larisProduct.when(
                //       data: (data) {
                //         return Column(
                //           children: [
                //             Padding(
                //               padding: const EdgeInsets.only(left: Dimens.px10, right: Dimens.px10, top: Dimens.px20),
                //               child: InkWell(
                //                 onTap: () => Navigator.pushNamed(context, Routes.listProduct, arguments: ArgProductList(title: 'Terlaris')),
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
                //                             productDetail: () =>
                //                                 Navigator.pushNamed(context, Routes.productDetail, arguments: ArgProductDetail(price.id)),
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
                //                               removeProduct: () => ref.read(cartStateNotifier.notifier).remove(price.productId),
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
                      onTap: () => Navigator.pushNamed(context, Routes.listProduct, arguments: ArgProductList(title: 'Promo')),
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
                            final cart = ref.watch(cartStateNotifier);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: WidgetProduct(
                                isFront: true,
                                isFrontImageHeight: 120,
                                radius: 10,
                                productDetail: () => Navigator.pushNamed(context, Routes.productDetail, arguments: ArgProductDetail(price.id)),
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
                                  removeProduct: () => ref.read(cartStateNotifier.notifier).remove(price.productId),
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
                    //           productDetail: () => Navigator.pushNamed(context, Routes.productDetail, arguments: ArgProductDetail(price.id)),
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
                    //             removeProduct: () => ref.read(cartStateNotifier.notifier).remove(price.productId),
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
