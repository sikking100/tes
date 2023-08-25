import 'package:carousel_slider/carousel_slider.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/argument.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:badges/badges.dart' as b;
import 'package:leader/routes.dart';

class Pengajuan extends Equatable {
  final int order;
  final int business;

  const Pengajuan(this.order, this.business);

  @override
  List<Object> get props => [order, business];
}

final getPengajuanProvider = FutureProvider.autoDispose<int>((ref) async {
  final emp = ref.read(employeeStateProvider);
  final bus = await ref.read(apiProvider).apply.find(userId: emp.id, type: 2);
  return bus.items.length;
});

final getOverlimitOverdueProvider = FutureProvider.autoDispose<int>((ref) async {
  final ord = await ref.read(apiProvider).orderApply.find(0);
  return ord.length;
});

final bannerProvider = FutureProvider<List<String>>((ref) async {
  final res = await ref.read(apiProvider).banner.findInternal();
  return res.map((e) => e.imageUrl).toList();
});

class ViewDashboard extends ConsumerWidget {
  const ViewDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banner = ref.watch(bannerProvider);
    final employee = ref.read(employeeStateProvider);
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: banner.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(
                  child: Text('Banner kosong'),
                );
              }
              return WidgetBanner(data: data);
            },
            error: (error, stackTrace) => WidgetError(error: error.toString(), onPressed: () => ref.invalidate(bannerProvider)),
            loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          ),
        ),
        Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(Dimens.px16),
              child: Column(
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Flexible(
                          child: WidgetMenuDashboard(
                            onTap: () {
                              if (employee.roles == 13) {
                                Navigator.pushNamed(context, Routes.performance, arguments: ArgPerformance(employee.location?.id ?? 'id', 'BRANCH'));
                              } else if (employee.roles == 12) {
                                Navigator.pushNamed(context, Routes.performance, arguments: ArgPerformance(employee.location?.id ?? 'id', 'REGION'));
                              } else {
                                Navigator.pushNamed(context, Routes.regions);
                              }
                              return;
                            },
                            imgPath: 'report_order.png',
                            title: 'Performa',
                          ),
                        ),
                        const SizedBox(width: Dimens.px16),
                        // Flexible(
                        //   child: WidgetMenuDashboard(
                        //     onTap: () => Navigator.pushNamed(context, Routes.catalogs),
                        //     imgPath: 'product.png',
                        //     title: 'Produk',
                        //   ),
                        // ),
                        Flexible(
                          child: WidgetMenuDashboard(
                            onTap: () => Navigator.pushNamed(context, Routes.business),
                            imgPath: 'customer.png',
                            title: 'Bisnis',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimens.px16),
                  Flexible(
                    child: Row(
                      children: [
                        Flexible(
                          child: WidgetMenuDashboard(
                            onTap: () => Navigator.pushNamed(context, Routes.orders),
                            imgPath: 'order.png',
                            title: 'Pesanan',
                          ),
                        ),
                        const SizedBox(width: Dimens.px16),
                        // Flexible(
                        //   child: WidgetMenuDashboard(
                        //     onTap: () => Navigator.pushNamed(context, Routes.business),
                        //     imgPath: 'customer.png',
                        //     title: 'Bisnis',
                        //   ),
                        // ),
                        Flexible(
                          child: WidgetMenuDashboard(
                            onTap: () => Navigator.pushNamed(context, Routes.reports),
                            imgPath: 'report.png',
                            title: 'Laporan',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimens.px16),
                  Flexible(
                    child: Row(
                      children: [
                        // Flexible(
                        //   child: WidgetMenuDashboard(
                        //     isPengajuan: true,
                        //     onTap: () {
                        //       ref.invalidate(getPengajuanProvider);
                        //       return showModalBottomSheet(
                        //         context: context,
                        //         builder: (context) => Consumer(
                        //           builder: (context, ref, child) {
                        //             final res = ref.watch(getPengajuanProvider);
                        //             return res.when(
                        //               data: (data) => Column(
                        //                 crossAxisAlignment: CrossAxisAlignment.start,
                        //                 mainAxisSize: MainAxisSize.min,
                        //                 children: [
                        //                   ListTile(
                        //                     onTap: () => Navigator.popAndPushNamed(context, Routes.approvalBusiness),
                        //                     title: const Text('Pengajuan Bisnis'),
                        //                     trailing: b.Badge(
                        //                       showBadge: data.business > 0,
                        //                       badgeContent: Text(data.business.toString(), style: const TextStyle(color: Colors.white)),
                        //                     ),
                        //                   ),
                        //                   ListTile(
                        //                     onTap: () => Navigator.pushNamed(context, Routes.approvalOrder),
                        //                     title: const Text('Overlimit / Overdue'),
                        //                     trailing: b.Badge(
                        //                       showBadge: data.order > 0,
                        //                       badgeContent: Text(data.order.toString(), style: const TextStyle(color: Colors.white)),
                        //                     ),
                        //                   )
                        //                 ],
                        //               ),
                        //               error: (error, stackTrace) => Column(
                        //                 mainAxisSize: MainAxisSize.min,
                        //                 children: [
                        //                   ListTile(
                        //                     onTap: () => Navigator.popAndPushNamed(context, Routes.approvalBusiness),
                        //                     title: const Text('Pengajuan Bisnis'),
                        //                   ),
                        //                   ListTile(
                        //                     onTap: () => Navigator.pushNamed(context, Routes.approvalOrder),
                        //                     title: const Text('Overlimit / Overdue'),
                        //                   )
                        //                 ],
                        //               ),
                        //               loading: () => Column(
                        //                 mainAxisSize: MainAxisSize.min,
                        //                 children: [
                        //                   ListTile(
                        //                     onTap: () => Navigator.popAndPushNamed(context, Routes.approvalBusiness),
                        //                     title: const Text('Pengajuan Bisnis'),
                        //                   ),
                        //                   ListTile(
                        //                     onTap: () => Navigator.pushNamed(context, Routes.approvalOrder),
                        //                     title: const Text('Overlimit / Overdue'),
                        //                   )
                        //                 ],
                        //               ),
                        //             );
                        //           },
                        //         ),
                        //       );
                        //     },
                        //     imgPath: 'approval.png',
                        //     title: 'Pengajuan',
                        //   ),
                        // ),
                        Flexible(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final res = ref.watch(getPengajuanProvider);
                              return res.when(
                                data: (data) => WidgetMenuDashboardPengajuan(
                                  onTap: () async {
                                    await Navigator.pushNamed(context, Routes.approvalBusiness);
                                    ref.invalidate(getPengajuanProvider);
                                    return;
                                  },
                                  imgPath: 'approval.png',
                                  title: 'Pengajuan Bisnis',
                                  data: data,
                                ),
                                error: (error, stackTrace) => WidgetMenuDashboardPengajuan(
                                  onTap: () => Navigator.pushNamed(context, Routes.approvalBusiness),
                                  imgPath: 'approval.png',
                                  title: 'Pengajuan Bisnis',
                                  data: 0,
                                ),
                                loading: () => WidgetMenuDashboardPengajuan(
                                  onTap: () => Navigator.pushNamed(context, Routes.approvalBusiness),
                                  imgPath: 'approval.png',
                                  title: 'Pengajuan Bisnis',
                                  data: 0,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: Dimens.px16),
                        Flexible(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final res = ref.watch(getOverlimitOverdueProvider);
                              return res.when(
                                data: (data) => WidgetMenuDashboardPengajuan(
                                  onTap: () async {
                                    await Navigator.pushNamed(context, Routes.approvalOrder);
                                    ref.invalidate(getOverlimitOverdueProvider);
                                    return;
                                  },
                                  imgPath: 'product.png',
                                  title: 'Overdue / Overlimit',
                                  data: data,
                                ),
                                error: (error, stackTrace) => WidgetMenuDashboardPengajuan(
                                  onTap: () => Navigator.pushNamed(context, Routes.approvalOrder),
                                  imgPath: 'product.png',
                                  title: 'Overdue / Overlimit',
                                  data: 0,
                                ),
                                loading: () => WidgetMenuDashboardPengajuan(
                                  onTap: () => Navigator.pushNamed(context, Routes.approvalOrder),
                                  imgPath: 'product.png',
                                  title: 'Overdue / Overlimit',
                                  data: 0,
                                ),
                              );
                            },
                          ),
                        ),
                        // Flexible(
                        //   child: WidgetMenuDashboard(
                        //     onTap: () => Navigator.pushNamed(context, Routes.reports),
                        //     imgPath: 'report.png',
                        //     title: 'Laporan',
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
      ],
    );
  }
}

class WidgetBanner extends StatelessWidget {
  const WidgetBanner({super.key, required this.data});

  final List<String> data;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: data.length,
      itemBuilder: (context, index, realIndex) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(data[index]),
              fit: BoxFit.fill,
            ),
          ),
        );
      },
      options: CarouselOptions(
        autoPlay: true,
        viewportFraction: 1.0,
        height: MediaQuery.of(context).size.height,
      ),
    );
  }
}

class WidgetMenuDashboard extends StatelessWidget {
  final Function() onTap;
  final String imgPath;
  final String title;
  const WidgetMenuDashboard({
    super.key,
    required this.onTap,
    required this.imgPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Image.asset(
              'assets/$imgPath',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black54,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetMenuDashboardPengajuan extends StatelessWidget {
  final Function() onTap;
  final String imgPath;
  final String title;
  final int data;

  const WidgetMenuDashboardPengajuan({
    super.key,
    required this.onTap,
    required this.imgPath,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Image.asset(
              'assets/$imgPath',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black54,
                child: data == 0
                    ? Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(width: 5),
                          b.Badge(
                            showBadge: data > 0,
                            badgeContent: Text(data.toString(), style: const TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
