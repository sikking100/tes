import 'dart:io';

import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/constant/constant.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/presentation/widgets/app_alert_dialog.dart';
import 'package:sales/presentation/widgets/app_bottom_sheet.dart';
import 'package:sales/presentation/widgets/app_image_widget.dart';
import 'package:sales/presentation/widgets/app_scaffold_messenger.dart';
import 'package:sales/presentation/widgets/shimmer/app_shimmer_account_setting.dart';
import 'package:sales/storage.dart';

final loadingAccountPageProvider = StateProvider.autoDispose<bool>((_) {
  return false;
});

class StateProfile extends Equatable {
  final bool loading;
  final double progress;
  final Employee? user;
  final String error;

  const StateProfile(this.loading, this.progress, this.user, this.error);

  StateProfile copyWith(
      {bool? loading, double? progress, Employee? user, String? error}) {
    return StateProfile(loading ?? this.loading, progress ?? this.progress,
        user ?? this.user, error ?? this.error);
  }

  @override
  List<Object?> get props => [loading, progress, user, error];
}

final profileStateNotifierProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, StateProfile>((ref) {
  return ProfileNotifier(ref);
});

class ProfileNotifier extends StateNotifier<StateProfile> {
  ProfileNotifier(this.ref) : super(const StateProfile(false, 0.0, null, '')) {
    final result = ref.watch(employee.notifier).state;
    init(result);
  }

  init(Employee employee) {
    state = state.copyWith(user: employee);
    image = employee.imageUrl;
    name = TextEditingController(text: employee.name);
    phone = TextEditingController(text: employee.phone);
    email = TextEditingController(text: employee.email);
  }

  late AutoDisposeRef ref;
  late String? image;
  late TextEditingController name;
  late TextEditingController phone;
  late TextEditingController email;

  void save(BuildContext context) async {
    try {
      if (image == null &&
          email.text == state.user?.email &&
          phone.text == state.user?.phone &&
          name.text == state.user?.name) return;
      state = state.copyWith(loading: true);
      if (state.user != const Employee()) {
        final api = ref.read(apiProvider);
        await api.employee
            .update(
          req: ReqEmployee(
            email: email.text,
            name: name.text,
            phone: phone.text,
          ),
          id: state.user?.id ?? '',
        )
            .then(
          (value) {
            ref.read(employee.notifier).update((state) => value);
            state = state.copyWith(loading: false);
            state = state.copyWith(user: value);
            return AppActionDialog.show(
                context: context,
                title: "Yea",
                content: "Berhasil memperbarui profil",
                isAction: false);
          },
        );
      }
      return;
    } catch (e) {
      AppScaffoldMessanger.showSnackBar(
          context: context, message: e.toString());
      return;
    }
  }

  Future<void> onRefresh(BuildContext context) async {
    try {
      ref.read(loadingAccountPageProvider.notifier).update((state) => true);
      await Future.delayed(const Duration(seconds: 5));
      final em = await ref.read(apiProvider).employee.byId(state.user!.id);
      ref.read(employee.notifier).update((state) => em);
      init(em);
      ref.read(loadingAccountPageProvider.notifier).update((state) => false);
    } catch (e) {
      ref.read(loadingAccountPageProvider.notifier).update((state) => false);
      AppScaffoldMessanger.showSnackBar(
          context: context, message: e.toString());
    }
  }

  Future<void> uploadFile(BuildContext context, String source) async {
    try {
      final result = await ImagePicker().pickImage(
          source:
              source == "camera" ? ImageSource.camera : ImageSource.gallery);

      if (result != null) {
        ref.read(loadingAccountPageProvider.notifier).update((state) => true);
        final refPath = Storage.instance.path(
          ref: 'employee/${state.user!.id}/',
          file: File(result.path),
        );
        await Storage.instance
            .uploadPhoto(ref: refPath, file: File(result.path));
        await for (final value in Storage.instance.taskEvents) {
          if (value.state == Storage.instance.error) {
            throw 'Gagagl upload file';
          }
          if (value.state == Storage.instance.success) {
            await Future.delayed(const Duration(seconds: 5));
            final em =
                await ref.read(apiProvider).employee.byId(state.user!.id);
            ref.read(employee.notifier).update((state) => em);
            init(em);
            ref
                .read(loadingAccountPageProvider.notifier)
                .update((state) => false);
            break;
          }
        }
      }
    } catch (e) {
      ref.read(loadingAccountPageProvider.notifier).update((state) => false);
      AppScaffoldMessanger.showSnackBar(
          context: context, message: e.toString());
    }
  }
}

