import 'package:api/employee/model.dart';
import 'package:common/constant/constant.dart';
import 'package:courier/main.dart';
import 'package:courier/presentation/page/home/view_kelola.dart';
import 'package:courier/presentation/page/home/view_pengantaran.dart';
import 'package:courier/presentation/page/home/view_rute.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final indexStateProvider = StateProvider.autoDispose<int>((ref) {
  return 1;
});

final userStateProvider = StateProvider<Employee>((ref) {
  return const Employee();
});

class MapIcons extends Equatable {
  final BitmapDescriptor courier;
  final BitmapDescriptor customer;

  const MapIcons(this.courier, this.customer);

  @override
  List<Object?> get props => [courier, customer];
}

final mapIconsProvider = StateProvider<MapIcons>((ref) {
  return const MapIcons(BitmapDescriptor.defaultMarker, BitmapDescriptor.defaultMarker);
});

final getUserProvider = FutureProvider<Employee>((ref) async {
  final api = ref.read(apiProvider);
  final id = FirebaseAuth.instance.currentUser?.uid;
  final result = await api.employee.byId(id ?? '');
  ref.read(userStateProvider.notifier).update((state) => result);
  final courier = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/loc.png',
  );
  final customer = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/customer.png',
  );

  ref.read(mapIconsProvider.notifier).update((state) => MapIcons(courier, customer));
  return result;
});

class PageHome extends ConsumerWidget {
  PageHome({Key? key}) : super(key: key);
  final _page = [
    const ViewRute(),
    const ViewPengantaran(),
    // const ViewPackingList(),
    const ViewKelola(),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(indexStateProvider);
    final user = ref.watch(getUserProvider);
    return user.when(
      data: (data) => Scaffold(
        body: _page[res],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: res,
          onTap: (value) {
            ref.read(indexStateProvider.notifier).state = value;
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.map_outlined,
                ),
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_outlined,
                ),
                label: ''),
            // BottomNavigationBarItem(
            //     icon: Icon(
            //       Icons.list_alt_outlined,
            //     ),
            //     label: ''),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_outline,
                ),
                label: ''),
          ],
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(Dimens.px16),
          child: Center(child: Text('$error')),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }
}
