import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:leader/function.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

final branchPickedProvider = StateProvider.autoDispose<String>((_) {
  return '';
});

final branchStateNotifierProvider = StateNotifierProvider.autoDispose.family<BranchNotifier, PagingController<int, Branch>, String>((ref, regionId) {
  return BranchNotifier(ref, regionId);
});

class BranchNotifier extends StateNotifier<PagingController<int, Branch>> {
  BranchNotifier(this.ref, this.regionId) : super(PagingController<int, Branch>(firstPageKey: 1)) {
    state.addPageRequestListener(pageListener);
  }

  void pageListener(int pageKey) async {
    try {
      final api = ref.read(apiProvider);
      final result = await api.branch.find(regionId: regionId, num: pageKey);
      if (result.items.length == 1) {
        ref.read(branchPickedProvider.notifier).update((state) => result.items.first.id);
      }
      if (result.next == null) {
        state.appendLastPage(result.items);
      } else {
        state.appendPage(result.items, result.next);
      }
      return;
    } catch (e) {
      state.error = '$e';
      return;
    }
  }

  final AutoDisposeRef ref;
  final String regionId;
}

class PagePerformance extends ConsumerWidget {
  final String? type;
  final String id;
  const PagePerformance({super.key, this.type = 'BRANCH', required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const title = 'Performa';
    if (type == 'REGION') {
      final controller = ref.watch(branchStateNotifierProvider(id));
      final pick = ref.watch(branchPickedProvider);
      return Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 8 / 100,
              child: PagedListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: Dimens.px16).copyWith(),
                scrollDirection: Axis.horizontal,
                pagingController: controller,
                builderDelegate: PagedChildBuilderDelegate<Branch>(
                  noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Tidak ada data')),
                  itemBuilder: (context, item, index) => ChoiceChip(
                    label: Container(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 30 / 100),
                      height: MediaQuery.of(context).size.height * 4.5 / 100,
                      child: Center(
                        child: Text(
                          item.name,
                        ),
                      ),
                    ),
                    selected: pick == item.id,
                    disabledColor: Colors.grey.shade100,
                    onSelected: (value) => ref.read(branchPickedProvider.notifier).update((state) => item.id),
                  ),
                ),
                separatorBuilder: (context, index) => const SizedBox(width: 10),
              ),
            ),
            Expanded(
              child: ViewPerformance(id: pick, topPadding: 0),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      body: ViewPerformance(id: id),
    );
  }
}

final dateRangePickerProvider = StateProvider.autoDispose<DateTimeRange>((ref) {
  return DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now());
});

final performanceProvider = FutureProvider.autoDispose.family<List<Performance>, String?>((ref, arg) async {
  final dates = ref.watch(dateRangePickerProvider);
  final api = ref.read(apiProvider);
  final employee = ref.read(employeeStateProvider);
  final result = await api.order.performance(startAt: dates.start, endAt: dates.end, team: employee.team, query: arg ?? employee.location?.id);
  final List<Performance> performance = [];
  final listCategory = await api.category.all();
  for (Category i in listCategory.where((element) => element.team == employee.team)) {
    Performance perf;
    if (result.isNotEmpty && result.map((e) => e.categoryId).contains(i.id)) {
      perf = result.firstWhere((element) => element.categoryId == i.id).copyWith(categoryTarget: i.target);
    } else {
      perf = Performance(
        qty: 0,
        branchId: '',
        branchName: '',
        categoryId: i.id,
        categoryName: i.name,
        categoryTarget: i.target,
        regionId: '',
        regionName: '',
      );
    }
    performance.add(perf);
  }
  return performance;
});

