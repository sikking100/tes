import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:common/widget/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/presentation/widgets/app_empty_widget.dart';
import 'package:sales/presentation/widgets/shimmer/app_shimmer_customer.dart';

class OrderPendingView extends ConsumerStatefulWidget {
  const OrderPendingView({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderPendingView> createState() => _OrderPendingViewState();
}

class _OrderPendingViewState extends ConsumerState<OrderPendingView> {
  final PagingController<int, Order> _pagingController =
      PagingController(firstPageKey: 1);
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchOrder(pageKey);
    });
  }

  Future<void> _fetchOrder(int pageKey) async {
    try {
      final api = ref.read(apiProvider);
      final mEmployee = ref.watch(employee);
      if (mEmployee.id.isEmpty) throw 'Employee id is empty';
      final res = await api.order.find(
        query: mEmployee.id,
      );
      if (res.items.isNotEmpty) {
        _pagingController.appendLastPage(
            res.items.where((element) => element.status != 2).toList());
      } else {
        _pagingController.appendPage(
            res.items.where((element) => element.status != 2).toList(),
            pageKey + 1);
      }
    } catch (error) {
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
              productPrice: order.totalPrice.toInt(),
              deliveryFee: order.deliveryPrice.toInt(),
              routeOrderDetail: AppRoutes.orderDetail,
            );
          },
          newPageProgressIndicatorBuilder: (context) =>
              const AppShimmerCustomer(),
          firstPageProgressIndicatorBuilder: (_) => const AppShimmerCustomer(),
          noItemsFoundIndicatorBuilder: (_) => const AppEmptyWidget(
            title: "Belum ada order",
          ),
        ),
        separatorBuilder: (_, index) => const SizedBox(
          height: Dimens.px16,
        ),
      ),
    );
  }
}
