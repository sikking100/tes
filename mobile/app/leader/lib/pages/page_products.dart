import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:leader/argument.dart';
import 'package:leader/cart_provider.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/routes.dart';
import 'package:leader/widget.dart';

final productListNotifierProvider =
    StateNotifierProvider.autoDispose.family<ProductListNotifier, PagingController<int, Product>, ArgProductList>((ref, arg) {
  return ProductListNotifier(ref, arg);
});

class ProductListNotifier extends StateNotifier<PagingController<int, Product>> {
  ProductListNotifier(this.ref, this.arg) : super(PagingController(firstPageKey: 1)) {
    b = ref.watch(customerStateProvider).business;
    api = ref.read(apiProvider);
    state.addPageRequestListener((pageKey) => fetch(pageKey));
  }
  final ArgProductList arg;
  final AutoDisposeRef ref;
  late Business? b;
  late final Api api;

  void fetch(int pageKey) async {
    try {
      Paging<Product> result;
      final business = b;
      if (business == null) throw 'Tidak ada bisnis yang terpilih';
      if (arg.title == 'Terbaru') {
        result = await api.product.find(query: business.location.branchId);
      } else if (arg.title == 'Terlaris') {
        result = await api.product.find(query: business.location.branchId, sort: 1);
      } else if (arg.title == 'Promo') {
        result = await api.product.find(query: business.location.branchId, sort: 2);
      } else {
        result = await api.product.find(query: '${business.location.branchId},${arg.idBrand}');
      }

      if (result.next == null) {
        state.appendLastPage(result.items);
      } else {
        state.appendPage(result.items, pageKey + 1);
      }
      return;
    } catch (e) {
      state.error = e.toString();
      return;
    }
  }
}

class PageProducts extends ConsumerWidget {
  final ArgProductList arg;
  const PageProducts({super.key, required this.arg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(productListNotifierProvider(arg));
    final cart = ref.watch(cartStateNotifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(arg.title),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => Future.sync(data.refresh),
        child: PagedGridView(
          padding: const EdgeInsets.all(Dimens.px12),
          pagingController: data,
          builderDelegate: PagedChildBuilderDelegate<Product>(
            noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
            itemBuilder: (context, price, index) {
              return WidgetProduct(
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
                  removeProduct: () => ref.read(cartStateNotifier.notifier).remove(price.productId),
                  qty: TextCount(product: price),
                ),
                padding10: 10,
                padding6: 6,
                padding16: 16,
              );
            },
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: (MediaQuery.of(context).size.width / 2) / ((MediaQuery.of(context).size.height + 70) / 2),
            crossAxisSpacing: Dimens.px12,
            mainAxisSpacing: Dimens.px12,
          ),
        ),
      ),
    );
  }
}