class ViewPerformance extends ConsumerWidget {
  final String? id;
  final double? topPadding;
  const ViewPerformance({super.key, this.id, this.topPadding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performance = ref.watch(performanceProvider(id));
    final dates = ref.watch(dateRangePickerProvider);
    return performance.when(
      data: (data) {
        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Belum ada performa"),
                const SizedBox(height: Dimens.px10),
                ElevatedButton(
                  onPressed: () {
                    showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2022),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                      initialDateRange: DateTimeRange(
                        start: dates.start,
                        end: dates.end,
                      ),
                      saveText: "Pilih",
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: scheme.error,
                            ),
                            buttonTheme: const ButtonThemeData(
                              textTheme: ButtonTextTheme.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    ).then(
                      (value) {
                        if (value != null) {
                          ref.read(dateRangePickerProvider.notifier).update((state) => value);
                        }
                      },
                    ).then((value) => ref.invalidate(performanceProvider));
                  },
                  child: const Text('Ganti tanggal'),
                )
              ],
            ),
          );
        }
        data.sort((a, b) => a.categoryName.compareTo(b.categoryName));
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.only(
                  top: topPadding ?? 16,
                  left: 16,
                  right: 16,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Branch: "),
                        Text(
                          data.first.branchName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Mulai: "),
                        Text(
                          dates.start.toCustomFormat,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Akhir: "),
                        Text(
                          dates.end.toCustomFormat,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Capaian: "),
                        Text(
                          "${data.map((e) => e.qty).reduce((value, element) => value + element)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            showDateRangePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(const Duration(days: 360)),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                              initialDateRange: DateTimeRange(
                                start: dates.start,
                                end: dates.end,
                              ),
                              saveText: "Pilih",
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: scheme.error,
                                    ),
                                    buttonTheme: const ButtonThemeData(
                                      textTheme: ButtonTextTheme.primary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            ).then(
                              (value) {
                                if (value != null) {
                                  ref.read(dateRangePickerProvider.notifier).update((state) => value);
                                }
                              },
                            );
                          },
                          child: const Text("Ganti Tanggal"),
                        ),
                        const SizedBox(width: 8),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (_) => BranchPage(
                        //           regionId: widget.regionId,
                        //         ),
                        //       ),
                        //     );
                        //   },
                        //   child: const Text("Lihat Cabang"),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: Dimens.px16),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,

                  legend: Legend(isVisible: true, position: LegendPosition.bottom),
                  primaryXAxis: CategoryAxis(
                    labelIntersectAction: AxisLabelIntersectAction.multipleRows,
                    // axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
                    //   axisLabelRenderArgs.text.split(' ').join('\n'),
                    //   axisLabelRenderArgs.textStyle,
                    // ),
                    // maximumLabelWidth: 50,
                    labelsExtent: 50,
                    labelAlignment: LabelAlignment.center,
                    // maximumLabels: 2,
                    // multiLevelLabelStyle: const MultiLevelLabelStyle(),
                  ),
                  primaryYAxis: NumericAxis(
                    isVisible: true,
                  ),
                  // zoomPanBehavior: ZoomPanBehavior(
                  //   zoomMode: ZoomMode.xy,
                  //   enablePinching: true,
                  //   enablePanning: true,
                  // ),
                  series: <BarSeries<Performance, String>>[
                    BarSeries(
                      sortingOrder: SortingOrder.descending,
                      sortFieldValueMapper: (datum, index) => datum.categoryName,
                      name: 'Pencapaian',
                      dataLabelMapper: (datum, index) => datum.categoryTarget == 0
                          ? '${datum.qty}(100 %)'
                          : '${datum.qty}(${(datum.qty / datum.categoryTarget * 100).toStringAsFixed(2)} %)',
                      dataSource: data.map((e) => e).toList(),
                      xValueMapper: (datum, index) => datum.categoryName,
                      yValueMapper: (datum, index) => datum.qty,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        labelAlignment: ChartDataLabelAlignment.outer,
                        // angle: 90,
                        // showCumulativeValues: true,
                      ),
                      color: Colors.green,
                      width: 0.8,
                      spacing: 0.0,
                    ),
                    BarSeries(
                      name: 'Target',
                      sortingOrder: SortingOrder.descending,
                      sortFieldValueMapper: (datum, index) => datum.categoryName,
                      dataLabelMapper: (datum, index) => datum.categoryTarget.toString(),
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        labelAlignment: ChartDataLabelAlignment.outer,
                        // angle: 90,
                      ),
                      dataSource: data,
                      xValueMapper: (datum, index) => datum.categoryName,
                      yValueMapper: (datum, index) => datum.categoryTarget,
                      color: Colors.red,
                      width: 0.8,
                      spacing: 0.0,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.builder(
                itemBuilder: (context, index) {
                  final item = data[index];
                  return ListTile(
                    shape: const UnderlineInputBorder(borderSide: BorderSide(width: 0.1)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Kategori: ${item.categoryName}"),
                        Text("Target Nasional: ${item.categoryTarget}"),
                        Text("Pencapaian Cabang: ${item.qty}"),
                        Text("Persentase: ${item.categoryTarget == 0 ? '100 %' : '${(item.qty / item.categoryTarget * 100).toStringAsFixed(2)} %'} "),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                },
                itemCount: data.length,
              ),
            )
          ],
        );
      },
      error: (error, stackTrace) => Center(child: Text('$error')),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}

