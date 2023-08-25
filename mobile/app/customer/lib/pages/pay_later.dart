import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PagePayLater extends ConsumerWidget {
  const PagePayLater({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(appBar: AppBar(title: const Text('Pay Later')), body: const ViewCreateApproval()

        // Container(
        //   width: MediaQuery.of(context).size.width,
        //   padding: const EdgeInsets.all(Dimens.px16),
        //   child: data.when(
        //     data: (data) {
        //       if (data.payLater == null) {
        //         if (data.applyPayLater == null || data.applyPayLater?.id.isEmpty == true) {
        //           return const ViewCreateApproval();
        //         }
        //         if (data.applyPayLater?.status == Status.intReject) {
        //           return const ViewCreateApproval(
        //               status: 'Mohon maaf pengajuan Pay Later Anda belum disetujui.  Hubungi kami melalui "Pusat Bantuan" untuk info selanjutnya.');
        //         }
        //         return Center(child: Text('${data.applyPayLater?.status}'));
        //       }
        //       return Column(
        //         children: [
        //           // ListTile(
        //           //   title: const Text('Limit Disetujui'),
        //           //   trailing: Text(data.payLater!.limit!.currency()),
        //           //   shape: UnderlineInputBorder(
        //           //     borderSide: BorderSide(
        //           //       color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
        //           //     ),
        //           //   ),
        //           // ),
        //           ListTile(
        //             title: const Text('Total Tagihan'),
        //             trailing: Text(data.payLater!.used.currency()),
        //             shape: UnderlineInputBorder(
        //               borderSide: BorderSide(
        //                 color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
        //               ),
        //             ),
        //           ),
        //           // ListTile(
        //           //   title: const Text('Sisa Limit'),
        //           //   trailing: Text((data.payLater!.limit! - data.payLater!.used!).currency()),
        //           //   shape: UnderlineInputBorder(
        //           //     borderSide: BorderSide(
        //           //       color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
        //           //     ),
        //           //   ),
        //           // ),
        //           ListTile(
        //             title: const Text('Jangka Waktu Pembayaran'),
        //             trailing: Text('${data.payLater!.day.toString()} hari'),
        //             shape: UnderlineInputBorder(
        //               borderSide: BorderSide(
        //                 color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
        //               ),
        //             ),
        //           ),
        //         ],
        //       );
        //     },
        //     error: (error, stackTrace) => Center(child: Text('$error')),
        //     loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        //   ),
        // ),
        );
  }
}

class ViewCreateApproval extends HookConsumerWidget {
  final String? status;
  const ViewCreateApproval({Key? key, this.status}) : super(key: key);

  void onPressed(WidgetRef ref, BuildContext context, ValueNotifier<bool> loading) async {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState<bool>(false);
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(status ?? 'Ajukan Pay Later untuk mendapatkan fitur pembayaran TOP.', textAlign: TextAlign.center),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: loading.value ? null : () => onPressed(ref, context, loading),
            child: loading.value
                ? const Center(child: FittedBox(child: CircularProgressIndicator.adaptive()))
                : Text(status == null ? 'Ajukan' : 'Ajukan Kembali'),
          ),
        ],
      ),
    );
  }
}
