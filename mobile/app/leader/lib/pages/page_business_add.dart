import 'dart:io';

import 'package:api/api.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/pages/view_business/legalitas.dart';
import 'package:leader/pages/view_business/pemilik.dart';
import 'package:leader/pages/view_business/pic.dart';
import 'package:leader/pages/view_business/usaha.dart';
import 'package:leader/storage.dart';

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
    usahaNama = '';
    shippingAddress = [];
    usahaAlamat = TextEditingController();
    shippingCount = TextEditingController();

    pemilikNik = TextEditingController();
    pemilikNama = TextEditingController();
    pemilikPhone = TextEditingController();
    pemilikEmail = TextEditingController();
    pemilikAlamat = TextEditingController();

    picNik = TextEditingController();
    picNama = TextEditingController();
    picPhone = TextEditingController();
    picEmail = TextEditingController();
    picAlamat = TextEditingController();

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

  @override
  void dispose() {
    super.dispose();

    // usahaNama.dispose();
    shippingCount.dispose();
    usahaAlamat.dispose();

    // Pemilik
    pemilikNik.dispose();
    pemilikNama.dispose();
    pemilikPhone.dispose();
    pemilikEmail.dispose();
    pemilikAlamat.dispose();

    // PIC
    picNik.dispose();
    picNama.dispose();
    picPhone.dispose();
    picEmail.dispose();
    picAlamat.dispose();
  }

  final AutoDisposeRef ref;

  // Profil Usaha
  File? fileUsaha;
  void changeName(String nama) => usahaNama = nama;
  late String usahaNama;
  late TextEditingController usahaAlamat;
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
      await Storages.instance.uploadPhoto(ref: ref, file: file);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sedang mengupload $name')));

      await for (final value in Storages.instance.taskEvents) {
        if (value.state == Storages.instance.error) {
          throw 'Gagagl upload file';
        }
        if (value.state == Storages.instance.success) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sukses mengupload $name')));
          break;
        }
      }
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<Customer> action(BuildContext context) async {
    ref.read(loadingStateProvider.notifier).update((_) => true);

    String usaha = '-';
    String ktp = '-';
    String ktpPic = '-';
    String tax = '-';
    final isSame = ref.read(isSameStateProvider);
    if (fileUsaha == null) throw 'Anda belum memilih foto usaha';
    if (fileKtp == null) throw 'Anda belum memilih foto ktp pemilik';
    if (!isSame && filePic == null) throw 'Anda belum memilih foto ktp pic';
    if (shippingAddress.isEmpty) throw 'Anda belum memilih alamat pengantaran';

    final reqC = ReqCustomer(
      phone: pemilikPhone.text,
      email: pemilikEmail.text,
      name: usahaNama,
    );
    final customer = await ref.read(apiProvider).customer.createByEmployee(reqC);
    usaha = Storages.instance.path(ref: 'customer/${customer.id}/', file: fileUsaha!);
    if (context.mounted) await uploadFile(fileUsaha!, usaha, 'Foto Usaha', context);
    ktp = Storages.instance.path(ref: 'private/customer/${customer.id}/', file: fileKtp!);
    if (context.mounted) await uploadFile(fileKtp!, ktp, 'Foto KTP', context);
    ktpPic = Storages.instance.path(ref: 'private/customer/${customer.id}/', file: filePic!);
    if (context.mounted) await uploadFile(filePic!, ktpPic, 'Foto KTP PIC', context);
    if (fileTax != null) {
      tax = Storages.instance.path(ref: 'private/customer/${customer.id}/', file: fileTax!);
      if (context.mounted) await uploadFile(fileTax!, tax, 'Foto Legalitas', context);
    }

    Branch branch;
    final emp = ref.watch(employeeStateProvider);
    final loc = emp.location;
    if (loc != null && loc.type == 2) {
      branch = await ref.read(apiProvider).branch.byId(loc.id);
    } else {
      branch = await ref.read(apiProvider).branch.near(lng: shippingAddress.first.lng, lat: shippingAddress.first.lat);
    }

    final priceList = await ref.read(apiProvider).priceList.find();

    final lastMonth = await ref.read(apiProvider).order.lastMonth(customer.id);
    final perMonth = await ref.read(apiProvider).order.perMonth(customer.id);

    final req = ReqApply(
      creditProposal: const Credit(),
      address: shippingAddress,
      customer: BusinessCustomer(
        id: customer.id,
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
      viewer: emp.roles,
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
    ref.read(loadingStateProvider.notifier).update((_) => false);
    return customer;
  }
}

class PageBusinessAdd extends HookConsumerWidget {
  const PageBusinessAdd({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choiceState = useState<int>(0);
    final loading = ref.watch(loadingStateProvider);
    final customer = ref.watch(customerStateProvider);
    final List<String> choice = ['Profil Usaha', 'Profil Pemilik', 'PIC', 'Legalitas'];

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
              ref.read(loadingStateProvider.notifier).update((_) => false);
              return Alerts.dialog(
                context,
                content: e.toString(),
              );
            },
          );
          return;
        }
        choiceState.value++;
        return;
      }
    }

    final title = choiceState.value != 3 ? 'Selanjutnya' : 'Ajukan';
    return Scaffold(
      appBar: AppBar(title: const Text('Bisnis')),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 12 / 100,
              child: ListView.separated(
                padding: const EdgeInsets.all(Dimens.px16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return ChoiceChip(
                    label: SizedBox(
                        width: MediaQuery.of(context).size.width * 35 / 100,
                        height: MediaQuery.of(context).size.height * 4.5 / 100,
                        child: Center(child: Text(choice[index]))),
                    selected: choiceState.value == index,
                    onSelected: (v) async {
                      if (ref.watch(formKeyProvider).currentState?.validate() == true) {
                        choiceState.value = index;
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemCount: choice.length,
              ),
            ),
            Expanded(child: view[choiceState.value]),
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
      ),
    );
  }
}
