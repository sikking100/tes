import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/presentation/pages/business/provider/business_create_provider.dart';
import 'package:sales/presentation/pages/maps/maps_page.dart';
import 'package:sales/presentation/widgets/app_button_widget.dart';

class BusinessListAddressView extends ConsumerWidget {
  const BusinessListAddressView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateRead = ref.read(businessCreateSatetNotifier.notifier);
    final stateWatch = ref.watch(businessCreateSatetNotifier);

    List<BusinessAddress> addressList = [];
    addressList.addAll(stateWatch.address);
    void showAddress(int i, BusinessAddress address) {
      final nameCtrl = TextEditingController(text: address.name);
      final theme = Theme.of(context);
      showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimens.px30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: Dimens.px20),
                  Form(
                    child: Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(Dimens.px12),
                        children: [
                          TextFormField(
                            autofocus: true,
                            textInputAction: TextInputAction.done,
                            controller: nameCtrl,
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.highlightColor,
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  Dimens.px30,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(
                                Dimens.px16,
                              ),
                            ),
                            onChanged: (value) {},
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(Dimens.px12),
                    child: Builder(
                      builder: (___) {
                        return AppButtonPrimary(
                          onPressed: () {
                            addressList[i] =
                                address.copyWith(name: nameCtrl.text);

                            stateRead.setState(
                              stateWatch.copyWith(
                                address: addressList,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          title: 'Simpan',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alamat pengantaran"),
        actions: [
          IconButton(
            onPressed: () async {
              final BusinessAddress? res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapsPage(
                    title: "Pilih Alamat Pengantaran",
                  ),
                ),
              );
              if (res != null) {
                addressList.add(res);
                stateRead.setState(
                  stateWatch.copyWith(
                    address: addressList,
                  ),
                );
                stateRead.businessShippingAddress.text =
                    addressList.length.toString();
              }
            },
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
        ],
      ),
      body: Column(
        children: List.generate(
          growable: true,
          addressList.length,
          (index) => Column(
            children: [
              ListTile(
                onTap: () {
                  showAddress(index, stateWatch.address[index]);
                },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Alamat ${index + 1}"),
                    Text(stateWatch.address[index].name),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    addressList.removeAt(index);
                    stateRead.setState(
                      stateWatch.copyWith(
                        address: addressList,
                      ),
                    );
                    stateRead.businessShippingAddress.text =
                        addressList.length.toString();
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.px16),
                child: Divider(
                  thickness: 1,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
