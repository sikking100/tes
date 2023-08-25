import 'package:api/api.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:leader/cart_provider.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/routes.dart';

final manyLodingProvider = StateProvider.autoDispose<Map<int, bool>>((ref) {
  return {};
});

final orderPendingProvider = StateNotifierProvider.autoDispose.family<OrderPendingNotifier, PagingController<int, Order>, int>((ref, args) {
  return OrderPendingNotifier(ref, args);
});

Future<void> orderAgain(int index, Order order, WidgetRef ref) async {
  try {
    ref.read(manyLodingProvider.notifier).update((state) => {...state, index: true});
    final result = await ref.read(apiProvider).customer.byId(order.customer.id);
    ref.read(customerStateProvider.notifier).update((state) => result);
    await Future.delayed(const Duration(seconds: 1));
    for (var p in order.product) {
      if (!ref.read(cartStateNotifier).map((e) => e.productId).contains(p.id)) {
        final product = await ref.read(apiProvider).product.byId('${order.branchId}-${p.id}');
        for (var i = 0; i < p.qty; i++) {
          ref.read(cartStateNotifier.notifier).add(product);
        }
      }
    }
    return;
  } catch (e) {
    rethrow;
  } finally {
    ref.read(manyLodingProvider.notifier).update((state) => {...state, index: false});
  }
}

class OrderPendingNotifier extends StateNotifier<PagingController<int, Order>> {
  OrderPendingNotifier(this.ref, this.status) : super(PagingController(firstPageKey: 1)) {
    state.addPageRequestListener(fetch);
  }

  final Ref ref;
  final int status;

  void fetch(int pageKey) async {
    try {
      final emp = ref.read(employeeStateProvider);
      final res = await ref.read(apiProvider).order.find(query: '${emp.id},$status', num: pageKey);

      if (res.next == null) {
        state.appendLastPage(res.items);
      } else {
        state.appendPage(res.items, pageKey + 1);
      }
      return;
    } catch (e) {
      state.error = e;
      return;
    }
  }
}

class PageOrders extends StatelessWidget {
  const PageOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Menunggu'),
              Tab(text: 'Berjalan'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: const TabBarView(children: [
          ViewWaitPay(),
          ViewPending(),
          ViewComplete(),
        ]),
      ),
    );
  }
}

class ViewWaitPay extends ConsumerWidget {
  const ViewWaitPay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gets = ref.watch(orderPendingProvider(0));
    return RefreshIndicator.adaptive(
      onRefresh: () => Future.sync(gets.refresh),
      child: PagedListView<int, Order>.separated(
        pagingController: gets,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<Order>(
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
          itemBuilder: (context, item, index) => WidgetOrder(
            deliveryTime: item.createdAt!,
            totalPesanan: item.totalPrice.toInt(),
            totalProduk: item.product.length,
            cancelNote: item.cancel?.note ?? '',
            orderAgainLoad: ref.watch(manyLodingProvider)[index],
            onOrderAgain: () => orderAgain(index, item, ref).then((value) => Navigator.pushNamed(context, Routes.cart)),
            id: item.id,
            customerName: item.customer.name,
            orderStatus: item.status,
            productPrice: item.totalPrice.toInt(),
            deliveryFee: item.deliveryPrice.toInt(),
            routeOrderDetail: Routes.order,
          ),
        ),
        separatorBuilder: (context, index) => const Divider(height: 0),
      ),
    );
  }
}

class ViewPending extends ConsumerWidget {
  const ViewPending({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gets = ref.watch(orderPendingProvider(1));

    return RefreshIndicator.adaptive(
      onRefresh: () => Future.sync(gets.refresh),
      child: PagedListView<int, Order>.separated(
        pagingController: gets,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<Order>(
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
          itemBuilder: (context, item, index) => WidgetOrder(
            deliveryTime: item.createdAt!,
            totalPesanan: item.totalPrice.toInt(),
            totalProduk: item.product.length,
            cancelNote: item.cancel?.note ?? '',
            orderAgainLoad: ref.watch(manyLodingProvider)[index],
            onOrderAgain: () => orderAgain(index, item, ref).then((value) => Navigator.pushNamed(context, Routes.cart)),
            id: item.id,
            customerName: item.customer.name,
            orderStatus: item.status,
            productPrice: item.totalPrice.toInt(),
            deliveryFee: item.deliveryPrice.toInt(),
            routeOrderDetail: Routes.order,
          ),
        ),
        separatorBuilder: (context, index) => const Divider(height: 0),
      ),
    );
  }
}

class ViewComplete extends ConsumerWidget {
  const ViewComplete({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gets = ref.watch(orderPendingProvider(2));

    return RefreshIndicator.adaptive(
      onRefresh: () => Future.sync(gets.refresh),
      child: PagedListView<int, Order>.separated(
        pagingController: gets,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<Order>(
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
          itemBuilder: (context, item, index) => WidgetOrder(
            deliveryTime: item.createdAt!,
            totalPesanan: item.totalPrice.toInt(),
            totalProduk: item.product.length,
            cancelNote: item.cancel?.note ?? '',
            orderAgainLoad: ref.watch(manyLodingProvider)[index],
            onOrderAgain: () => orderAgain(index, item, ref).then((value) => Navigator.pushNamed(context, Routes.cart)),
            id: item.id,
            customerName: item.customer.name,
            orderStatus: item.status,
            productPrice: item.totalPrice.toInt(),
            deliveryFee: item.deliveryPrice.toInt(),
            routeOrderDetail: Routes.order,
          ),
        ),
        separatorBuilder: (context, index) => const Divider(height: 0),
      ),
    );
  }
}
