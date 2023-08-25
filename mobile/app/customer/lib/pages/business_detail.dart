import 'dart:io';

import 'package:api/api.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:customer/argument.dart';
import 'package:customer/main_controller.dart';
import 'package:customer/pages/home.dart';
import 'package:customer/storage.dart';
import 'package:customer/view_business/legalitas.dart';
import 'package:customer/view_business/pay_later.dart';
import 'package:customer/view_business/pemilik.dart';
import 'package:customer/view_business/pic.dart';
import 'package:customer/view_business/usaha.dart';
import 'package:customer/view_home/beranda.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final loadingImageProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

class ModelBusinessDetail extends Equatable {
  final Apply? apply;
  final Customer customer;

  const ModelBusinessDetail({this.apply, required this.customer});

  ModelBusinessDetail copyWith({Apply? apply, Customer? customer}) =>
      ModelBusinessDetail(apply: apply ?? this.apply, customer: customer ?? this.customer);

  @override
  List<Object?> get props => [apply, customer];
}

const double upgradAccountHeight = 3.6;

final isSameStateProvider = StateProvider.autoDispose<bool>((_) => false);

final businessStateProvider = StateNotifierProvider.autoDispose<BusinessStateNotifier, AsyncValue<ModelBusinessDetail>>((ref) {
  return BusinessStateNotifier(ref);
});

class BusinessStateNotifier extends StateNotifier<AsyncValue<ModelBusinessDetail>> {
  BusinessStateNotifier(this.ref) : super(const AsyncValue.loading()) {
    customer = ref.watch(customerStateProvider);
    init();

    // usahaNama = TextEditingController(text: customer.business != null ? customer.name : '');
    usahaNama = customer.business != null ? customer.name : '';
    shippingAddress = customer.business != null ? customer.business!.address : [];
    usahaAlamat = TextEditingController(text: customer.business?.customer.address);
    shippingCount = TextEditingController(text: customer.business != null ? customer.business!.address.length.toString() : 0.toString());

    pemilikNik = TextEditingController(text: customer.business?.customer.idCardNumber);
    pemilikNama = TextEditingController(text: customer.name);
    pemilikPhone = TextEditingController(text: customer.phone);
    pemilikEmail = TextEditingController(text: customer.email);
    pemilikAlamat = TextEditingController();

    picNik = TextEditingController(text: customer.business?.pic.idCardNumber);
    picNama = TextEditingController(text: customer.business?.pic.name);
    picPhone = TextEditingController(text: customer.business?.pic.phone);
    picEmail = TextEditingController(text: customer.business?.pic.email);
    picAlamat = TextEditingController(text: customer.business?.pic.address);

    taxHari = customer.business?.tax?.exchangeDay;
    taxState = customer.business?.tax?.type;

    if (mounted) {
      ref.listen(isSameStateProvider, (previous, next) {
        if (next) {
          picPhone.text = pemilikPhone.text;
          picEmail.text = pemilikEmail.text;
          picNik.text = pemilikNik.text;
          filePic = fileKtp;
          picNama.text = pemilikNama.text;
          picAlamat.text = pemilikAlamat.text;
        } else {
          picPhone.clear();
          picEmail.clear();
          picNama.clear();
          picNik.clear();
          picAlamat.clear();
          filePic = null;
        }
      });
    }
  }
  final AutoDisposeRef ref;
  late Customer customer;

  void init() async {
    state = await AsyncValue.guard(() async {
      if (customer.business != null) {
        final res = await ref.read(apiProvider).customer.byId(customer.id);
        customer = res;
        taxHari = res.business?.tax?.exchangeDay;
        taxState = res.business?.tax?.type;
        return ModelBusinessDetail(apply: null, customer: res);
      }
      final result = await ref.read(apiProvider).apply.byId(customer.id);
      if (result.id.isEmpty) return ModelBusinessDetail(apply: null, customer: customer);
      return ModelBusinessDetail(apply: result, customer: customer);
    });
  }

  // Profil Usaha
  File? fileUsaha;

