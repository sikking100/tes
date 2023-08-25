import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/argument.dart';
import 'package:leader/pages/page_business.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:leader/routes.dart';

class PageListRegion extends ConsumerWidget {
  const PageListRegion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagingController = ref.watch(regionBusinessNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Region')),
      body: PagedListView.separated(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<Region>(
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Tidak ada data')),
          itemBuilder: (context, item, index) => ListTile(
            title: Text(item.name),
            onTap: () => Navigator.pushNamed(context, Routes.performance, arguments: ArgPerformance(item.id, 'REGION')),
          ),
        ),
        separatorBuilder: (context, index) => const Divider(color: Colors.grey, thickness: .9),
      ),
    );
  }
}
