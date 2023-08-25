import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:courier/common/constant.dart';
import 'package:courier/firebase/store.dart';
import 'package:courier/function/function.dart';
import 'package:courier/main.dart';
import 'package:courier/presentation/page/page_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:location/location.dart';
import 'package:api/api.dart' hide logger, Location;

final pickedProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});

final locationStreamInside = StreamProvider.autoDispose.family<LocationData, String>((_, arg) {
  Location.instance.changeSettings(distanceFilter: 100);

  final result = Location.instance.onLocationChanged;
  result.listen((event) {
    Store.instance.updateLoc(id: arg, loc: event);
  });
  return result;
});

// final polyLineProvider = StateProvider.autoDispose<Set<Polyline>>((ref) {
//   return {};
// });

// final directionProvider = StateProvider.autoDispose<Direction?>((ref) {
//   return null;
// });

// final getDirectionFuture = FutureProvider.autoDispose.family<Set<Polyline>, Delivery>((ref, arg) async {
//   final loc = await Location.instance.getLocation();
//   final result =
//       await ref.read(apiProvider).maps.directions(oriLatLng: "${loc.latitude},${loc.longitude}", desLatLng: "${arg.address.lat},${arg.address.lng}");
//   final employee = ref.watch(userStateProvider);

//   final delivery = arg.items.firstWhere((element) => (element.status == Status.deliver) && element.courier.id == employee.id);
//   await FirebaseFirestore.instance.doc('tracking/${delivery.id}').update({
//     "overviewPolyline": result.first.overviewPolyline,
//   });
//   final polyline = [
//     for (int i = 0; i < result.length; i++)
//       Polyline(
//         onTap: () {
//           ('message');
//           ref.read(pickedProvider.notifier).update((state) => i);
//         },
//         polylineId: PolylineId(i.toString()),
//         points: decodePolyline(result[i].overviewPolyline).map((e) => LatLng(e.first.toDouble(), e.last.toDouble())).toList(),
//         color: ref.watch(pickedProvider) == i ? scheme.secondary : Colors.grey,
//         width: ref.watch(pickedProvider) == i ? 3 : 1,
//       )
//   ];

//   ref.read(directionProvider.notifier).update((state) => result.first);
//   ref.read(polyLineProvider.notifier).update((state) => polyline.toSet());
//   return polyline.toSet();
// });

final rutePengantaranStateNotifierProvider =
    StateNotifierProvider.autoDispose.family<RutePengantaranNotifier, AsyncValue<List<Direction>>, Delivery>((ref, arg) {
  return RutePengantaranNotifier(ref, arg);
});

class RutePengantaranNotifier extends StateNotifier<AsyncValue<List<Direction>>> {
  RutePengantaranNotifier(this.ref, this.delivery) : super(const AsyncValue.loading()) {
    init();
  }

  final AutoDisposeRef ref;
  final Delivery delivery;

  void init() async {
    state = await AsyncValue.guard(() async {
      final curLoc = await Location.instance.getLocation();

      final result = await ref.read(apiProvider).maps.directions(
            oriLatLng: '${curLoc.latitude},${curLoc.longitude}',
            desLatLng: '${delivery.customer.lat},${delivery.customer.lng}',
          );
      await FirebaseFirestore.instance.doc('tracking/${delivery.id}').update({
        "overviewPolyline": result.first.overviewPolyline,
      });
      return result;
    });
  }
}

