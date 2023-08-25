import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:customer/argument.dart';
import 'package:customer/pages/checkout.dart';
import 'package:customer/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PageBusinessListAddress extends HookWidget {
  final ArgBusinessListAddress arg;
  const PageBusinessListAddress({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final listAddress = useState<List<BusinessAddress>>(arg.items);

    return WillPopScope(
      onWillPop: () {
        if (arg.isCheckout) {
          Navigator.pop(context);
        } else {
          Navigator.pop(context, listAddress.value);
        }
        return Future.value(true);
      },
      child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                if (arg.isCheckout) {
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context, listAddress.value);
                }
              },
            ),
            title: const Text('Alamat Pengantaran'),
            actions: [
              listAddress.value.isEmpty
                  ? Container()
                  : arg.isCheckout
                      ? Container()
                      : IconButton(
                          onPressed:
                              // () async {
                              //   final result = await Navigator.pushNamed(context, Routes.mapPick) as BusinessAddress?;
                              //   if (result != null) {
                              //     SimpleLogger().info(result);
                              //     listAddress.value = [
                              //       ...listAddress.value,
                              //       result,
                              //     ];
                              //   }
                              // },
                              () => Navigator.pushNamed(context, Routes.mapPick,
                                  arguments: ArgMap(
                                    action: (v) => listAddress.value = [
                                      ...listAddress.value,
                                      v,
                                    ],
                                  )),
                          icon: const Icon(Icons.add),
                        )
            ],
          ),
          body: Column(
            children: [
              listAddress.value.isEmpty
                  ? GestureDetector(
                      onTap:
                          // () async {
                          //   final result = await Navigator.pushNamed(context, Routes.mapPick) as BusinessAddress?;
                          //   if (result != null) {
                          //     SimpleLogger().info(result);
                          //     listAddress.value = [
                          //       ...listAddress.value,
                          //       result,
                          //     ];
                          //   }
                          // },
                          () => Navigator.pushNamed(
                        context,
                        Routes.mapPick,
                        arguments: ArgMap(
                          action: (v) => listAddress.value = [
                            ...listAddress.value,
                            v,
                          ],
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(5)),
                        margin: const EdgeInsets.all(Dimens.px16),
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(Dimens.px16),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Tambah Alamat'),
                            Icon(Icons.add),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(Dimens.px16),
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () async {
                            if (!arg.isCheckout) {
                              // final result = await Navigator.pushNamed(context, Routes.mapPick, arguments: ArgMap(address: listAddress.value[index]))
                              //     as BusinessAddress?;
                              // if (result != null) {
                              //   listAddress.value = [
                              //     for (int i = 0; i < listAddress.value.length; i++)
                              //       if (i == index)
                              //         listAddress.value[i].copyWith(
                              //           lngLat: result.lngLat,
                              //           name: result.name,
                              //         )
                              //       else
                              //         listAddress.value[i]
                              //   ];
                              // }
                              Navigator.pushNamed(
                                context,
                                Routes.mapPick,
                                arguments: ArgMap(
                                  action: (v) => listAddress.value = [
                                    for (int i = 0; i < listAddress.value.length; i++)
                                      if (i == index)
                                        listAddress.value[i].copyWith(
                                          lngLat: v.lngLat,
                                          name: v.name,
                                        )
                                      else
                                        listAddress.value[i]
                                  ],
                                ),
                              );
                              return;
                            }
                            Navigator.pop(context, listAddress.value[index]);
                            return;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(Dimens.px16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Alamat ${index + 1}'),
                                    const Spacer(),
                                    arg.isCheckout
                                        ? Container()
                                        : IconButton(
                                            onPressed: () => listAddress.value = [
                                              for (final v in listAddress.value)
                                                if (v != listAddress.value[index]) v
                                            ],
                                            icon: const Icon(Icons.delete),
                                          )
                                  ],
                                ),
                                Text(listAddress.value[index].name),
                              ],
                            ),
                          ),
                        ),
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: listAddress.value.length,
                      ),
                    ),
              arg.isCheckout
                  ? Consumer(
                      builder: (context, ref, child) => GestureDetector(
                        onTap: () async {
                          final result = await Navigator.pushNamed(context, Routes.mapPick,
                              arguments: ArgMap(
                                action: (v) => ref.read(pickedLocation.notifier).update((state) => v),
                              ));
                          if (result != null && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(5)),
                          margin: const EdgeInsets.all(Dimens.px16),
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(Dimens.px16),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Gunakan Alamat Sementara'),
                              Icon(Icons.add),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          )),
    );
  }
}
