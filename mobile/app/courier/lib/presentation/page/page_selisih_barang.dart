import 'package:api/api.dart' hide logger;
import 'package:courier/common/constant.dart';
import 'package:courier/common/widget.dart';
import 'package:courier/main_controller.dart';
import 'package:courier/presentation/page/home/view_pengantaran.dart';
import 'package:courier/presentation/page/home/view_proses.dart';
import 'package:courier/presentation/page/home/view_rute.dart';
import 'package:courier/presentation/page/page_home.dart';
import 'package:courier/presentation/page/page_rincian_pengantaran.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/common.dart';

class PageSelisihBarang extends ConsumerWidget {
  final List<DeliveryProduct> products;
  final String idDelivery;
  final int status;
  final String defaultNote;
  final _formKey = GlobalKey<FormState>();
  PageSelisihBarang({Key? key, required this.products, required this.idDelivery, required this.status, required this.defaultNote}) : super(key: key);
  final Map<String, int> broken = {};
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonLoading = ref.watch(loadingStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selisih Barang'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: mPadding,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var product in products)
                  if (product.deliveryQty == 0)
                    Container()
                  else
                    Column(
                      children: [
                        // Text(products.keys.toList()[i]),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text((i + 1).toString()),
                            // const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.id),
                                  Text(
                                    '${product.name}, ${product.size}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('${product.deliveryQty} pcs'),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Input Selisih',
                                      focusedBorder: UnderlineInputBorder(),
                                      hintText: 'Input Selisih',
                                    ),
                                    onChanged: (value) async {
                                      if (value.isEmpty || value == '0') {
                                        broken.remove(product.id);
                                        return;
                                      }
                                      final count = int.tryParse(value);
                                      if (count != null) {
                                        if (count == 0) {
                                          broken.remove(product.id);
                                          return;
                                        }
                                        if (count > product.deliveryQty) {
                                          broken.remove(product.id);
                                          return;
                                        }
                                        broken[product.id] = count;
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null) return null;
                                      final count = int.tryParse(value);
                                      if (count == null) return null;
                                      if (count == 0) {
                                        return 'Input tidak valid';
                                      }
                                      if (count > product.deliveryQty) {
                                        return 'Selisih tidak boleh lebih besar\ndaripada jumlah barang yang diantar';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const Divider(),
                      ],
                    ),
                const SizedBox(height: 470),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(MediaQuery.of(context).size.width, 48),
                  ),
                  onPressed: buttonLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() == false) {
                            return;
                          }

                          final productBrokens = <DeliveryProduct>[];

                          for (var el in products) {
                            if (broken.containsKey(el.id)) {
                              productBrokens.add(
                                el.copyWith(
                                  brokenQty: broken[el.id],
                                  reciveQty: el.deliveryQty - (broken[el.id] ?? 0),
                                ),
                              );
                            } else {
                              productBrokens.add(el);
                            }
                          }
                          ref
                              .read(antarStateProvider(idDelivery).notifier)
                              .selesai(
                                defaultNote: defaultNote,
                                products: productBrokens,
                                isRestock: true,
                              )
                              .then((value) => Navigator.pop(context))
                              .then((value) => Navigator.pop(context))
                              .then((value) {
                            if (ref.watch(indexStateProvider) == 1 && ref.watch(pengantaranStateProvider) == 1) {
                              ref.read(prosesStateNotifier).refresh();
                            } else {
                              ref.invalidate(rutesStateNotifier);
                            }
                          }).catchError(
                            (error, stackTrace) {
                              myAlert(context, errorText: error.toString());
                              return;
                            },
                          );
                        },
                  child: buttonLoading ? const BtnLoading() : const Text('Laporkan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MaxItem extends TextInputFormatter {
  final int max;

  MaxItem(this.max);
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final result = int.tryParse(newValue.text);
    final textSeletion = newValue.selection;
    String truncated = newValue.text;
    if (result == null) {
      return TextEditingValue(text: truncated, selection: textSeletion);
    }
    if (result > max) {
      truncated = '';
    }
    return TextEditingValue(text: truncated, selection: textSeletion);
  }
}
