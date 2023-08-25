import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:courier/main.dart';
import 'package:courier/main_controller.dart';
import 'package:courier/presentation/page/page_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

final rutesStateNotifier = StateNotifierProvider.autoDispose<RuteState, AsyncValue<List<PackingDestination>>>((ref) => RuteState(ref));

final mapController = StateProvider<GoogleMapController?>((_) => null);

class RuteState extends StateNotifier<AsyncValue<List<PackingDestination>>> {
  RuteState(this.ref) : super(const AsyncValue.loading()) {
    init();
  }
  final AutoDisposeRef ref;
  late Direction direction;
  late Address customer;

  void init() async {
    state = await AsyncValue.guard(() async {
      final result = await ref.read(apiProvider).delivery.packingListDestination();
      return result;
    });
    direction = const Direction();
    customer = const Address();
    return;
  }

  void getDirection(String ori, Address des) async {
    state = state;
    final result = await ref.read(apiProvider).maps.directions(oriLatLng: ori, desLatLng: '${des.lat},${des.lng}');
    direction = result.first;
    customer = des;
    state = state;
  }
}

class ViewRute extends ConsumerWidget {
  const ViewRute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rute = ref.watch(rutesStateNotifier);
    final notifier = ref.watch(rutesStateNotifier.notifier);
    final icon = ref.watch(mapIconsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rute Pengantaran')),
      body: rute.when(
        data: (data) {
          final location = ref.watch(locationStreamProvider);
          return Column(
            children: [
              Expanded(
                child: location.when(
                  data: (loc) => GoogleMap(
                    myLocationEnabled: true,
                    onMapCreated: (controller) {
                      ref.read(mapController.notifier).update((state) => controller);
                    },
                    initialCameraPosition: CameraPosition(target: LatLng(loc.latitude!, loc.longitude!), zoom: 14.0),
                    markers: {
                      location.when(
                        data: (l) => Marker(markerId: const MarkerId('courier'), position: LatLng(l.latitude!, l.longitude!), icon: icon.courier),
                        error: (error, stackTrace) => const Marker(markerId: MarkerId('courier')),
                        loading: () => const Marker(markerId: MarkerId('courier')),
                      ),
                      for (var d in data)
                        Marker(
                          icon: icon.customer,
                          onTap: () => notifier.getDirection(
                              '${location.value?.latitude},${location.value?.longitude}', Address(lngLat: d.customer.addressLngLat)),
                          markerId: MarkerId(d.customer.id),
                          position: LatLng(d.customer.lat, d.customer.lng),
                        )
                    },
                    polylines: {
                      Polyline(
                        polylineId: PolylineId(notifier.direction.overviewPolyline),
                        width: 3,
                        color: Colors.red,
                        points:
                            decodePolyline(notifier.direction.overviewPolyline).map((e) => LatLng(e.first.toDouble(), e.last.toDouble())).toList(),
                      ),
                    },
                  ),
                  error: (error, stackTrace) => Center(child: Text('$error')),
                  loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                child: notifier.direction.legs.isEmpty
                    ? Container()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Jarak ${notifier.direction.legs.first.distance}'),
                          Text('Perkiraan waktu tempuh ${notifier.direction.legs.first.duration}'),
                          Text(notifier.customer.name),
                        ],
                      ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Center(
          child: Text('$error'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }
}
