import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/presentation/pages/business/business_list_page.dart';
import 'package:sales/presentation/pages/order/order_page.dart';
import 'package:sales/presentation/pages/setting/setting_page.dart';

final _currentIndex = StateProvider<int>(
  (ref) {
    return 1;
  },
);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _page = [
    const BusinessListPage(),
    const OrderPage(),
    const SettingPage(),
  ];

  bool loading = true;
  @override
  void initState() {
    super.initState();
    initEmployee();
  }

  void initEmployee() async {
    try {
      setState(() {
        loading = true;
      });
      final id = ref.read(auth).currentUser?.uid;
      if (id != null) {
        final api = ref.read(apiProvider);
        await api.employee.byId(id).then((em) {
          return ref.read(employee.notifier).update((state) => em);
        });
        setState(() {
          loading = false;
        });
      }
      return;
    } catch (e) {
      logger.info(e);
      setState(() {
        loading = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = ref.watch(_currentIndex);
    return Scaffold(
      body: loading
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : _page[res],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: res,
        onTap: (index) => ref.read(_currentIndex.notifier).state = index,
        items: const [
          BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.article_outlined),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.home_outlined),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.person_outline),
          ),
        ],
        showUnselectedLabels: false,
        showSelectedLabels: false,
      ),
    );
  }
}
