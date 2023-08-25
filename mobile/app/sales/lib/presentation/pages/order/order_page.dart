import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:sales/presentation/pages/order/view/oder_pending_view.dart';
import 'package:sales/presentation/pages/order/view/order_history_view.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final List<Tab> tabs = [
    const Tab(text: 'Saat ini'),
    const Tab(text: 'Selesai'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan'),
          bottom: TabBar(
            tabs: tabs,
            indicatorColor: theme.colorScheme.primary,
          ),
        ),
        body: const TabBarView(
          children: [
            OrderPendingView(),
            OrderHistoryView(),
          ],
        ),
      ),
    );
  }
}
