import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:customer/argument.dart';
import 'package:customer/cart.dart';
import 'package:customer/main_controller.dart';
import 'package:customer/pages/home.dart';
import 'package:customer/routes.dart';
import 'package:customer/view_home/beranda.dart';
import 'package:customer/widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

final productListNotifierProvider =
    StateNotifierProvider.autoDispose.family<ProductListNotifier, PagingController<int, Product>, ArgProductList>((ref, arg) {
  return ProductListNotifier(ref, arg);
});

class ProductListNotifier extends StateNotifier<PagingController<int, Product>> {
  ProductListNotifier(this.ref, this.arg) : super(PagingController(firstPageKey: 1)) {
    branch = ref.watch(branchProvider);
    business = ref.watch(customerStateProvider).business;
    state.addPageRequestListener((pageKey) {
      request(pageKey);
    });
  }
  final ArgProductList arg;
  final AutoDisposeRef ref;
  String error = '';
  late Branch branch;
  late Business? business;

  void request(int pageKey) async {
    Paging<Product> result;
    if (arg.title == 'Terbaru') {
      result = await ref.read(apiProvider).product.find(query: branch.id, num: pageKey);
    } else if (arg.title == 'Terlaris') {
      result = await ref.read(apiProvider).product.find(query: branch.id, sort: 1, num: pageKey);
    } else if (arg.title == 'Promo') {
      result = await ref.read(apiProvider).product.find(query: branch.id, sort: 2, num: pageKey);
    } else {
      result = await ref.read(apiProvider).product.find(query: '${branch.id},${arg.idBrand}', num: pageKey);
    }

    if (result.next == null) {
      state.appendLastPage(result.items);
    } else {
      state.appendPage(result.items, result.next);
    }
  }
}

class PageProductList extends ConsumerWidget {
  final ArgProductList arg;
  const PageProductList({super.key, required this.arg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(productListNotifierProvider(arg));
    final cart = ref.watch(cartStateNotifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(arg.title),
      ),
      body: RefreshIndicator.adaptive(
        child: PagedGridView<int, Product>(
          padding: const EdgeInsets.all(Dimens.px16),
          pagingController: data,
          builderDelegate: PagedChildBuilderDelegate<Product>(
            noItemsFoundIndicatorBuilder: (context) => const Center(
              child: Text('Belum ada data'),
            ),
            itemBuilder: (context, item, index) {
              final price = item;
              return WidgetProduct(
                isFront: true,
                isFrontImageHeight: MediaQuery.of(context).size.aspectRatio < 0.5 ? 357 : 120,
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
                padding16: 10,
              );
            },
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            // childAspectRatio: (MediaQuery.of(context).size.width / 2) / ((MediaQuery.of(context).size.height + 120) / 2),
            childAspectRatio: (MediaQuery.of(context).size.width / 2) / ((MediaQuery.of(context).size.height) / 1.6),

            // childAspectRatio: MediaQuery.of(context).size.aspectRatio,
            crossAxisSpacing: Dimens.px12,
            mainAxisSpacing: Dimens.px12,
          ),
        ),
        onRefresh: () => Future.sync(() => data.refresh()),
      ),
    );
  }
}
