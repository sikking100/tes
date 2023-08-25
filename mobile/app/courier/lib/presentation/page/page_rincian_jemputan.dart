import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:courier/main.dart';
import 'package:courier/main_controller.dart';
import 'package:courier/presentation/page/home/view_pending.dart';
import 'package:courier/presentation/page/page_home.dart';
import 'package:courier/presentation/routes/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/common.dart';

final productChoosen = StateProvider.autoDispose<Map<String, dynamic>>((_) => {});

class PageRincianJemputan extends ConsumerWidget {
  final PackingListCourier packingList;
  final bool isRestock;
  const PageRincianJemputan({Key? key, required this.packingList, this.isRestock = false}) : super(key: key);

  Future<void> onPressed(WidgetRef ref) async {
    try {
      ref.read(loadingStateProvider.notifier).update((_) => true);
      final employee = ref.watch(userStateProvider);
      final req = Loaded(
        branchId: employee.location?.id ?? '-',
        warehouseId: packingList.product.first.warehouse?.id ?? '-',
        courierId: employee.id,
        product: packingList.product.asMap().map((key, value) => MapEntry(value.id, value.deliveryQty)),
      );
      await ref.read(apiProvider).delivery.loaded(req);
      ref.invalidate(pendingProvider);
      return;
    } catch (e) {
      rethrow;
    } finally {
      ref.read(loadingStateProvider.notifier).update((state) => false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = isRestock ? packingList.product.where((element) => element.brokenQty > 0).toList() : packingList.product;
    return Scaffold(
      appBar: AppBar(
        title: Text('Rincian Packing List ${packingList.product.first.warehouse?.name}'),
      ),
      body: Container(
        padding: const EdgeInsets.all(Dimens.px16),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(packingList.warehouse.name),
                      // Text(packingList.warehouse.addressName),
                      const SizedBox(height: Dimens.px10),
                      for (int i = 0; i < product.where((element) => element.deliveryQty > 0).length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, Routes.photoview, arguments: {'img': product[i].imageUrl}),
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      child: Container(
                                        height: 58,
                                        width: 58,
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Image.network(product[i].imageUrl),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product[i].category),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${product[i].name}, ${product[i].size}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),
                                        if (!isRestock) Text('${product[i].deliveryQty} pcs'),
                                        if (isRestock) Text('Retur ${product[i].brokenQty} pcs', style: const TextStyle(color: Colors.red))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: Dimens.px10),
                    ],
                  ),
                ),
              ),
            ),
            isRestock
                ? Container()
                : Consumer(
                    builder: (context, ref, child) {
                      final loading = ref.watch(loadingStateProvider);
                      return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size.fromWidth(
                              MediaQuery.of(context).size.width,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: loading
                              ? null
                              : () => onPressed(ref).then((value) => Navigator.pop(context)).catchError((e) => Alerts.dialog(context, content: '$e')),
                          child: loading ? const BtnLoading() : child);
                    },
                    child: const Text('Muat Barang'),
                  )
          ],
        ),
      ),
    );
  }
}