// class PerformaRagionPage extends ConsumerStatefulWidget {
//   const PerformaRagionPage({super.key, required this.regionId});

//   final String regionId;

//   @override
//   ConsumerState<PerformaRagionPage> createState() => _PerformaRagionPageState();
// }

// class _PerformaRagionPageState extends ConsumerState<PerformaRagionPage> {
//   late Api api;
//   bool _isLoading = false;
//   List<Performance> _performa = [];
//   late DateTime startAt;
//   late DateTime endAt;

//   @override
//   void initState() {
//     api = ref.read(apiProvider);
//     setState(() {
//       startAt = DateTime.now().subtract(const Duration(days: 20));
//       endAt = DateTime.now();
//     });
//     _getPerforma(startAt, endAt);
//     super.initState();
//   }

//   void _getPerforma(DateTime start, DateTime end) async {
//     try {
//       final emp = ref.watch(employeeStateProvider);
//       setState(() => _isLoading = true);
//       final res = await api.order.performance(startAt: start, endAt: end, team: emp.team);
//       setState(() => _performa = res);
//     } catch (e) {
//       // showSnackBar(context, "Gagal mendapatkan performa");
//       Alerts.dialog(context, content: '$e');
//       return;
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _isLoading
//         ? const Center(child: CircularProgressIndicator.adaptive())
//         : _performa.isEmpty
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Belum ada performa"),
//                     const SizedBox(height: Dimens.px10),
//                     ElevatedButton(
//                       onPressed: () {
//                         final start = DateTime.now().subtract(const Duration(days: 20));
//                         final end = DateTime.now();
//                         setState(() {
//                           startAt = start;
//                           endAt = end;
//                         });
//                         _getPerforma(start, end);
//                       },
//                       child: const Icon(Icons.refresh),
//                     )
//                   ],
//                 ),
//               )
//             : SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.only(
//                         top: 16,
//                         left: 16,
//                         right: 16,
//                       ),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Branch: "),
//                               Text(
//                                 _performa.first.branchName,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Mulai: "),
//                               Text(
//                                 startAt.toCustomFormat,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Akhir: "),
//                               Text(
//                                 endAt.toCustomFormat,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Total Capaian: "),
//                               Text(
//                                 "${_performa.map((e) => e.qty).reduce((value, element) => value + element)}",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               OutlinedButton(
//                                 onPressed: () {
//                                   showDateRangePicker(
//                                     context: context,
//                                     firstDate: DateTime(2022),
//                                     lastDate: DateTime.now(),
//                                     initialDateRange: DateTimeRange(
//                                       start: startAt,
//                                       end: endAt,
//                                     ),
//                                     saveText: "Pilih",
//                                     builder: (context, child) {
//                                       return Theme(
//                                         data: ThemeData.light().copyWith(
//                                           colorScheme: ColorScheme.light(
//                                             primary: scheme.error,
//                                           ),
//                                           buttonTheme: const ButtonThemeData(
//                                             textTheme: ButtonTextTheme.primary,
//                                           ),
//                                         ),
//                                         child: child!,
//                                       );
//                                     },
//                                   ).then(
//                                     (value) {
//                                       if (value != null) {
//                                         setState(() {
//                                           startAt = value.start;
//                                           endAt = value.end;
//                                           _getPerforma(startAt, endAt);
//                                         });
//                                       }
//                                     },
//                                   );
//                                 },
//                                 child: const Text("Ganti Tanggal"),
//                               ),
//                               const SizedBox(width: 8),
//                               // ElevatedButton(
//                               //   onPressed: () {
//                               //     Navigator.push(
//                               //       context,
//                               //       MaterialPageRoute(
//                               //         builder: (_) => BranchPage(
//                               //           regionId: widget.regionId,
//                               //         ),
//                               //       ),
//                               //     );
//                               //   },
//                               //   child: const Text("Lihat Cabang"),
//                               // ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: Dimens.px16),
//                     SfCartesianChart(
//                       legend: Legend(isVisible: true, position: LegendPosition.bottom),
//                       primaryXAxis: CategoryAxis(),
//                       isTransposed: true,
//                       series: <BarSeries<Performance, String>>[
//                         BarSeries(
//                           name: 'Target',
//                           dataLabelMapper: (datum, index) => datum.categoryTarget.toString(),
//                           dataSource: _performa.map((e) => e).toList(),
//                           xValueMapper: (datum, index) => datum.categoryName,
//                           yValueMapper: (datum, index) => datum.categoryTarget,
//                           dataLabelSettings: const DataLabelSettings(
//                               isVisible: true, labelPosition: ChartDataLabelPosition.outside, labelAlignment: ChartDataLabelAlignment.outer),
//                           color: Colors.red,
//                         ),
//                         BarSeries(
//                           name: 'Pencapaian',
//                           dataLabelMapper: (datum, index) => datum.categoryTarget == 0
//                               ? '${datum.qty}\n100 %'
//                               : '${datum.qty}\n(${(datum.qty / datum.categoryTarget * 100).toStringAsFixed(2)} %)',
//                           dataSource: _performa.map((e) => e).toList(),
//                           xValueMapper: (datum, index) => datum.categoryName,
//                           yValueMapper: (datum, index) => datum.qty,
//                           dataLabelSettings: const DataLabelSettings(
//                               isVisible: true, labelPosition: ChartDataLabelPosition.outside, labelAlignment: ChartDataLabelAlignment.outer),
//                           color: Colors.green,
//                         ),
//                       ],
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(Dimens.px16),
//                       child: Column(
//                         children: [
//                           for (var item in _performa)
//                             ListTile(
//                               shape: const UnderlineInputBorder(borderSide: BorderSide(width: 0.1)),
//                               contentPadding: const EdgeInsets.symmetric(vertical: 10),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text("Kategori: ${item.categoryName}"),
//                                   Text("Target Nasional: ${item.categoryTarget}"),
//                                   Text("Pencapaian Cabang: ${item.qty}"),
//                                   Text(
//                                       "Persentase: ${item.categoryTarget == 0 ? '100 %' : '${(item.qty / item.categoryTarget * 100).toStringAsFixed(2)} %'} "),
//                                   const SizedBox(height: 10),
//                                 ],
//                               ),
//                             )
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               );
//   }
// }

