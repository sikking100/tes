import 'package:courier/presentation/page/home/view_dimuat.dart';
import 'package:courier/presentation/page/home/view_pending.dart';
import 'package:courier/presentation/page/home/view_proses.dart';
import 'package:courier/presentation/page/home/view_selesai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pengantaranStateProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});

class ViewPengantaran extends ConsumerWidget {
  const ViewPengantaran({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final index = ref.watch(pengantaranStateProvider);
        return DefaultTabController(
          length: 4,
          initialIndex: index,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Daftar Pengantaran'),
              bottom: TabBar(
                isScrollable: true,
                onTap: (value) => ref
                    .read(pengantaranStateProvider.notifier)
                    .update((state) => value),
                tabs: const [
                  Tab(
                    text: 'Menunggu',
                  ),
                  Tab(
                    text: 'Dimuat',
                  ),
                  Tab(
                    text: 'Mengantar',
                  ),
                  Tab(
                    text: 'Retur',
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                ViewPending(),
                ViewDimuat(),
                ViewProses(),
                ViewSelesai(),
              ],
            ),
          ),
        );
      },
    );
  }
}
