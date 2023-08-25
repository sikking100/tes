import 'dart:developer';

import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:common/widget/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/presentation/pages/cart/provider/cart_provider.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/widgets/app_empty_widget.dart';
import 'package:sales/presentation/widgets/app_scaffold_messenger.dart';
import 'package:sales/presentation/widgets/shimmer/app_shimmer_customer.dart';

final loadingOrderAgainProvider = StateProvider.autoDispose<bool>((_) {
  return false;
});

class OrderHistoryView extends ConsumerStatefulWidget {
  const OrderHistoryView({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends ConsumerState<OrderHistoryView> {
  final PagingController<int, Order> _pagingController =
      PagingController(firstPageKey: 1);
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchOrder(pageKey);
    });
  }

  Future<void> orderAgain(List<OrderProduct> index, String priceId) async {
    try {
      ref.read(loadingOrderAgainProvider.notifier).update((state) => true);
      for (var p in index) {
        if (!ref.read(cartStateNotifier).map((e) => e.id).contains(p.id)) {
          await ref.read(apiProvider).product.byId('$priceId.${p.id}').then(
            (value) {
              for (var i = 0; i < p.qty; i++) {
                ref.watch(cartStateNotifier.notifier).add(value);
              }
            },
          );
        }
      }
      ref.read(loadingOrderAgainProvider.notifier).update((state) => false);
    } catch (e) {
      ref.read(loadingOrderAgainProvider.notifier).update((state) => false);
      rethrow;
    }
  }

  Future<void> _fetchOrder(int pageKey) async {
    try {
      final api = ref.read(apiProvider);
      final mEmployee = ref.read(employee.notifier).state;
      final res = await api.order.find(
        query: mEmployee.id,
      );
      if (res.items.isNotEmpty) {
        _pagingController.appendLastPage(
            res.items.where((element) => element.status == 2).toList());
      } else {
        _pagingController.appendPage(
            res.items.where((element) => element.status == 2).toList(),
            pageKey + 1);
      }
    } catch (error) {
      log(error.toString());
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: theme.primaryColor,
      onRefresh: () async {
        _pagingController.refresh();
      },
      child: PagedListView.separated(
          padding: const EdgeInsets.all(Dimens.px16),
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Order>(
            itemBuilder: (_, order, index) {
              return WidgetOrder(
                totalProduk: order.product.length,
                totalPesanan: order.totalPrice.toInt(),
                deliveryTime: order.createdAt!,
                cancelNote: "",
                id: order.id,
                customerName: order.customer.name,
                orderStatus: order.status,
                productPrice: 1,
                deliveryFee: order.deliveryPrice.toInt(),
                onOrderAgain: () async {
                  try {
                    await ref
                        .read(apiProvider)
                        .customer
                        .byId(order.customer.id)
                        .then(
                      (value) {
                        return ref
                            .read(customerStateProvider.notifier)
                            .update((state) => value);
                      },
                    ).then(
                      (value) => orderAgain(order.product, order.priceId).then(
                        (value) =>
                            Navigator.pushNamed(context, AppRoutes.cartPage),
                      ),
                    );
                  } catch (e) {
                    AppScaffoldMessanger.showSnackBar(
                        context: context, message: e.toString());
                  }
                },
                routeOrderDetail: AppRoutes.orderDetail,
              );
            },
            newPageProgressIndicatorBuilder: (context) =>
                const AppShimmerCustomer(),
            firstPageProgressIndicatorBuilder: (_) =>
                const AppShimmerCustomer(),
            noItemsFoundIndicatorBuilder: (_) => const AppEmptyWidget(
              title: "Belum ada order",
            ),
          ),
          separatorBuilder: (_, index) => const SizedBox()),
    );
  }
}
