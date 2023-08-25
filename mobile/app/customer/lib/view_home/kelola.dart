import 'package:api/order/model.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:customer/argument.dart';
import 'package:customer/cart.dart';
import 'package:customer/main_controller.dart';
import 'package:customer/pages/home.dart';
import 'package:customer/routes.dart';
import 'package:customer/view_home/beranda.dart';
import 'package:customer/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final versionProvider = FutureProvider<String>((ref) async {
  final result = await PackageInfo.fromPlatform();
  return result.version;
});

final orderPendingProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final user = ref.watch(customerStateProvider);
  final result = await ref.watch(apiProvider).order.find(num: 1, limit: 50, query: '${user.id},1');

  return result.items;
});

class ViewHomeKelola extends ConsumerWidget {
  const ViewHomeKelola({super.key});

  Future<void> logout(WidgetRef ref, BuildContext context) async {
    try {
      Navigator.pop(context);

      await FirebaseAuth.instance.signOut();
      await Future.delayed(const Duration(seconds: 1));
      return;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(versionProvider);
    final customer = ref.watch(customerStateProvider);
    final orderPending = ref.watch(orderPendingProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola'),
      ),
      body: Kelola(
        keluar: () => Alerts.dialog(
          context,
          content: 'Anda yakin ingin keluar?',
          title: 'Peringatan',
          cancel: () => Navigator.pop(context),
          ok: () => logout(ref, context).then((v) {
            ref.invalidate(customerStateProvider);
            ref.invalidate(branchProvider);
            ref.invalidate(cartStateNotifier);
          }).catchError(
            (e) async {
              await Alerts.dialog(context, content: '$e');
              return;
            },
          ),
        ),
        orderHistory: ListTile(
          contentPadding: const EdgeInsets.only(right: 20),
          leading: const Icon(Icons.notes),
          title: const Text('Pesanan'),
          minLeadingWidth: 0,
          trailing: orderPending.whenOrNull(
            data: (data) => BadgeWidget(
              value: data.length.toString(),
              isChild: const SizedBox(),
            ),
          ),
          horizontalTitleGap: 10,
          minVerticalPadding: 0,
          onTap: () => Navigator.pushNamed(context, Routes.orderHistory, arguments: ArgOrderHistory(1)),
        ),
        webviewRoute: Routes.webview,
        tema: () => Navigator.pushNamed(context, Routes.theme),
        profile: customer.business != null
            ? () => Navigator.pushNamed(context, Routes.businessDetail, arguments: ArgBusinessDetail(business: customer))
            : () => Navigator.pushNamed(context, Routes.profile),
        version: version.when(
          data: (data) => data,
          error: (error, stackTrace) => error.toString(),
          loading: () => '',
        ),
        isBusiness: customer.business != null,
        urlApp: urlApp,
      ),
    );
  }
}