  void changeName(String nama) => usahaNama = nama;

  late String usahaNama;
  late final TextEditingController usahaAlamat;
  late List<BusinessAddress> shippingAddress;
  late final TextEditingController shippingCount;

  // Pemilik
  File? fileKtp;
  late final TextEditingController pemilikNik;
  late final TextEditingController pemilikNama;
  late final TextEditingController pemilikPhone;
  late final TextEditingController pemilikEmail;
  late final TextEditingController pemilikAlamat;

  // PIC
  File? filePic;
  late final TextEditingController picNik;
  late final TextEditingController picNama;
  late final TextEditingController picPhone;
  late final TextEditingController picEmail;
  late final TextEditingController picAlamat;

  // Legalitas
  File? fileTax;
  int? taxHari;
  int? taxState;

  setFileKtp(File file, {bool isNpwp = false, bool isKtpPic = false, isUsaha = false}) {
    ref.read(loadingImageProvider.notifier).update((_) => true);

    if (isNpwp == true) {
      fileTax = file;
    } else if (isKtpPic == true) {
      filePic = file;
    } else if (isUsaha) {
      fileUsaha = file;
    } else {
      fileKtp = file;
    }
    ref.read(loadingImageProvider.notifier).update((_) => false);
  }

  Future<void> uploadFile(File file, String ref, String name, BuildContext context) async {
    try {
      await Storage.instance.uploadPhoto(ref: ref, file: file);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sedang mengupload $name')));

      await for (final value in Storage.instance.taskEvents) {
        if (value.state == Storage.instance.error) {
          throw 'Gagal upload file';
        }
        if (value.state == Storage.instance.success) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sukses mengupload $name')));
          break;
        }
      }
      return;
    } catch (e) {
      rethrow;
    }
  }

  bool usahaEmpty() =>
      usahaNama.isEmpty ||
      // usahaJenis == null ||
      usahaAlamat.text.isEmpty ||
      shippingAddress.isEmpty;

  bool pemilikEmpty() => pemilikNik.text.isEmpty || pemilikPhone.text.isEmpty || pemilikEmail.text.isEmpty;

  bool picEmpty() => picNik.text.isEmpty || picNama.text.isEmpty || picPhone.text.isEmpty || picEmail.text.isEmpty || picAlamat.text.isEmpty;

  Future<Customer> action(BuildContext context) async {
    ref.read(loadingProvider.notifier).update((_) => true);

    if (customer.business != null) {
      String ktpPic = '';
      String tax = '';
      String usaha = '';

      if (fileUsaha != null) {
        usaha = Storage.instance.path(ref: 'customer/${customer.id}/', file: fileUsaha!);
        await uploadFile(fileUsaha!, usaha, 'Foto Usaha', context);
      }

      if (filePic != null) {
        ktpPic = Storage.instance.path(ref: 'private/customer/${customer.id}/', file: filePic!);
        if (context.mounted) await uploadFile(fileKtp!, ktpPic, 'Foto KTP PIC', context);
      }
      if (fileTax != null) {
        tax = Storage.instance.path(ref: 'private/customer/${customer.id}/', file: fileTax!);
        if (context.mounted) await uploadFile(fileTax!, tax, 'Foto Legalitas', context);
      }

      final req = UpdateBusiness(
        viewer: customer.business?.viewer ?? 0,
        location: customer.business?.location ?? const Location(),
        tax: customer.business?.tax == null && fileTax == null
            ? null
            : Tax(
                exchangeDay: taxHari!,
                legalityPath: tax.isEmpty ? (customer.business?.tax?.legalityPath ?? '') : tax,
                type: taxState!,
              ),
        address: shippingAddress,
        pic: BusinessPic(
          name: picNama.text,
          email: picEmail.text,
          phone: picPhone.text,
          address: picAlamat.text,
          idCardNumber: picNik.text,
          idCardPath: ktpPic.isEmpty ? customer.business!.pic.idCardPath : ktpPic,
        ),
      );
      await ref.read(apiProvider).customer.updateBusiness(id: customer.id, req: req);
      ref.read(loadingProvider.notifier).update((_) => false);
      return customer;
    }
    String usaha = '-';
    String ktp = '-';
    String ktpPic = '-';
    String tax = '-';
    final isSame = ref.read(isSameStateProvider);
    if (fileUsaha == null) throw 'Anda belum memilih foto usaha';
    if (fileKtp == null) throw 'Anda belum memilih foto ktp pemilik';
    if (!isSame && filePic == null) throw 'Anda belum memilih foto ktp pic';
    if (shippingAddress.isEmpty) throw 'Anda belum memilih alamat pengantaran';

    if (usahaEmpty()) throw 'Lengkapi profil usaha';
    if (pemilikEmpty()) throw 'Lengkapi profil pemilik';
    if (picEmpty()) throw 'Lengkapi pic';

    usaha = Storage.instance.path(ref: 'customer/${customer.id}/', file: fileUsaha!);
    await uploadFile(fileUsaha!, usaha, 'Foto Usaha', context);
    ktp = Storage.instance.path(ref: 'private/customer/${customer.id}/', file: fileKtp!);
    if (context.mounted) await uploadFile(fileKtp!, ktp, 'Foto KTP', context);
    ktpPic = Storage.instance.path(ref: 'private/customer/${customer.id}/', file: filePic!);
    if (context.mounted) await uploadFile(filePic!, ktpPic, 'Foto KTP PIC', context);
    if (fileTax != null) {
      tax = Storage.instance.path(ref: 'private/customer/${customer.id}/', file: fileTax!);
      if (context.mounted) await uploadFile(fileTax!, tax, 'Foto Legalitas', context);
    }

    final branch = ref.read(branchProvider);

    final priceList = await ref.read(apiProvider).priceList.find();

    final lastMonth = await ref.read(apiProvider).order.lastMonth(customer.id);
    final perMonth = await ref.read(apiProvider).order.perMonth(customer.id);
    final cus = await ref.read(apiProvider).customer.update(
          ReqCustomer(
            name: usahaNama,
            email: customer.email,
            phone: customer.phone,
          ),
        );

    final req = ReqApply(
      creditProposal: const Credit(),
      address: shippingAddress,
      customer: BusinessCustomer(
        id: cus.id,
        address: usahaAlamat.text,
        idCardNumber: pemilikNik.text,
        idCardPath: ktp,
      ),
      location: Location(
        branchId: branch.id,
        branchName: branch.name,
        regionId: branch.region?.id ?? '',
        regionName: branch.region?.name ?? '',
      ),
      priceList: priceList.first,
      transactionLastMonth: lastMonth.toInt(),
      transactionPerMonth: perMonth.toInt(),
      viewer: 0,
      pic: BusinessPic(
        email: picEmail.text,
        name: picNama.text,
        phone: picPhone.text,
        address: picAlamat.text,
        idCardNumber: picNik.text,
        idCardPath: ktpPic,
      ),
      tax: fileTax == null
          ? null
          : Tax(
              exchangeDay: taxHari ?? 0,
              type: taxState ?? 0,
              legalityPath: tax,
            ),
    );
    await ref.read(apiProvider).apply.create(req);
    ref.read(loadingProvider.notifier).update((_) => false);
    return customer;
  }
}

