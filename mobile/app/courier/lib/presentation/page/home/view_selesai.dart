import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:courier/common/widget.dart';

import 'package:courier/main.dart';
import 'package:courier/presentation/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restokeProvider = FutureProvider.autoDispose<List<PackingListCourier>>((ref) async {
  final api = ref.read(apiProvider);
  return api.delivery.packingListCourier(8);
});

class ViewSelesai extends ConsumerWidget {
  const ViewSelesai({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoke = ref.watch(restokeProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.inventory_2_outlined),
        onPressed: () => Navigator.pushNamed(context, Routes.looaded),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async => ref.refresh(restokeProvider),
        child: restoke.when(
          data: (data) => data.isEmpty
              ? LayoutBuilder(
                  builder: (p0, p1) => ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        constraints: BoxConstraints(minHeight: p1.maxHeight),
                        child: const Center(
                          child: Text('Belum ada data'),
                        ),
                      )
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(Dimens.px16),
                  itemBuilder: (context, index) {
                    final e = data[index];
                    return WarehouseItem(packingList: e, isRestock: true, number: index);
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: data.length,
                ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$error'),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: () => ref.refresh(restokeProvider), child: const Text('Refresh'))
              ],
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }
}
