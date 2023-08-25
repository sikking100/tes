import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:courier/main.dart';
import 'package:courier/presentation/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadedProvider = FutureProvider.autoDispose<List<DeliveryProduct>>((ref) async {
  return ref.read(apiProvider).delivery.productByStatus(5);
});

class PageLoaded extends ConsumerWidget {
  const PageLoaded({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(loadedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dimuat"),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async => ref.refresh(loadedProvider),
        child: ListView(
          padding: const EdgeInsets.all(Dimens.px16),
          children: loaded.when(
            data: (data) {
              return [
                for (int i = 0; i < data.length; i++)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, Routes.photoview, arguments: {'img': data[i].imageUrl}),
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
                            child: Image.network(data[i].imageUrl),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data[i].category),
                            const SizedBox(height: 5),
                            Text(
                              '${data[i].name}, ${data[i].size}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text('${data[i].deliveryQty} pcs'),
                          ],
                        ),
                      )
                    ],
                  ),
              ];
            },
            error: (error, stackTrace) => [
              Center(
                child: Text('$error'),
              )
            ],
            loading: () => [
              const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