class SettingAccountPage extends ConsumerWidget {
  const SettingAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateWatch = ref.watch(profileStateNotifierProvider);
    final stateReadNotifier = ref.read(profileStateNotifierProvider.notifier);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Akun"),
      ),
      body: RefreshIndicator(
        color: theme.primaryColor,
        onRefresh: () => stateReadNotifier.onRefresh(context),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: body(
                  state: stateWatch,
                  bodyDefault: Column(
                    children: [
                      Center(
                        child: InkWell(
                          onTap: () {
                            AppBottomSheet.showBottomSheetImage(
                              context: context,
                              title: 'Pilih Foto',
                              onTapCamera: () {
                                Navigator.pop(context);
                                stateReadNotifier.uploadFile(context, "camera");
                              },
                              onTapGalery: () {
                                Navigator.pop(context);
                                stateReadNotifier.uploadFile(context, "galery");
                              },
                            );
                          },
                          child: Stack(
                            children: [
                              Builder(
                                builder: (context) {
                                  if (ref.watch(loadingAccountPageProvider) ==
                                      true) {
                                    return const CircleAvatar(
                                      radius: 60,
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return AppImagePrimary(
                                    isOnTap: true,
                                    imageUrl: stateWatch.user?.imageUrl ?? "",
                                    height: 120,
                                    width: 120,
                                    radius: 100,
                                  );
                                },
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: CircleAvatar(
                                  backgroundColor:
                                      theme.scaffoldBackgroundColor,
                                  child: CircleAvatar(
                                    radius: Dimens.px16,
                                    backgroundColor: theme.primaryColor,
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: theme.scaffoldBackgroundColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimens.px20),
                      TextFormField(
                        initialValue: stateWatch.user?.id,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'ID',
                        ),
                      ),
                      TextFormField(
                        initialValue: stateWatch.user?.roles == UserRoles.sales
                            ? "Sales"
                            : "",
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                        ),
                      ),
                      TextFormField(
                        initialValue: stateWatch.user!.location!.name,
                        minLines: 1,
                        maxLines: 5,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Cabang',
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          if (stateWatch.user == null) {
                            return TextFormField(
                              enabled: false,
                              decoration: const InputDecoration(
                                labelText: 'Tim',
                              ),
                            );
                          }
                          return TextFormField(
                            initialValue: stateWatch.user?.team == 1
                                ? "Food Service"
                                : "Retail",
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Tim',
                            ),
                          );
                        },
                      ),
                      TextFormField(
                          controller: stateReadNotifier.name,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            suffixIcon: Padding(
                              padding:
                                  EdgeInsetsDirectional.only(end: Dimens.px10),
                              child: Icon(Icons.edit_outlined),
                            ),
                          ),
                          onTap: () {}),
                      TextFormField(
                          controller: stateReadNotifier.phone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Telepon',
                            suffixIcon: Padding(
                              padding:
                                  EdgeInsetsDirectional.only(end: Dimens.px10),
                              child: Icon(Icons.edit_outlined),
                            ),
                          ),
                          onTap: () {}),
                      TextFormField(
                          controller: stateReadNotifier.email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            suffixIcon: Padding(
                              padding:
                                  EdgeInsetsDirectional.only(end: Dimens.px10),
                              child: Icon(Icons.edit_outlined),
                            ),
                          ),
                          onTap: () {}),
                      const SizedBox(height: Dimens.px20),
                      ElevatedButton(
                        onPressed: stateWatch.loading
                            ? null
                            : () => ref
                                .read(profileStateNotifierProvider.notifier)
                                .save(context),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize:
                              Size(MediaQuery.of(context).size.width, 48),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: stateWatch.loading
                            ? const Center(
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : const Text('Simpan'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget body({required StateProfile state, required Widget bodyDefault}) {
    if (state.error.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(state.error),
        ),
      );
    }
    if (state.user == null) {
      return const AppShimmerAccountSetting();
    }
    return bodyDefault;
  }
}
