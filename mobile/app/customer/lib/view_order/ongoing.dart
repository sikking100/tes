import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:common/widget/order.dart';
import 'package:customer/cart.dart';
import 'package:customer/main_controller.dart';
import 'package:customer/pages/home.dart';
import 'package:customer/routes.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

final ongoingStateNotifierProvider = StateNotifierProvider.autoDispose<OngoingNotifier, PagingController<int, Order>>((ref) {
  return OngoingNotifier(ref);
});

class OngoingNotifier extends StateNotifier<PagingController<int, Order>> {
  OngoingNotifier(this.ref) : super(PagingController(firstPageKey: 1)) {
    user = ref.watch(customerStateProvider);
    error = '';
    state.addPageRequestListener((pageKey) => request(pageKey));
  }

  final AutoDisposeRef ref;
  late final Customer user;
  late String error;

  void request(int pageKey) async {
    try {
      final result = await ref.read(apiProvider).order.find(query: '${user.id},1', num: pageKey);
      if (result.next == null) {
        state.appendLastPage(result.items);
      } else {
        state.appendPage(result.items, result.next);
      }
      return;
    } catch (e) {
      state.error = '$e';
      return;
    }
  }
}

class ViewOrderOngoing extends ConsumerWidget {
  const ViewOrderOngoing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ongoingStateNotifierProvider);
    final loading = ref.watch(manyLodingProvider);

    Future<void> orderAgain(int index, List<OrderProduct> product, String branchId) async {
      ref.read(manyLodingProvider.notifier).update((state) => {...state, index: true});

      for (var p in product) {
        if (!ref.read(cartStateNotifier).map((e) => e.productId).contains(p.id)) {
          final product = await ref.read(apiProvider).product.byId('$branchId-${p.id}');
          for (var i = 0; i < p.qty; i++) {
            ref.read(cartStateNotifier.notifier).add(product);
          }
        }
      }
      ref.read(manyLodingProvider.notifier).update((state) => {...state, index: false});

      return;
    }

    return RefreshIndicator.adaptive(
      child: PagedListView<int, Order>.separated(
        padding: const EdgeInsets.all(Dimens.px16),
        pagingController: state,
        builderDelegate: PagedChildBuilderDelegate<Order>(
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Tidak ada data')),
          itemBuilder: (context, item, index) => WidgetOrder(
            totalPesanan: item.totalPrice.toInt(),
            deliveryTime: item.createdAt!,
            totalProduk: item.product.map((element) => element.id).toSet().length,
            cancelNote: item.cancel?.note ?? '',
            orderAgainLoad: loading[index],
            onOrderAgain: () => orderAgain(index, item.product, item.branchId).whenComplete(() => Navigator.popAndPushNamed(context, Routes.cart)),
            id: item.id,
            customerName: '',
            orderStatus: item.status,
            productPrice: item.productPrice.toInt(),
            deliveryFee: (item.deliveryPrice).floor(),
            routeOrderDetail: Routes.orderDetail,
          ),
        ),
        separatorBuilder: (context, index) => const Divider(height: 30, color: Colors.grey),
      ),
      onRefresh: () => Future.sync(() => state.refresh()),
    );
  }
}
