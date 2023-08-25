import 'dart:io';
import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales/presentation/pages/business/provider/business_create_provider.dart';
import 'package:sales/presentation/pages/business/view/business_list_address_view.dart';
import 'package:sales/presentation/pages/maps/maps_page.dart';
import 'package:sales/presentation/widgets/app_bottom_sheet.dart';

class BusinessProfileView extends ConsumerWidget {
  const BusinessProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateRead = ref.read(businessCreateSatetNotifier.notifier);
    final state = ref.watch(businessCreateSatetNotifier.notifier);
    final stateWatch = ref.watch(businessCreateSatetNotifier);
    final imageRead = ref.read(imageParamProvider.notifier);
    final imageWatch = ref.watch(imageParamProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return ListView(
      padding: const EdgeInsets.all(Dimens.px16),
      children: [
        InkWell(
          onTap: () {
            AppBottomSheet.showBottomSheetImage(
              context: context,
              title: 'Pilih Foto',
              onTapCamera: () async {
                Navigator.pop(context);
                final result =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (result != null) {
                  imageRead.setImageBusiness(File(result.path));
                }
              },
              onTapGalery: () async {
                Navigator.pop(context);
                final result =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (result != null) {
                  imageRead.setImageBusiness(File(result.path));
                }
              },
            );
          },
          child: Builder(builder: (context) {
            if (imageWatch.imageBusiness.path.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.px12),
                child: Image.file(
                  File(imageWatch.imageBusiness.path),
                  height: size.height * 0.3,
                  fit: BoxFit.cover,
                ),
              );
            }
            return Container(
              height: size.height * 0.3,
              decoration: BoxDecoration(
                color: theme.highlightColor,
                borderRadius: BorderRadius.circular(Dimens.px16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_rounded,
                    size: 80,
                    color: Theme.of(context).dividerColor,
                  ),
                  Text(
                    'Unggah foto tampak depan usaha',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: Dimens.px20),
        TextFormField(
          keyboardType: TextInputType.text,
          controller: stateRead.businessName,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nama Usaha',
            hintText: 'Masukkan nama usaha',
            suffixIcon: Icon(Icons.edit),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Nama usaha tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: Dimens.px20),
        TextFormField(
          controller: stateRead.businessOfficeAddress,
          readOnly: state.businessOfficeAddress.text == '' ? true : false,
          textInputAction: TextInputAction.done,
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Alamat Usaha',
            hintText: 'Masukkan alamat usaha',
            suffixIcon: IconButton(
              icon: const Icon(Icons.location_on_outlined),
              onPressed: () async {
                final BusinessAddress? res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapsPage(
                      title: "Pilih Alamat Usaha",
                    ),
                  ),
                );
                if (res != null) {
                  stateRead.setState(
                    stateWatch.copyWith(
                      customer: stateWatch.customer.copyWith(
                        address: res.name,
                      ),
                    ),
                  );
                  stateRead.businessOfficeAddress.text = res.name;
                }
              },
            ),
          ),
          onTap: state.businessOfficeAddress.text != ''
              ? () {}
              : () async {
                  final BusinessAddress? res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MapsPage(
                        title: "Pilih Alamat Usaha",
                      ),
                    ),
                  );
                  if (res != null) {
                    stateRead.setState(
                      stateWatch.copyWith(
                        customer:
                            stateWatch.customer.copyWith(address: res.name),
                      ),
                    );
                    stateRead.businessOfficeAddress.text = res.name;
                  }
                },
          onChanged: (value) {
            stateRead.setState(
              stateWatch.copyWith(
                customer: stateWatch.customer.copyWith(address: value),
              ),
            );
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Alamat usaha tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: Dimens.px20),
        TextFormField(
          controller: stateRead.businessShippingAddress,
          textInputAction: TextInputAction.done,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Alamat Pengantaran',
            hintText: 'Alamat Pengantaran',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_location_alt_outlined),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BusinessListAddressView(),
                  ),
                );
              },
            ),
          ),
          onTap: () {},
          validator: (value) {
            if (value!.isEmpty) {
              return 'Alamat pengantaran tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: Dimens.px20),
      ],
    );
  }
}