// class PerformaBranchPage extends ConsumerStatefulWidget {
//   const PerformaBranchPage({super.key, required this.branchId});

//   final String branchId;

//   @override
//   ConsumerState<PerformaBranchPage> createState() => _PerformaBranchPageState();
// }

// class _PerformaBranchPageState extends ConsumerState<PerformaBranchPage> {
//   late Api api;
//   bool _isLoading = false;
//   List<Performance> _performa = [];
//   late DateTime startAt;
//   late DateTime endAt;

//   @override
//   void initState() {
//     api = ref.read(apiProvider);
//     setState(() {
//       startAt = DateTime.now().subtract(const Duration(days: 20));
//       endAt = DateTime.now();
//     });
//     _getPerforma(startAt, endAt);
//     super.initState();
//   }

//   void _getPerforma(DateTime start, DateTime end) async {
//     try {
//       setState(() => _isLoading = true);
//       final res = await api.order.performance(
//         startAt: start,
//         endAt: end,
//         team: ref.watch(employeeStateProvider).team,
//       );
//       setState(() => _performa = res);
//     } catch (e) {
//       // showSnackBar(context, "Gagal mendapatkan performa");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _isLoading
//         ? const Center(child: CircularProgressIndicator.adaptive())
//         : _performa.isEmpty
//             ? SizedBox.expand(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Belum ada performa"),
//                       const SizedBox(height: Dimens.px10),
//                       ElevatedButton(
//                         onPressed: () {
//                           final start = DateTime.now().subtract(const Duration(days: 20));
//                           final end = DateTime.now();
//                           setState(() {
//                             startAt = start;
//                             endAt = end;
//                           });
//                           _getPerforma(start, end);
//                         },
//                         child: const Icon(Icons.refresh),
//                       )
//                     ],
//                   ),
//                 ),
//               )
//             : SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.only(
//                         top: 16,
//                         left: 16,
//                         right: 16,
//                       ),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Cabang: "),
//                               Text(
//                                 _performa.first.branchName,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Mulai: "),
//                               Text(
//                                 startAt.toCustomFormat,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Akhir: "),
//                               Text(
//                                 endAt.toCustomFormat,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Target Nasional: "),
//                               Text(
//                                 "${_performa.map((e) => e.categoryTarget).reduce((value, element) => value + element)}",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Pencapaian Cabang: "),
//                               Text(
//                                 "${_performa.map((e) => e.qty).reduce((value, element) => value + element)}",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Persentase: "),
//                               Text(
//                                 "${(_performa.map((e) => e.qty).reduce((value, element) => value + element) / _performa.map((e) => e.categoryTarget).reduce((value, element) => value + element) * 100).toStringAsFixed(2)} %",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               OutlinedButton(
//                                 onPressed: () {
//                                   showDateRangePicker(
//                                     context: context,
//                                     firstDate: DateTime(2022),
//                                     lastDate: DateTime.now(),
//                                     initialDateRange: DateTimeRange(
//                                       start: startAt,
//                                       end: endAt,
//                                     ),
//                                     saveText: "Pilih",
//                                     builder: (context, child) {
//                                       return Theme(
//                                         data: ThemeData.light().copyWith(
//                                           colorScheme: ColorScheme.light(
//                                             primary: scheme.error,
//                                           ),
//                                           buttonTheme: const ButtonThemeData(
//                                             textTheme: ButtonTextTheme.primary,
//                                           ),
//                                         ),
//                                         child: child!,
//                                       );
//                                     },
//                                   ).then(
//                                     (value) {
//                                       if (value != null) {
//                                         setState(() {
//                                           startAt = value.start;
//                                           endAt = value.end;
//                                           _getPerforma(startAt, endAt);
//                                         });
//                                       }
//                                     },
//                                   );
//                                 },
//                                 child: const Text("Ganti Tanggal"),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: Dimens.px16),
//                     SfCartesianChart(
//                       legend: Legend(isVisible: true, position: LegendPosition.bottom),
//                       primaryXAxis: CategoryAxis(),
//                       isTransposed: true,
//                       series: <BarSeries<Performance, String>>[
//                         BarSeries(
//                           name: 'Target',
//                           dataLabelMapper: (datum, index) => datum.categoryTarget.toString(),
//                           dataSource: _performa.map((e) => e).toList(),
//                           xValueMapper: (datum, index) => datum.categoryName,
//                           yValueMapper: (datum, index) => datum.categoryTarget,
//                           dataLabelSettings: const DataLabelSettings(
//                               isVisible: true, labelPosition: ChartDataLabelPosition.outside, labelAlignment: ChartDataLabelAlignment.outer),
//                           color: Colors.red,
//                         ),
//                         BarSeries(
//                           name: 'Pencapaian',
//                           dataLabelMapper: (datum, index) => datum.categoryTarget == 0
//                               ? '${datum.qty}\n100 %'
//                               : '${datum.qty}\n(${(datum.qty / datum.categoryTarget * 100).toStringAsFixed(2)} %)',
//                           dataSource: _performa.map((e) => e).toList(),
//                           xValueMapper: (datum, index) => datum.categoryName,
//                           yValueMapper: (datum, index) => datum.qty,
//                           dataLabelSettings: const DataLabelSettings(
//                               isVisible: true, labelPosition: ChartDataLabelPosition.outside, labelAlignment: ChartDataLabelAlignment.outer),
//                           color: Colors.green,
//                         ),
//                       ],
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(Dimens.px16),
//                       child: Column(
//                         children: [
//                           for (var item in _performa)
//                             ListTile(
//                               shape: const UnderlineInputBorder(borderSide: BorderSide(width: 0.1)),
//                               contentPadding: const EdgeInsets.symmetric(vertical: 10),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Kategori: ${item.categoryName}",
//                                     style: const TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                   Text("Target Nasional: ${item.categoryTarget}"),
//                                   Text("Pencapaian Cabang: ${item.qty}"),
//                                   Text(
//                                       "Persentase: ${item.categoryTarget == 0 ? '100 %' : '${(item.qty / item.categoryTarget * 100).toStringAsFixed(2)} %'}"),
//                                 ],
//                               ),
//                             )
//                         ],
//                       ),
//                     ),