class PagePengantaran extends ConsumerWidget {
  final Delivery delivery;
  const PagePengantaran({Key? key, required this.delivery}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listDirection = ref.watch(rutePengantaranStateNotifierProvider(delivery));
    final pick = ref.watch(pickedProvider);
    final notifier = ref.read(rutePengantaranStateNotifierProvider(delivery).notifier);
    final stream = ref.watch(locationStreamInside(notifier.delivery.id));
    final icon = ref.watch(mapIconsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rute Pengantaran')),
      body: listDirection.when(
        data: (data) => Column(
          children: [
            Expanded(
              child: GoogleMap(
                // onMapCreated: (controller) => ref.read(mapController.notifier).update((state) => controller),
                initialCameraPosition: CameraPosition(target: LatLng(delivery.customer.lat, delivery.customer.lng), zoom: 13.0),
                markers: {
                  Marker(
                    markerId: const MarkerId('customer'),
                    position: LatLng(delivery.customer.lat, delivery.customer.lng),
                    icon: icon.customer,
                  ),
                  stream.when(
                    data: (loc) => Marker(
                      markerId: const MarkerId('courier'),
                      position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
                      icon: icon.courier,
                      rotation: loc.heading ?? 0.0,
                    ),
                    error: (error, stackTrace) => const Marker(markerId: MarkerId('courier')),
                    loading: () => const Marker(markerId: MarkerId('courier')),
                  ),
                },
                polylines: {
                  for (int i = 0; i < data.length; i++)
                    Polyline(
                      consumeTapEvents: true,
                      onTap: () async {
                        ref.read(pickedProvider.notifier).update((state) => i);
                        return FirebaseFirestore.instance.doc('tracking/${notifier.delivery.id}').update({
                          "overviewPolyline": data[i].overviewPolyline,
                        });
                      },
                      polylineId: PolylineId(i.toString()),
                      color: pick == i ? Colors.orange : Colors.grey,
                      width: 3,
                      points: decodePolyline(data[i].overviewPolyline).map((e) => LatLng(e.first.toDouble(), e.last.toDouble())).toList(),
                    ),
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: mPadding,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(
                      0,
                      -1,
                    ),
                    blurRadius: 1,
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(
                    20,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Jarak ${data[pick].legs.first.distance}, ${data[pick].legs.first.duration}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(MediaQuery.of(context).size.width, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      await launchs(delivery.customer.phone, true);
                    },
                    child: const Text('Hubungi'),
                  ),
                ],
              ),
            ),
          ],
        ),
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

// class PagePengantaran extends ConsumerStatefulWidget {
//   final Order delivery;
//   const PagePengantaran({Key? key, required this.delivery}) : super(key: key);

//   @override
//   ConsumerState<PagePengantaran> createState() => _PagePengantaranState();
// }

// class _PagePengantaranState extends ConsumerState<PagePengantaran> {
//   late final BitmapDescriptor courier;
//   late final BitmapDescriptor customer;
//   Set<Marker> markers(WidgetRef ref, LocationData loc, LatLng cus) {
//     return {
//       Marker(
//         markerId: MarkerId(widget.delivery.customer?.id ?? ''),
//         position: cus,
//         icon: customer,
//       ),
//       Marker(
//         markerId: const MarkerId('courier'),
//         position: LatLng(loc.latitude!, loc.longitude!),
//         rotation: loc.heading!,
//         icon: courier,
//       )
//     };
//   }

//   @override
//   void initState() {
//     super.initState();
//     initBitmap();
//   }

//   void initBitmap() async {
//     final courier = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(100, 100)),
//       'assets/loc.png',
//     );
//     final customer = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(100, 100)),
//       'assets/customer.png',
//     );

//     setState(() {
//       this.courier = courier;
//       this.customer = customer;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Rute Pengantaran'),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 ref.refresh(getDirectionFuture(widget.delivery.delivery));
//                 ref.refresh(directionProvider);
//                 ref.refresh(polyLineProvider);
//               },
//               icon: const Icon(Icons.refresh))
//         ],
//       ),
//       body: Consumer(
//         builder: (context, ref, child) {
//           final loc = ref.watch(locationStreamProvider);
//           final polyline = ref.watch(getDirectionFuture(widget.delivery.delivery));
//           final oldPolyline = ref.watch(polyLineProvider);
//           final direction = ref.watch(directionProvider);
//           final employee = ref.watch(userStateProvider);
//           final delivery = widget.delivery.delivery.items
//               .firstWhere((element) => (element.status == Status.loaded || element.status == Status.deliver) && element.courier.id == employee.id);
//           ref.watch(locationStreamInside(delivery));
//           return Column(
//             children: [
//               Expanded(
//                 child: loc.when(
//                   data: (data) => GoogleMap(
//                     onMapCreated: (controller) => ref.read(mapController.notifier).update((state) => controller),
//                     initialCameraPosition: loc.when(
//                       data: (data) {
//                         return CameraPosition(target: LatLng(data.latitude!, data.longitude!), zoom: 14.0);
//                       },
//                       error: (error, stackTrace) => CameraPosition(
//                         target: LatLng(widget.delivery.delivery.items.first.packingList.first.warehouse.address.lat,
//                             widget.delivery.delivery.items.first.packingList.first.warehouse.address.lng),
//                         zoom: 14.0,
//                       ),
//                       loading: () => CameraPosition(
//                         target: LatLng(widget.delivery.delivery.items.first.packingList.first.warehouse.address.lat,
//                             widget.delivery.delivery.items.first.packingList.first.warehouse.address.lng),
//                         zoom: 14.0,
//                       ),
//                     ),
//                     markers: loc.when(
//                       data: (data) => markers(ref, data, LatLng(widget.delivery.delivery.address.lat, widget.delivery.delivery.address.lng)),
//                       error: (error, stackTrace) => {},
//                       loading: () => {},
//                     ),
//                     polylines: polyline.when(data: (data) => data, error: (error, stackTrace) => {}, loading: () => oldPolyline),
//                   ),
//                   error: (error, stackTrace) => Center(
//                     child: Text('$error'),
//                   ),
//                   loading: () => const Center(
//                     child: CircularProgressIndicator.adaptive(),
//                   ),
//                 ),
//               ),
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 padding: mPadding,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).scaffoldBackgroundColor,
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.grey,
//                       offset: Offset(
//                         0,
//                         -1,
//                       ),
//                       blurRadius: 1,
//                     ),
//                   ],
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(
//                       20,
//                     ),
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (direction != null) Text('Jarak ${direction.legs.first.distance} Km, ${direction.legs.first.duration} Menit'),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: Size(MediaQuery.of(context).size.width, 48),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       onPressed: () async {
//                         await launchs(widget.delivery.customer?.phone ?? '', true);
//                       },
//                       child: const Text('Hubungi'),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class PagePengantaran extends ConsumerStatefulWidget {
//   final DestinationEntity destination;
//   final String idDelivery;
//   const PagePengantaran({Key? key, required this.destination, required this.idDelivery}) : super(key: key);

//   @override
//   ConsumerState<PagePengantaran> createState() => _PagePengantaranState();
// }

// class _PagePengantaranState extends ConsumerState<PagePengantaran> {
//   BitmapDescriptor kurir = BitmapDescriptor.defaultMarker;
//   BitmapDescriptor toko = BitmapDescriptor.defaultMarker;
//   late DirectionEntity directionEntity;
//   bool isLoading = true;
//   @override
//   void initState() {
//     super.initState();
//     loadMarkers();
//   }

//   void loadMarkers() async {
//     try {
//       log('message');
//       setState(() => isLoading = true);
//       final kurir = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration.empty,
//         'assets/loc.png',
//         mipmaps: false,
//       );
//       final toko = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration.empty,
//         'assets/customer.png',
//       );
//       this.kurir = kurir;
//       this.toko = toko;
//       final location = await Location.instance.getLocation();
//       final res = await ref.watch(
//           directionFuture(Props(LatLng(location.latitude ?? lat, location.longitude ?? lng), LatLng(widget.destination.lat, widget.destination.lng)))
//               .future);
//       directionEntity = res;
//       return;
//     } catch (e) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           content: Text(e.toString()),
//         ),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator.adaptive()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Rute Pengantaran'),
//       ),
//       body: Consumer(
//         builder: (context, ref, child) {
//           final loc = ref.watch(locationStreamProvider);
//           final direction = ref.watch(getDirectionFuture(widget.destination));
//           final rute = ref.watch(polylineProvider);
//           return loc.when(
//             data: (data) {
//               Store.instance.updateLoc(id: widget.idDelivery, loc: data);
//               (data);

//               return GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(loc.value?.latitude ?? lat, loc.value?.longitude ?? lng),
//                   zoom: 12.0,
//                 ),
//                 markers: {
//                   Marker(
//                     markerId: const MarkerId('kurir'),
//                     icon: kurir,
//                     rotation: loc.value?.heading ?? 0.0,
//                     position: LatLng(loc.value?.latitude ?? lat, loc.value?.longitude ?? lng),
//                   ),
//                   Marker(
//                     markerId: MarkerId(widget.destination.id),
//                     icon: toko,
//                     position: LatLng(widget.destination.lat, widget.destination.lng),
//                   ),
//                 },
//                 polylines: direction.when(data: (data) => data, error: (error, stackTrace) => {}, loading: () => rute),
//               );
//             },
//             error: (error, stackTrace) => Center(
//               child: Text('$error'),
//             ),
//             loading: () => const Center(
//               child: CircularProgressIndicator.adaptive(),
//             ),
//           );
//         },
//       ),
//       bottomSheet: BottomSheet(
//         onClosing: () {},
//         builder: (context) => 
// Container(
//           width: MediaQuery.of(context).size.width,
//           padding: mPadding,
//           decoration: BoxDecoration(
//             color: Theme.of(context).scaffoldBackgroundColor,
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.grey,
//                 offset: Offset(
//                   0,
//                   -1,
//                 ),
//                 blurRadius: 1,
//               ),
//             ],
//             borderRadius: const BorderRadius.vertical(
//               top: Radius.circular(
//                 20,
//               ),
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Jarak ${directionEntity.km} Km, ${directionEntity.duration.inMinutes} Menit'),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(MediaQuery.of(context).size.width, 48),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 onPressed: () async {
//                   await launchs(widget.destination.phone, true);
//                 },
//                 child: const Text('Hubungi'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
