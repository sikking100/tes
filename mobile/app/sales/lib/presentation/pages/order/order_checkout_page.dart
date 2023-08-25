import 'dart:io';

import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/presentation/pages/business/provider/business_create_provider.dart';
import 'package:sales/presentation/pages/cart/provider/cart_provider.dart';
import 'package:sales/presentation/pages/order/provider/order_checkout_provider.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/widgets/app_alert_dialog.dart';
import 'package:sales/presentation/widgets/app_bottom_sheet.dart';
import 'package:sales/presentation/widgets/app_button_widget.dart';
import 'package:sales/presentation/widgets/app_scaffold_messenger.dart';
import 'package:sales/presentation/widgets/app_square_button_widget.dart';
import 'package:file_picker/file_picker.dart';

class OrderCheckoutPage extends ConsumerWidget {
  const OrderCheckoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cusStateWatch = ref.watch(customerStateProvider);
    final orderStateWatch = ref.watch(createOrderStateProvider);
    final orderStateWatchNotifier =
        ref.watch(createOrderStateProvider.notifier);
    final orderStateReadNotifier = ref.read(createOrderStateProvider.notifier);
    final radioStateWatch = ref.watch(radioStateProvider);
    final totalPrice = ref.watch(cartStateNotifier.notifier).totalProduct();
    final imageRead = ref.read(imageParamPOProvider.notifier);
    final imageWatch = ref.watch(imageParamPOProvider);

