import 'package:api/common.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/cart_provider.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/routes.dart';
import 'package:leader/widget.dart';

class PageCart extends ConsumerWidget {
  const PageCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartStateNotifier);
    final cartNotifier = ref.watch(cartStateNotifier.notifier);
    final uniqueList = cart.toSet().toList();
    final customer = ref.watch(customerStateProvider);
    uniqueList.sort(((a, b) => a.id.compareTo(b.id)));
    final emp = ref.watch(employeeStateProvider);
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
                final price = product.kPrice(customer.business?.priceList.id).price;
                final adds = ref.watch(doubleProvider);

                return Column(
                  children: [
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Card(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
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
                              GestureDetector(
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Consumer(
                                    builder: (context, ref, child) {
                                      final add = ref.watch(doubleProvider);
                                      return Padding(
                                        padding: const EdgeInsets.all(Dimens.px16).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 35,
                                              height: 5,
                                              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(15)),
                                            ),
                                            const SizedBox(height: 30),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () => ref.read(doubleProvider.notifier).update((state) {
                                                    // if (state == -100) return state;
                                                    // if (employee.roles == UserRoles.intAm && state == -7.5) return state;
                                                    // if (employee.roles == UserRoles.intRm && state == -10) return state;
                                                    // if (employee.roles == UserRoles.intNsm && state == -20) return state;
                                                    if (state[product.productId] == 0) return state;
                                                    final result = (state[product.productId] ?? 0) - 0.25;
                                                    return {
                                                      ...state,
                                                      product.productId: result,
                                                    };
                                                  }),
                                                  child: const Icon(
                                                    Icons.remove_circle,
                                                    size: 30,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  '${(add[product.productId] ?? 0.0).toStringAsFixed(2)} %',
                                                  style: const TextStyle(fontSize: 25),
                                                ),
                                                const SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () => ref.read(doubleProvider.notifier).update((state) {
                                                    if (state[product.productId] == 100) return state;
                                                    if (emp.roles == UserRoles.am && state[product.productId] == 7.5) return state;
                                                    if (emp.roles == UserRoles.rm && state[product.productId] == 10) return state;
                                                    if (emp.roles == UserRoles.nsm && state[product.productId] == 20) return state;
                                                    final result = (state[product.productId] ?? 0) + 0.25;
                                                    return {
                                                      ...state,
                                                      product.productId: result,
                                                    };
                                                  }),
                                                  child: const Icon(
                                                    Icons.add_circle_outlined,
                                                    size: 30,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                              ],
                                            ),
                                            const SizedBox(height: 50),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                child: cartNotifier.discount(product.productId).discount > 0 ||
                                        (adds[product.productId] != null && adds[product.productId] != 0.0)
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
                                              text: (price -
                                                      cartNotifier.discount(product.productId).discount -
                                                      cartNotifier.additional((adds[product.productId] ?? 0), product.productId))
                                                  .currency(),
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(price.currency()),
                              )
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
                                  ref.read(doubleProvider.notifier).update((state) {
                                    state.remove(product.productId);
                                    return state;
                                  });
                                  ref.read(cartStateNotifier.notifier).remove(product.productId);
                                });
                                return;
                              } else {
                                ref.read(cartStateNotifier.notifier).remove(product.productId);
                              }
                            },
                            qtys: cart.where((element) => element.id == product.id).toList().length,
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
                        if (totalPrice < 50000) {
                          throw 'Belanjaan Anda masih kurang dari ${50000.currency()}.  Belanja lagi yuk!';
                        }

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => CheckoutPage(customer: customer),
                        //   ),
                        // );
                        ref.read(customerStateProvider.notifier).update((state) => customer);
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