//                     // Expanded(
//                     //   child: ListView.separated(
//                     //     itemCount: _performa.length,
//                     //     padding: const EdgeInsets.all(16),
//                     //     itemBuilder: (context, index) {

//                     //     },
//                     //     separatorBuilder: (context, index) => const Divider(),
//                     //   ),
//                     // ),
//                     // Expanded(
//                     //   child: Padding(
//                     //     padding: const EdgeInsets.symmetric(horizontal: Dimens.px16).copyWith(bottom: Dimens.px16),
//                     //     child:
//                     // SfCartesianChart(
//                     //       legend: Legend(isVisible: true, position: LegendPosition.bottom),
//                     //       primaryXAxis: CategoryAxis(),
//                     //       isTransposed: true,
//                     //       series: <BarSeries<Performance, String>>[
//                     //         BarSeries(
//                     //           name: 'Target',
//                     //           dataLabelMapper: (datum, index) => datum.categoryTarget.toString(),
//                     //           dataSource: _performa.map((e) => e).toList(),
//                     //           xValueMapper: (datum, index) => datum.categoryName,
//                     //           yValueMapper: (datum, index) => datum.categoryTarget,
//                     //           dataLabelSettings: const DataLabelSettings(isVisible: true),
//                     //         ),
//                     //         BarSeries(
//                     //           name: 'Kuantitas',
//                     //           dataLabelMapper: (datum, index) => datum.qty.toString(),
//                     //           dataSource: _performa.map((e) => e).toList(),
//                     //           xValueMapper: (datum, index) => datum.categoryName,
//                     //           yValueMapper: (datum, index) => datum.qty,
//                     //           dataLabelSettings: const DataLabelSettings(isVisible: true),
//                     //         ),
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               );
//   }
// }
