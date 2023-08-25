import 'dart:io';

import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/presentation/pages/business/provider/business_create_provider.dart';
import 'package:sales/presentation/pages/business/provider/ktp_provider.dart';
import 'package:sales/presentation/widgets/app_scaffold_messenger.dart';

class BusinessTaxView extends ConsumerWidget {
  const BusinessTaxView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateRead = ref.read(businessCreateSatetNotifier.notifier);
    final imageRead = ref.read(imageParamProvider.notifier);
    final imageWatch = ref.watch(imageParamProvider);
    final reg = ref.watch(ktpRecognitionStateNotifierProvider.notifier);
    const List<String> days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      "Jum'At",
      'Sabtu',
      'Minggu'
    ];
    int intDays(String day) {
      switch (day) {
        case "Senin":
          return 1;
        case "Selasa":
          return 2;
        case "Rabu":
          return 3;
        case "kamis":
          return 4;
        case "Jum'At":
          return 5;
        case "Sabtu":
          return 6;
        case "Minggu":
          return 0;
        default:
          return 0;
      }
    }

    const List<String> state = ['Non PKP', 'PKP'];
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return ListView(
      padding: const EdgeInsets.all(Dimens.px16),
      children: [
        InkWell(
          onTap: () async {
            try {
              final result = await reg.getImage();
              File file = File(result.path);
              final npwp = await reg.setNpwpRec(file);
              if (npwp != "") {
                imageRead.setImageLegal(file);
              }
            } catch (e) {
              AppScaffoldMessanger.showSnackBar(
                  context: context, message: e.toString());
            }
          },
          child: Builder(builder: (context) {
            if (imageWatch.imageLegal.path.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.px12),
                child: Image.file(
                  File(imageWatch.imageLegal.path),
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
                    'Unggah foto NPWP (*jika ada)',
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
        AbsorbPointer(
          absorbing: imageWatch.imageLegal.path.isEmpty,
          child: DropdownButtonFormField(
            elevation: 0,
            decoration: const InputDecoration(
              labelText: 'Hari Tukar Faktur (*jika berlaku)',
              hintText: 'Pilih hari tukar faktur',
            ),
            items: days.map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              stateRead.setExachangeDay(intDays(value!));
            },
          ),
        ),
        const SizedBox(height: Dimens.px20),
        AbsorbPointer(
          absorbing: imageWatch.imageLegal.path.isEmpty,
          child: DropdownButtonFormField(
            elevation: 0,
            decoration: const InputDecoration(
              labelText: 'Status Pajak (*jika berlaku)',
              hintText: 'Pilih status pajak',
            ),
            items: state.map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              stateRead.setType(value == 'PKP' ? 1 : 0);
            },
          ),
        ),
      ],
    );
  }
}
