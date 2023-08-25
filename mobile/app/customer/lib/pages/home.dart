import 'package:api/api.dart' hide Location;
import 'package:common/widget/alert.dart';
import 'package:customer/main_controller.dart';
import 'package:customer/view_home/beranda.dart';
import 'package:customer/view_home/kelola.dart';
import 'package:customer/view_home/recipe.dart';
import 'package:customer/widget.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher_string.dart';

final keyboardProvider = Provider.autoDispose.family<FocusNode, BuildContext>((ref, c) {
  final FocusNode node = FocusNode();
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    node.addListener(() {
      bool hasFocus = node.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(c);
      } else {
        KeyboardOverlay.removerOverlay();
      }
    });
  }
  ref.onDispose(() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      node.dispose();
      KeyboardOverlay.removerOverlay();
    }
  });

  return node;
});

final homeProvider = StateProvider.autoDispose<int>((ref) {
  return 1;
});

final customerStateProvider = StateProvider<Customer>((_) {
  return const Customer();
});

final homeFutureProvider = FutureProvider.autoDispose<void>((ref) async {
  final id = FirebaseAuth.instance.currentUser?.uid;
  final user = await ref.read(apiProvider).customer.byId(id ?? '');
  ref.read(customerStateProvider.notifier).update((_) => user);
  Branch branch;
  final business = user.business;
  if (business != null) {
    branch = await ref.read(apiProvider).branch.byId(business.location.branchId);
  } else {
    final location = await Location.instance.getLocation();
    logger.info(location);
    branch = await ref.read(apiProvider).branch.near(lat: location.latitude ?? 0.0, lng: location.longitude ?? 0.0);
  }
  ref.read(branchProvider.notifier).update((_) => branch);
  return;
});

final homeStateNotifierProvider = StateNotifierProvider.autoDispose<HomeNotifier, AsyncValue<void>>((ref) {
  return HomeNotifier(ref);
});

class HomeNotifier extends StateNotifier<AsyncValue<void>> {
  HomeNotifier(this.ref) : super(const AsyncValue.loading()) {
    init();
  }

  final AutoDisposeRef ref;

  init() async {
    final result = await AsyncValue.guard<void>(() async {
      return;
    });

    state = result;
  }
}

class PageHome extends ConsumerWidget {
  const PageHome({
    super.key,
    this.listHome = const [
      ViewHomeRecipe(),
      ViewHomeBeranda(),
      ViewHomeKelola(),
    ],
  });

  final List<Widget> listHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeProvider);
    final home = ref.watch(homeFutureProvider);
    return home.when(
      data: (data) {
        final pending = ref.watch(orderPendingProvider);

        return Scaffold(
          body: listHome[index],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (value) {
              if (value == 2) {
                ref.invalidate(orderPendingProvider);
              }
              ref.read(homeProvider.notifier).update((state) => value);
            },
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: ''),
              const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
              BottomNavigationBarItem(
                icon: BadgeWidget(value: pending.whenOrNull(data: (d) => d.length.toString()) ?? '0', isChild: null),
                label: '',
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        if (error.toString().contains('Data tidak ditemukan')) {
          return Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Layanan kami belum tersedia di wilayah Anda.  Silakan hubungi kami di ',
                        ),
                        TextSpan(
                          text: 'info@dairyfood.co.id ',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              try {
                                const url = 'mailto:info@dairyfood.co.id?subject=Layanan belum tersedia';
                                if (await canLaunchUrlString(url)) {
                                  launchUrlString(url);
                                }
                                return;
                              } catch (e) {
                                Alerts.dialog(context, content: e.toString());
                                return;
                              }
                            },
                        ),
                        const TextSpan(text: 'atau '),
                        TextSpan(
                          text: '+62 877-7272-7388 ',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              try {
                                const url = 'https://wa.me/+6287772727388';
                                if (await canLaunchUrlString(url)) {
                                  launchUrlString(url, mode: LaunchMode.externalApplication);
                                }
                                return;
                              } catch (e) {
                                Alerts.dialog(context, content: e.toString());
                                return;
                              }
                            },
                        ),
                        const TextSpan(text: 'untuk info lebih lanjut.')
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      ref.invalidate(customerStateProvider);
                      ref.invalidate(branchProvider);
                      return;
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(error.toString()),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => FirebaseAuth.instance.signOut().then((_) {
                    ref.invalidate(branchProvider);
                    ref.invalidate(customerStateProvider);
                    return;
                  }),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
