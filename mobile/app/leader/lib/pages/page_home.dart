import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/view_home/view_activity.dart';
import 'package:leader/pages/view_home/view_dashboard.dart';
import 'package:leader/pages/view_home/view_kelola.dart';

final homeStateProvider = StateProvider.autoDispose<int>((_) {
  return 1;
});

final employeeStateProvider = StateProvider<Employee>((_) {
  return const Employee();
});

final getEmployeeFutureProvider = FutureProvider.autoDispose<Employee?>((ref) async {
  final id = FirebaseAuth.instance.currentUser?.uid;
  if (id == null) throw 'Tidak ada user';
  final result = await ref.read(apiProvider).employee.byId(id);
  ref.read(employeeStateProvider.notifier).update((_) => result);
  return result;
});

class PageHome extends ConsumerWidget {
  PageHome({super.key});
  final list = [const ViewActivity(), const ViewDashboard(), const ViewKelola()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeStateProvider);
    final loading = ref.watch(getEmployeeFutureProvider);
    return loading.when(
      data: (data) {
        if (data == null) {
          return const Scaffold(
            body: Center(
              child: Text('data null'),
            ),
          );
        }
        return Scaffold(
          body: list[index],
          bottomNavigationBar: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: index,
            onTap: (value) => ref.read(homeStateProvider.notifier).update((_) => value),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            ],
          ),
        );
      },
      error: (error, stackTrace) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(error.toString()),
                const SizedBox(height: Dimens.px10),
                ElevatedButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text('Keluar'))
              ],
            ),
          ),
        ),
      ),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
    );
  }
}