    orderStateWatchNotifier.businessOfficeAddress.text =
        orderStateWatch.customer.addressName;

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(Dimens.px16),
          children: [
            Text(
              "Pelanggan",
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              initialValue: cusStateWatch.name,
              enabled: false,
              minLines: 1,
              maxLines: 5,
            ),
            const SizedBox(height: Dimens.px12),
            Text(
              "Alamat Pengantaran",
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: orderStateWatchNotifier.businessOfficeAddress,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Pilih alamat pengantaran',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_sharp),
                  onPressed: () async {
                    _showAddress(context, cusStateWatch.business!.address);
                  },
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Alamat tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: Dimens.px12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Waktu Pengantaran",
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Dimens.px12),
                SizedBox(
                  width: size.width,
                  child: AppSquareButtonWidget(
                      onPress: () async {
                        final DateTime? date = await showDatePicker(
                          builder: (_, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? schemeDark
                                      : scheme.copyWith(
                                          primary: scheme.secondary,
                                          onPrimary: scheme.onSecondary)),
                              child: child ?? Container(),
                            );
                          },
                          context: context,
                          initialDate: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day + 1,
                          ),
                          firstDate: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day + 1,
                          ),
                          lastDate: DateTime(
                            DateTime.now().year,
                            DateTime.now().month + 1,
                          ),
                          keyboardType: TextInputType.datetime,
                        );
                        if (date != null) {
                          orderStateReadNotifier.controllerDate.text =
                              date.fullDate;
                          orderStateReadNotifier.setState(
                              orderStateWatch.copyWith(deliveryAt: date));
                        }
                      },
                      icon: Icons.date_range_outlined,
                      title: orderStateWatchNotifier.controllerDate.text),
                ),
                Divider(
                  thickness: 0.8,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(height: Dimens.px12),
                Text(
                  "Unggah PO",
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Dimens.px12),
                SizedBox(
                  width: size.width,
                  child: AppSquareButtonWidget(
                      onPress: () {
                        AppBottomSheet.showBottomSheetImage(
                          context: context,
                          title: 'Pilih File',
                          onTapCamera: () async {
                            Navigator.pop(context);
                            final result = await ImagePicker()
                                .pickImage(source: ImageSource.camera);
                            if (result != null) {
                              imageRead.setImagePO(File(result.path));
                              orderStateWatchNotifier.controllerPO.text =
                                  result.name;
                            }
                          },
                          onTapGalery: () async {
                            Navigator.pop(context);
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['jpg', 'pdf'],
                            );
                            if (result != null) {
                              imageRead
                                  .setImagePO(File(result.files.first.path!));
                              orderStateWatchNotifier.controllerPO.text =
                                  result.files.first.name;
                            }
                          },
                        );
                      },
                      icon: Icons.file_upload,
                      title: imageWatch.imagePO.path.isNotEmpty
                          ? orderStateWatchNotifier.controllerPO.text
                          : imageWatch.imagePO.path),
                ),
                const Divider(
                  thickness: 0.5,
                  color: Colors.black,
                ),
                const SizedBox(height: Dimens.px12),
                Text(
                  "Catatan Pengantaran",
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: orderStateWatchNotifier.controllerNote,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan catatan pengantaran',
                    suffixIcon: Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: Dimens.px12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rincian Pembayaran',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Dimens.px12),
                    text(context, "Total Belanja", totalPrice.currency()),
                    const SizedBox(height: Dimens.px12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                        ),
                        Text(
                          (totalPrice).currency(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: mPrimaryColor,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: Dimens.px12),
                    Divider(
                      thickness: 0.8,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ],
                ),
                Text(
                  'Opsi Pembayaran',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RadioListTile<int>(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: Text(
                    'TRANSFER (bayar sekarang)',
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  dense: true,
                  value: PaymentMethod.trf,
                  groupValue: radioStateWatch,
                  onChanged: (value) {
                    ref
                        .read(radioStateProvider.notifier)
                        .update((state) => value ?? 0);
                  },
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                ),
                if (cusStateWatch.business != null)
                  RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Text(
                      'COD (bayar saat pesanan diantarkan)',
                      style: theme.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    dense: true,
                    value: PaymentMethod.cod,
                    groupValue: radioStateWatch,
                    onChanged: (value) {
                      ref
                          .read(radioStateProvider.notifier)
                          .update((state) => value ?? 1);
                    },
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                  ),
                Builder(
                  builder: (context) {
                    if (totalPrice > 500000 && cusStateWatch.business != null) {
                      return Column(
                        children: [
                          if (cusStateWatch.business!.credit.limit > 0)
                            RadioListTile<int>(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.trailing,
                              title: Text(
                                'TOP (bayar nanti saat jatuh tempo)',
                                style: theme.textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              dense: true,
                              value: PaymentMethod.top,
                              groupValue: radioStateWatch,
                              onChanged: (value) {
                                ref
                                    .read(radioStateProvider.notifier)
                                    .update((state) => value ?? 2);
                              },
                              visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity,
                              ),
                            ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(Dimens.px12),
            child: ref.watch(isLoadingProvider)
                ? const AppButtonLoading()
                : AppButtonPrimary(
                    onPressed: () async {
                      if (orderStateWatchNotifier
                          .businessOfficeAddress.text.isEmpty) {
                        return AppScaffoldMessanger.showSnackBar(
                            context: context,
                            message: "Pilih alamat pengantaran!");
                      } else if (orderStateWatchNotifier
                              .controllerDate.text.isEmpty ||
                          orderStateWatchNotifier.controllerDate.text ==
                              "Pilih Tanggal") {
                        return AppScaffoldMessanger.showSnackBar(
                            context: context,
                            message: "Pilih tanggal pengantaran!");
                      } else if (radioStateWatch == 3) {
                        return AppScaffoldMessanger.showSnackBar(
                            context: context,
                            message: "Pilih opsi pembayaran!");
                      } else {
                        try {
                          ref
                              .watch(isLoadingProvider.notifier)
                              .update((state) => true);
                          await orderStateWatchNotifier.createOrder().then(
                            (value) {
                              ref
                                  .watch(isLoadingProvider.notifier)
                                  .update((state) => false);
                              AppAlertDialog.show(
                                context: context,
                                title: "Yeaa",
                                content: "Pesanan berhasil dibuat",
                                onPressYes: () {
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.orderDetail,
                                    arguments: value.id,
                                  );
                                },
                              );
                            },
                          );
                        } catch (e) {
                          ref
                              .watch(isLoadingProvider.notifier)
                              .update((state) => false);
                          AppActionDialog.show(
                            context: context,
                            title: "Oops!",
                            content: e.toString(),
                            isAction: false,
                          );
                        }
                      }
                    },
                    title: 'Proses',
                  ),
          ),
        ),
      ),
    );
  }

  _showAddress(BuildContext context, List<BusinessAddress> address) {
    showModalBottomSheet<BusinessAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final stateWatchNotifier =
                ref.watch(createOrderStateProvider.notifier);
            final stateRead = ref.read(createOrderStateProvider.notifier);
            final stateWatch = ref.watch(createOrderStateProvider);
            return Container(
              height: MediaQuery.of(context).size.height * 0.60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Dimens.px30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: Dimens.px20),
                  Text(
                    "Pilih Alamat",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: address.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Alamat ${index + 1}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Text(
                                address[index].name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.check),
                          onTap: () async {
                            try {
                              stateWatchNotifier.businessOfficeAddress.text =
                                  address[index].name;
                              stateRead.setState(stateWatch.copyWith(
                                customer: stateWatch.customer.copyWith(
                                    addressLngLat: [
                                      address[index].lng,
                                      address[index].lat
                                    ],
                                    addressName: address[index].name),
                              ));
                              Navigator.pop(context);
                            } catch (e) {
                              AppScaffoldMessanger.showSnackBar(
                                  context: context, message: e.toString());
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget text(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(width: Dimens.px16),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}
