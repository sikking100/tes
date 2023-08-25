import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:courier/function/function.dart';
import 'package:courier/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PickDate {
  final DateTime startAt;
  final DateTime endAt;

  PickDate(this.startAt, this.endAt);

  PickDate copyWith({
    DateTime? startAt,
    DateTime? endAt,
  }) {
    return PickDate(
      startAt ?? this.startAt,
      endAt ?? this.endAt,
    );
  }
}

final datePickProvider = StateProvider.autoDispose<PickDate>((ref) {
  return PickDate(DateTime.now(), DateTime.now());
});

final packingListProvider = FutureProvider.autoDispose<List<PackingListCourier>>((ref) async {
  return ref.read(apiProvider).delivery.packingListCourier(6);
});

class ViewPackingList extends ConsumerWidget {
  const ViewPackingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(datePickProvider);
    final list = ref.watch(packingListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing List'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Center(child: Text('${date.startAt.parseDate} - ${date.endAt.parseDate}')),
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async => ref.refresh(packingListProvider),
        child: list.when(
          data: (data) => data.isEmpty
              ? LayoutBuilder(
                  builder: (p0, p1) => ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        constraints: BoxConstraints(
                          minHeight: p1.maxHeight,
                        ),
                        child: const Center(
                          child: Text('Belum ada data'),
                        ),
                      )
                    ],
                  ),
                )
              : ListView.separated(
                  itemBuilder: (context, index) => ExpansionTile(
                        textColor: Colors.red,
                        backgroundColor: Colors.grey.shade100,
                        title: Text(data[index].warehouse?.name ?? 'warehouse name'),
                        children: List.generate(
                          data[index].product.length,
                          (i) => ListTile(
                            title: Text(
                              '${data[index].product[i].name}, ${data[index].product[i].size}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text('${data[index].product[i].deliveryQty}'),
                          ),
                        ),
                      ),
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: data.length),
          error: (error, stackTrace) => Center(
            child: Text('$error'),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.date_range),
        onPressed: () async {
          final result = await showDateRangePicker(
            context: context,
            firstDate: DateTime(0),
            lastDate: DateTime(3000),
            builder: (_, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).brightness == Brightness.dark
                        ? schemeDark
                        : scheme.copyWith(primary: scheme.secondary, onPrimary: scheme.onSecondary)),
                child: child ?? Container(),
              );
            },
          );
          if (result != null) {
            ref.read(datePickProvider.notifier).update((state) => PickDate(result.start, result.end));
          }
        },
      ),
    );
  }
}
