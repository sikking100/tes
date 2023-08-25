import 'dart:io';

import 'package:api/api.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/config/functions.dart';
import 'package:sales/storage.dart';

final businessCreateSatetNotifier =
    StateNotifierProvider.autoDispose<BusinessCreateStateNotifier, ReqApply>(
  (ref) => BusinessCreateStateNotifier(),
);

final isSameAsOwnerProvider = StateProvider.autoDispose<bool>((_) {
  return false;
});

final isLoadingProvider = StateProvider.autoDispose<bool>((_) {
  return false;
});

final imageParamProvider =
    StateNotifierProvider.autoDispose<ImageParamStateNotifier, ImageParam>(
        (ref) {
  return ImageParamStateNotifier();
});

class ImageParam extends Equatable {
  final File imageBusiness;
  final File imageUser;
  final File imagePic;
  final File imageLegal;

  ImageParam({
    File? imageBusiness,
    File? imageUser,
    File? imagePic,
    File? imageLegal,
  })  : imageBusiness = imageBusiness ?? File(''),
        imageUser = imageUser ?? File(''),
        imagePic = imagePic ?? File(''),
        imageLegal = imageLegal ?? File('');

  @override
  List<Object> get props => [imageBusiness, imageUser, imagePic, imageLegal];

  ImageParam copyWith({
    File? imageBusiness,
    File? imageUser,
    File? imagePic,
    File? imageLegal,
  }) {
    return ImageParam(
      imageBusiness: imageBusiness ?? this.imageBusiness,
      imageUser: imageUser ?? this.imageUser,
      imagePic: imagePic ?? this.imagePic,
      imageLegal: imageLegal ?? this.imageLegal,
    );
  }
}

class ImageParamStateNotifier extends StateNotifier<ImageParam> {
  ImageParamStateNotifier() : super(ImageParam());

  setImageBusiness(File file) {
    state = state.copyWith(imageBusiness: file);
  }

  setImageUser(File file) {
    state = state.copyWith(imageUser: file);
  }

  setImagePic(File file) {
    state = state.copyWith(imagePic: file);
  }

  setImageLegal(File file) {
    state = state.copyWith(imageLegal: file);
  }
}

class BusinessCreateStateNotifier extends StateNotifier<ReqApply> {
  BusinessCreateStateNotifier() : super(const ReqApply());
  final businessName = TextEditingController();
  final businessOfficeAddress = TextEditingController();
  final businessShippingAddress = TextEditingController();
  //
  final cusNik = TextEditingController();
  final cusPhone = TextEditingController();
  final cusEmail = TextEditingController();
  //
  final picNik = TextEditingController();
  final picName = TextEditingController();
  final picPhone = TextEditingController();
  final picAddress = TextEditingController();
  final picEmail = TextEditingController();
  //
  bool isLoading = false;

  int? type;
  int? exChangeDay;

  setExachangeDay(int day) {
    exChangeDay = day;
  }

  setType(int t) {
    type = t;
  }

  isSame(WidgetRef ref, bool v) {
    ref.read(isSameAsOwnerProvider.notifier).update((state) => v);
    if (ref.watch(isSameAsOwnerProvider) == true) {
      ref
          .read(imageParamProvider.notifier)
          .setImagePic(ref.watch(imageParamProvider).imageUser);
      picNik.text = cusNik.text;
      picPhone.text = cusPhone.text;
      picEmail.text = cusEmail.text;
      picAddress.text = businessOfficeAddress.text;
    } else {
      ref.read(imageParamProvider.notifier).setImagePic(File(""));
      picNik.text = "";
      picName.text = "";
      picPhone.text = "";
      picAddress.text = "";
      picEmail.text = "";
    }
  }

  Future<void> uploadFile(File file, String ref) async {
    try {
      await Storage.instance.uploadPhoto(ref: ref, file: file);
      await for (final value in Storage.instance.taskEvents) {
        if (value.state == Storage.instance.error) {
          throw 'Gagagl upload file';
        }
        if (value.state == Storage.instance.success) {
          break;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  setState(ReqApply apply) {
    state = apply;
  }

  create(WidgetRef ref) async {
    String usaha = '-';
    String ktp = '-';
    String ktpPic = '-';
    String tax = '-';
    ref.read(isLoadingProvider.notifier).update((state) => true);
    final image = ref.watch(imageParamProvider);
    final api = ref.read(apiProvider);
    final emp = ref.watch(employee);
    try {
      await api.priceList.find().then(
        (priceList) async {
          if (priceList.isNotEmpty) {
            await api.branch.byId(emp.location!.id).then(
              (loc) async {
                if (loc.region != null) {
                  await ref.read(auth).currentUser?.getIdToken().then(
                    (fcmToken) async {
                      await api.customer
                          .createByEmployee(
                        ReqCustomer(
                          phone: cusPhone.text,
                          email: cusEmail.text,
                          name: businessName.text,
                        ),
                      )
                          .then(
                        (cus) async {
                          usaha = Storage.instance.path(
                              ref: 'customer/${cus.id}/',
                              file: image.imageBusiness);
                          ktp = Storage.instance.path(
                              ref: 'private/customer/${cus.id}/',
                              file: image.imageUser);
                          ktpPic = Storage.instance.path(
                              ref: 'private/customer/${cus.id}/',
                              file: image.imagePic);
                          if (image.imageLegal.path.isNotEmpty) {
                            tax = Storage.instance.path(
                                ref: 'private/customer/${cus.id}/',
                                file: image.imageLegal);
                          }

                          setState(
                            state.copyWith(
                              customer: state.customer.copyWith(
                                address: businessOfficeAddress.text,
                                idCardPath: ktp,
                                id: cus.id,
                              ),
                              location: Location(
                                branchId: loc.id,
                                branchName: loc.name,
                                regionId: loc.region?.id ?? "",
                                regionName: loc.region?.name ?? "",
                              ),
                              priceList: priceList.first,
                              pic: state.pic.copyWith(
                                idCardPath: ktpPic,
                                idCardNumber: picNik.text,
                                phone: phoneFormatToIndonesia(picPhone.text),
                                email: picEmail.text,
                                address: picAddress.text,
                              ),
                              creditProposal: const Credit(),
                              viewer: emp.roles,
                              tax: image.imageLegal.path.isEmpty
                                  ? null
                                  : Tax(
                                      legalityPath: tax,
                                      exchangeDay: exChangeDay!,
                                      type: type!,
                                    ),
                              transactionLastMonth: 0,
                              transactionPerMonth: 0,
                            ),
                          );
                          logger.info(state.toJson());
                          await api.apply.create(state).then(
                            (value) async {
                              await uploadFile(image.imageBusiness, usaha);
                              await uploadFile(image.imageUser, ktp);
                              await uploadFile(image.imagePic, ktpPic);
                              if (image.imageLegal.path.isNotEmpty ||
                                  image.imageLegal == File("")) {
                                await uploadFile(image.imageLegal, tax);
                              }
                              ref
                                  .read(isLoadingProvider.notifier)
                                  .update((state) => false);
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            );
          }
        },
      );
    } catch (e) {
      ref.read(isLoadingProvider.notifier).update((state) => false);
      rethrow;
    }
  }
}
