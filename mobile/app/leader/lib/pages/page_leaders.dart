import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';

class PageLeaders extends ConsumerStatefulWidget {
  const PageLeaders({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PageLeadersState();
}

class _PageLeadersState extends ConsumerState<PageLeaders> {
  late Api _api;
  static const _pageSize = 20;
  final PagingController<int, Employee> _pagingController = PagingController(
    firstPageKey: 1,
  );

  Future<void> _fetchLeader(int pageKey) async {
    try {
      final emp = ref.read(employeeStateProvider);
      String query = '';

      if (emp.roles == UserRoles.am) {
        final branch = await ref.read(apiProvider).branch.byId(emp.location?.id ?? 'id');
        query = '${UserRoles.rm},${emp.team},${branch.region?.id}';
      } else if (emp.roles == UserRoles.rm) {
        if (emp.team == Team.food) {
          query = '${UserRoles.nsm},${emp.team}';
        } else {
          query = '${UserRoles.gm},${emp.team}';
        }
      } else if (emp.roles == UserRoles.nsm) {
        query = '${UserRoles.gm},${emp.team}';
      } else if (emp.roles == UserRoles.gm) {
        query = '${UserRoles.direktur},${emp.team}';
      }

      final res = await _api.employee.find(
        num: pageKey,
        limit: _pageSize,
        query: query,
      );

      if (res.next == null) {
        _pagingController.appendLastPage(res.items);
      } else {
        _pagingController.appendPage(res.items, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    _api = ref.read(apiProvider);
    _pagingController.addPageRequestListener(
      (pageKey) => _fetchLeader(pageKey),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Leader'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => Future.sync(_pagingController.refresh),
        child: PagedListView<int, Employee>.separated(
          pagingController: _pagingController,
          padding: const EdgeInsets.all(16),
          builderDelegate: PagedChildBuilderDelegate<Employee>(
            noItemsFoundIndicatorBuilder: (context) => const Center(
              child: Text('Belum ada data'),
            ),
            itemBuilder: (context, item, index) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: AspectRatio(
                aspectRatio: 1,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(item.imageUrl),
                  radius: 30,
                ),
              ),
              title: Text(item.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${roleString(item.roles)} ${item.location?.name}'),
                ],
              ),
              // trailing: IconButton(
              //   onPressed: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => ReportAddPage(empTo: item),
              //     ),
              //   ),
              //   icon: const Icon(Icons.send_rounded),
              // ),
            ),
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
