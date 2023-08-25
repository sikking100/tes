import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/presentation/pages/business/provider/business_create_provider.dart';

import 'package:sales/presentation/pages/business/view/business_cutomer_view.dart';
import 'package:sales/presentation/pages/business/view/business_pic_view.dart';
import 'package:sales/presentation/pages/business/view/business_profile_view.dart';
import 'package:sales/presentation/pages/business/view/business_tax_view.dart';
import 'package:sales/presentation/widgets/app_alert_dialog.dart';
import 'package:sales/presentation/widgets/app_scaffold_messenger.dart';

class BusinessCreatePage extends StatefulWidget {
  const BusinessCreatePage({super.key});

  @override
  State<BusinessCreatePage> createState() => _BusinessCreatePageState();
}

class _BusinessCreatePageState extends State<BusinessCreatePage> {
  final choice = ['Profil Usaha', 'Profil Pemilik', 'PIC', 'Legalitas'];
  int index = 0;
  ScrollController scrollController = ScrollController();
  final _businessKey = GlobalKey<FormState>();

  void onPageChanged(int index) {
    switch (index) {
      case 0:
        setPageIndex(index);
        break;
      case 1:
        setPageIndex(index);
        break;
      case 2:
        setPageIndex(index);
        break;
      case 3:
        setPageIndex(index);
        break;
      default:
    }
  }

  setPop() {
    if (index == 0) {
      AppActionDialog.show(
        context: context,
        title: "Yakin ingin keluar?",
        content: "Data bisnis akan terhapus!",
        isAction: true,
        onPressYes: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onPressNo: () => Navigator.pop(context),
      );
    }
    if (index > 0) {
      onPageChanged(index - 1);
    }
  }

  setPageIndex(int value) {
    setState(
      () {
        index = value;
        scrollController.animateTo(
          index * 100,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        setPop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buat Bisnis'),
        ),
        body: Column(
          children: [
            const SizedBox(height: Dimens.px12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.px12,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  if (index != i) {
                    return OutlinedButton(
                      onPressed: () => onPageChanged(i),
                      child: Text(choice[i]),
                    );
                  }
                  return ElevatedButton(
                    onPressed: () => onPageChanged(i),
                    child: Text(choice[i]),
                  );
                },
                separatorBuilder: (_, index) {
                  return const SizedBox(
                    width: Dimens.px10,
                  );
                },
                itemCount: choice.length,
              ),
            ),
            const SizedBox(height: Dimens.px12),
            Expanded(
              child: Form(
                key: _businessKey,
                child: IndexedStack(
                  index: index,
                  children: const [
                    BusinessProfileView(),
                    BusinessCustomerView(),
                    BusinessPicView(),
                    BusinessTaxView()
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Builder(
          builder: (context) {
            if (index != 3) {
              return Padding(
                padding: const EdgeInsets.all(Dimens.px16),
                child: ElevatedButton(
                  onPressed: () async {
                    onPageChanged(index + 1);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: Size(MediaQuery.of(context).size.width, 48),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Selanjutnya'),
                ),
              );
            }
            return Consumer(
              builder: (__, ref, _) {
                final stateRead =
                    ref.read(businessCreateSatetNotifier.notifier);
                final imageWatch = ref.watch(imageParamProvider);
                return Padding(
                  padding: const EdgeInsets.all(Dimens.px16),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (imageWatch.imageBusiness.path.isEmpty) {
                        AppScaffoldMessanger.showSnackBar(
                          context: context,
                          message: 'Oops! Foto Usaha tidak boleh kosong',
                        );
                        onPageChanged(0);
                      } else if (imageWatch.imageUser.path.isEmpty) {
                        AppScaffoldMessanger.showSnackBar(
                          context: context,
                          message: 'Oops! Foto KTP Pemilik tidak boleh kosong',
                        );
                        onPageChanged(1);
                      } else if (imageWatch.imagePic.path.isEmpty) {
                        AppScaffoldMessanger.showSnackBar(
                          context: context,
                          message: 'Oops! Foto KTP PIC tidak boleh kosong',
                        );
                        onPageChanged(2);
                      } else if (_businessKey.currentState!.validate()) {
                        try {
                          await stateRead.create(ref);
                          if (!mounted) return;
                          AppAlertDialog.show(
                            context: context,
                            title: "Yeaa!",
                            content:
                                "Buat bisnis berhasil, silakan tunggu konfirmasi dari admin.",
                            onPressYes: () {
                              index = 0;
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          );
                        } catch (e) {
                          ref
                              .read(isLoadingProvider.notifier)
                              .update((state) => false);
                          AppScaffoldMessanger.showSnackBar(
                            context: context,
                            message: e.toString(),
                          );
                        }
                      } else {
                        AppScaffoldMessanger.showSnackBar(
                          context: context,
                          message: 'Oops! Mohon lengkapi data',
                        );
                        onPageChanged(0);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: Size(MediaQuery.of(context).size.width, 48),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: ref.watch(isLoadingProvider)
                        ? const CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )
                        : const Text('Simpan'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
