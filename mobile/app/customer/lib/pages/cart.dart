import 'package:common/constant/constant.dart';
import 'package:customer/argument.dart';
import 'package:customer/cart.dart';
import 'package:customer/routes.dart';
import 'package:customer/widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:common/common.dart';

class PageCart extends ConsumerWidget {
  const PageCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartStateNotifier);
    final cartNotifier = ref.watch(cartStateNotifier.notifier);
    final uniqueList = cart.toSet().toList();
    uniqueList.sort(((a, b) => a.id.compareTo(b.id)));
    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Keranjang'),
        ),
        body: const Center(
          child: Text(
            'Keranjang Anda kosong.\nBelanja dulu yuk!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(Dimens.px16),
              itemBuilder: (_, index) {
                final product = uniqueList[index];
                final price = product.price.first.price;

                return Column(
                  children: [
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, Routes.productDetail, arguments: ArgProductDetail(product.id)),
                          child: Card(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                // boxShadow: const [
                                //   BoxShadow(
                                //     color: mTextfieldLoginColor,
                                //     blurRadius: 1,
                                //     offset: Offset(0, 0),
                                //   ),
                                //   BoxShadow(
                                //     color: mTextfieldLoginColor,
                                //     blurRadius: 1,
                                //     offset: Offset(0, 2),
                                //   ),
                                // ],
                                color: Theme.of(context).highlightColor.withOpacity(0.3),
                              ),
                              child: Image.network(product.imageUrl),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.w900),
                                maxLines: 2,
                              ),
                              Text(
                                product.size,
                                style: const TextStyle(),
                              ),
                              cartNotifier.discount(product.productId).discount > 0
                                  ? Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${price.currency()}\n',
                                            style: TextStyle(
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: Colors.black,
                                              decorationThickness: Theme.of(context).brightness == Brightness.dark ? 3 : 1.5,
                                              fontSize: 13,
                                            ),
                                          ),
                                          TextSpan(
                                            text: (price - cartNotifier.discount(product.productId).discount).currency(),
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Text(price.currency()),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 28 / 100,
                          child: WidgetPlusMinusButton(
                            isCenter: false,
                            add: () => ref.read(cartStateNotifier.notifier).add(product),
                            remove: () async {
                              if (cart.where((element) => element.productId == product.productId).toList().length == 1) {
                                await warning(context,
                                    title: 'Peringatan!', errorText: 'Apakah Anda yakin ingin menghapus produk ini dari keranjang?', onPressed: () {
                                  Navigator.pop(context);

                                  ref.read(cartStateNotifier.notifier).remove(product.productId);
                                });
                                return;
                              } else {
                                ref.read(cartStateNotifier.notifier).remove(product.productId);
                              }
                            },
                            qtys: cart.where((element) => element.productId == product.productId).toList().length,
                            qty: TextCount(product: product),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 20),
              itemCount: uniqueList.length,
            ),
          ),
          SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final totalPrice = ref.watch(cartStateNotifier.notifier).totalProduct();
                        if (totalPrice < 50000) throw 'Belanjaan Anda masih kurang dari ${50000.currency()}.  Belanja lagi yuk!';

                        Navigator.pushNamed(context, Routes.checkout);
                        return;
                      } catch (e) {
                        Alerts.dialog(context, content: e.toString());
                        return;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary, borderRadius: const BorderRadius.only(topRight: Radius.circular(30))),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total Pesanan',
                          style: TextStyle(),
                        ),
                        const SizedBox(height: 5),
                        FittedBox(
                          child: Text(
                            ref.watch(cartStateNotifier.notifier).totalProduct().currency(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
