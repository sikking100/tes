import 'package:customer/view_order/complete.dart';
import 'package:customer/view_order/ongoing.dart';
import 'package:customer/view_order/wait_pay.dart';
import 'package:customer/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PageOrderHistory extends HookWidget {
  const PageOrderHistory({super.key});

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
          actions: const [CartWidget()],
        ),
        body: const TabBarView(children: [
          ViewOrderWaitPay(),
          ViewOrderOngoing(),
          ViewOrderComplete(),
        ]),
      ),
    );
  }
}
