import 'package:api/common.dart';
import 'package:api/customer/model.dart';

import 'package:api/product/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sales/main_controller.dart';

final customerStateProvider = StateProvider<Customer>((_) {
  return const Customer();
});

class ArgProductList {
  final String title;
  final String? idBrand;

  ArgProductList({required this.title, this.idBrand});
}

final productListNotifierProvider = StateNotifierProvider.autoDispose
    .family<ProductListNotifier, Paging<Product>, ArgProductList>((ref, arg) {
  return ProductListNotifier(ref, arg);
});

final newProductProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final cus = ref.watch(customerStateProvider);
  final result = await ref
      .read(apiProvider)
      .product
      .find(query: cus.business?.location.branchId ?? "");
  return result.items;
});

final productDiskonProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final cus = ref.watch(customerStateProvider);
  final result = await ref
      .read(apiProvider)
      .product
      .find(query: cus.business?.location.branchId ?? "", sort: 2);
  return result.items;
});

final productLarisProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final cus = ref.watch(customerStateProvider);
  final result = await ref
      .read(apiProvider)
      .product
      .find(query: cus.business?.location.branchId ?? "", sort: 1);
  return result.items;
});

class ProductListNotifier extends StateNotifier<Paging<Product>> {
  ProductListNotifier(this.ref, this.arg)
      : super(const Paging<Product>(null, [])) {
    controller = RefreshController(initialRefresh: true);
    business = ref.watch(customerStateProvider).business;
  }
  final ArgProductList arg;
  final AutoDisposeRef ref;
  late final RefreshController controller;
  String error = '';
  bool isLoading = false;

  late Business? business;

  void onRefresh() async {
    try {
      isLoading = true;
      controller.resetNoData();
      Paging<Product> result;
      if (arg.title == 'Terbaru') {
        result = await ref
            .read(apiProvider)
            .product
            .find(query: business!.location.branchId);
      } else if (arg.title == 'Terlaris') {
        result = await ref
            .read(apiProvider)
            .product
            .find(query: business!.location.branchId, sort: 1);
      } else if (arg.title == 'Promo') {
        result = await ref
            .read(apiProvider)
            .product
            .find(query: business!.location.branchId, sort: 2);
      } else {
        result = await ref
            .read(apiProvider)
            .product
            .find(query: "${business!.location.branchId},${arg.idBrand}");
      }

      state = result;
      controller.refreshCompleted();
      isLoading = false;
      return;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      controller.refreshFailed();
      state = state.copyWith();
      return;
    }
  }

  void onLoading() async {
    try {
      isLoading = true;
      if (state.next == null) {
        controller.loadNoData();
        state = state.copyWith();
        return;
      }
      Paging<Product> result;
      if (arg.title == 'Terbaru') {
        result = await ref
            .read(apiProvider)
            .product
            .find(query: business!.location.branchId, num: state.next);
      } else if (arg.title == 'Terlaris') {
        result = await ref
            .read(apiProvider)
            .product
            .find(query: business!.location.branchId, num: state.next, sort: 1);
      } else if (arg.title == 'Promo') {
        result = await ref
            .read(apiProvider)
            .product
            .find(query: business!.location.branchId, num: state.next, sort: 2);
      } else {
        result = await ref.read(apiProvider).product.find(
            query: business!.location.branchId,
            num: state.next,
            sort: 2,
            search: arg.idBrand);
      }
      if (result.items.isEmpty) {
        controller.loadNoData();
        return;
      }
      controller.loadComplete();
      state.items.addAll(result.items);
      state = state.copyWith(next: result.next);
      isLoading = false;
      return;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      controller.loadFailed();
      state = state.copyWith();
      return;
    }
  }
}
