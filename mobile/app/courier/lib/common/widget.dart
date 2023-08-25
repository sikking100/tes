import 'package:api/delivery/model.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:courier/function/function.dart';
import 'package:courier/presentation/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> myAlert(BuildContext context, {String? title, required String errorText}) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title ?? 'Oops'),
        content: Text(errorText),
        actions: [
          CupertinoDialogAction(
            child: const Text('Ok'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
    return;
  }
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title ?? 'Oops'),
      content: Text(errorText),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Ok'),
        ),
      ],
    ),
  );
  return;
}

Future<void> warning(BuildContext context, {String? title, required String errorText, required void Function()? onPressed}) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title ?? 'Oops'),
        content: Text(errorText),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: onPressed,
            child: const Text('Ya'),
          ),
        ],
      ),
    );
    return;
  }
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title ?? 'Oops'),
      content: Text(errorText),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.secondary,
            side: BorderSide(color: Theme.of(context).colorScheme.secondary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Tidak'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: onPressed,
          child: const Text('Ya'),
        ),
      ],
    ),
  );
  return;
}

class WidgetPengantaran extends StatelessWidget {
  const WidgetPengantaran({
    Key? key,
    required this.datas,
    required this.ref,
    this.isRiwayat = false,
  }) : super(key: key);

  final Delivery datas;
  final WidgetRef ref;
  final bool isRiwayat;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isRiwayat) {
          Navigator.pushNamed(context, Routes.riwayatRincian, arguments: datas.id);
          return;
        }
        Navigator.pushNamed(
          context,
          Routes.rincianPengantaran,
          arguments: datas,
        ).then((value) {
          if (value != null) {
            final arg = value as Map<String, dynamic>;
            if (arg['isAntar'] == true) {
              DefaultTabController.of(context).index = 2;
              return;
            }
          }
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // const CircleAvatar(
          //   backgroundImage: NetworkImage(mImage),
          //   radius: 23,
          // ),
          // const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  datas.customer.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 5),
                Text(
                  datas.customer.addressName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 5),
                Text((datas.status != 1 ? datas.createdAt.fullDate : datas.deliveryAt.fullDate)),
                const SizedBox(height: 5),
                Text(datas.status != 1 ? datas.createdAt.parseTime : orderingTime(datas.deliveryAt.hour)),
                Text(datas.note),
              ],
            ),
          ),
          if (isRiwayat && datas.status == 2)
            const Icon(
              Icons.arrow_forward_ios,
              color: mArrowIconColor,
            )
          else if (!isRiwayat && datas.status != 2)
            const Icon(
              Icons.arrow_forward_ios,
              color: mArrowIconColor,
            )
        ],
      ),
    );
  }
}

class InputDoneView extends StatelessWidget {
  const InputDoneView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: CupertinoColors.systemGrey6,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: CupertinoButton(
            padding: const EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
            onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: const Text(
              'Done',
              style: TextStyle(color: CupertinoColors.systemBlue),
            ),
          ),
        ),
      ),
    );
  }
}

class TextCopy extends StatelessWidget {
  final String text;
  const TextCopy({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$text ',
          ),
          WidgetSpan(
            child: GestureDetector(
              child: const Icon(Icons.copy, size: 17),
              onTap: () => Clipboard.setData(ClipboardData(text: text)).then(
                (value) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil disalin'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WarehouseItem extends StatelessWidget {
  const WarehouseItem({
    Key? key,
    required this.packingList,
    this.isRestock = false,
    required this.number,
  }) : super(key: key);

  final PackingListCourier packingList;
  final bool isRestock;
  final int number;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.rincianPackingList, arguments: {
        "list": packingList,
        "isRestock": isRestock,
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text('Packing List - ${number + 1}'),
          Text(packingList.product.first.warehouse?.name ?? 'name'),
          const SizedBox(
            height: 5,
          ),
          Text(packingList.product.first.warehouse?.addressName ?? 'warehouse address name'),
          const SizedBox(
            height: 5,
          ),
          const SizedBox(height: Dimens.px8),
        ],
      ),
    );
  }
}