class PageBusinessDetail extends HookConsumerWidget {
  final ArgBusinessDetail arg;
  const PageBusinessDetail({super.key, required this.arg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessStateProvider);
    final scroll = useScrollController();
    final choiceState = useState<int>(0);
    final loading = ref.watch(loadingProvider);
    final customer = ref.watch(customerStateProvider);
    final List<String> choice = ['Profil Usaha', 'Profil Pemilik', 'PIC', 'Legalitas', if (customer.business != null) 'TOP'];

    final List<Widget> view = [
      Padding(
        padding: const EdgeInsets.all(Dimens.px16).copyWith(top: 0),
        child: const ViewBusinessUsaha(),
      ),
      Padding(
        padding: const EdgeInsets.all(Dimens.px16).copyWith(top: 0),
        child: const ViewBusinessPemilik(),
      ),
      Padding(
        padding: const EdgeInsets.all(Dimens.px16).copyWith(top: 0),
        child: const ViewBusinessPic(),
      ),
      Padding(
        padding: const EdgeInsets.all(Dimens.px16).copyWith(top: 0),
        child: const ViewBusinessLegalitas(),
      ),
      if (customer.business != null)
        Padding(
          padding: const EdgeInsets.all(Dimens.px16).copyWith(top: 0),
          child: const ViewBusinessPayLater(),
        )
    ];

    void onPressed() {
      if (ref.watch(formKeyProvider).currentState?.validate() == true) {
        if (choiceState.value == 3) {
          ref.read(businessStateProvider.notifier).action(context).then((value) {
            Navigator.pop(context);
            if (customer.business != null) {
              ref.read(customerStateProvider.notifier).update((state) => value);
              return Alerts.dialog(context, content: 'Sukses mengubah profil', title: 'Berhasil');
            }
            return Alerts.dialog(context, title: 'Berhasil', content: 'Pengajuan sedang diproses.');
          }).onError(
            (e, stackTrace) {
              ref.read(loadingProvider.notifier).update((_) => false);
              return Alerts.dialog(
                context,
                content: e.toString(),
              );
            },
          );
          return;
        }
        scroll.animateTo(
          ((scroll.position.viewportDimension + scroll.position.maxScrollExtent) * choiceState.value / 5),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
        choiceState.value++;
        return;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bisnis')),
      body: state.when(
        data: (data) {
          final apply = data.apply;
          (apply);
          if (data.customer.business == null && apply != null) {
            return Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(Dimens.px16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(StatusString.business(apply.status)),
                  const SizedBox(height: Dimens.px10),
                  ElevatedButton(onPressed: () => ref.invalidate(businessStateProvider), child: const Text('Refresh'))
                ],
              ),
            );
          }

          final title = choiceState.value != 3
              ? 'Selanjutnya'
              : data.customer.business != null
                  ? 'Perbarui'
                  : 'Ajukan';
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 12 / 100,
                  child: ListView.separated(
                    controller: scroll,
                    padding: const EdgeInsets.all(Dimens.px16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return ChoiceChip(
                        label: SizedBox(
                          width: MediaQuery.of(context).size.width * 35 / 100,
                          height: MediaQuery.of(context).size.height * 4.5 / 100,
                          child: Center(
                            child: Text(
                              choice[index],
                            ),
                          ),
                        ),
                        selected: choiceState.value == index,
                        onSelected: (v) async {
                          if (customer.business != null) {
                            choiceState.value = index;
                            scroll.animateTo(
                              ((scroll.position.viewportDimension + scroll.position.maxScrollExtent) * index / 4),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            );
                          }
                          if (ref.watch(formKeyProvider).currentState?.validate() == true) {
                            choiceState.value = index;
                            scroll.animateTo(
                              ((scroll.position.viewportDimension + scroll.position.maxScrollExtent) * index / 4),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemCount: choice.length,
                  ),
                ),
                Expanded(
                  child: view[choiceState.value],
                  // Consumer(
                  //   builder: (context, ref, child) => PageView(
                  //     controller: pageController,
                  //     onPageChanged: (value) {
                  //       choiceState.value = value;
                  //       scrollController.animateTo(
                  //         ((scrollController.position.viewportDimension + scrollController.position.maxScrollExtent) * value / 4),
                  //         duration: const Duration(milliseconds: 900),
                  //         curve: Curves.easeIn,
                  //       );
                  //     },
                  //     children: ,
                  //   ),
                  // ),
                ),
                choiceState.value == 4
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(Dimens.px16).copyWith(top: 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(MediaQuery.of(context).size.width, 48),
                          ),
                          onPressed: loading ? null : onPressed,
                          child: loading ? const CircularProgressIndicator.adaptive() : Text(title),
                        ),
                      ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => WidgetError(error: error.toString(), onPressed: () => ref.invalidate(businessStateProvider)),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
