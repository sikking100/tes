import 'package:common/common.dart';
import 'package:customer/pages/business_detail.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ViewBusinessPayLater extends ConsumerWidget {
  const ViewBusinessPayLater({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(businessStateProvider.notifier).customer;
    return ListView(
      children: [
        ListTile(
          title: const Text('Total Tagihan'),
          trailing: Text((customer.business?.credit.used.toInt() ?? 0).currency()),
          shape: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
            ),
          ),
        ),
        // ListTile(
        //   title: const Text('Sisa Limit'),
        //   trailing: Text((data.payLater!.limit! - data.payLater!.used!).currency()),
        //   shape: UnderlineInputBorder(
        //     borderSide: BorderSide(
        //       color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
        //     ),
        //   ),
        // ),
        ListTile(
          title: const Text('Jangka Waktu Pembayaran'),
          trailing: Text('${customer.business?.credit.term} hari'),
          shape: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
            ),
          ),
        ),
        ListTile(
          title: const Text('Jangka Waktu Invoice'),
          trailing: Text('${customer.business?.credit.termInvoice} hari'),
          shape: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
            ),
          ),
        ),
      ],
    );
  }
}
