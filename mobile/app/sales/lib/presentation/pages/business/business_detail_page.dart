import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/presentation/pages/business/provider/business_detail_provider.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/widgets/app_empty_widget.dart';
import 'package:sales/presentation/widgets/app_image_widget.dart';
import 'package:sales/storage.dart';

final getImageFirebase = FutureProvider.autoDispose
    .family<String, String>((_, arg) => Storage.instance.getImageUrl(arg));

class BusinessDetailPage extends ConsumerStatefulWidget {
  const BusinessDetailPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BusinessDetailPage> createState() => _BusinessDetailState();
}

class _BusinessDetailState extends ConsumerState<BusinessDetailPage> {
  final _scrollController = ScrollController();
  final _pageController = PageController();

  int _pageIndex = 0;

  void _onPageChanged(int index) {
    switch (index) {
      case 0:
        _pageController.jumpToPage(index);
        setState(() => _pageIndex = index);
        break;
      case 1:
        _pageController.jumpToPage(index);
        setState(() => _pageIndex = index);
        break;
      case 2:
        _pageController.jumpToPage(index);
        setState(() => _pageIndex = index);
        break;
      case 3:
        _pageController.jumpToPage(index);
        setState(() => _pageIndex = index);
        break;
      case 4:
        _pageController.jumpToPage(index);
        setState(() => _pageIndex = index);
        break;
      default:
    }
  }

  void _animateToIndex(int index) {
    _scrollController.animateTo(
      index * 100,
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cus = ref.watch(customerStateProvider);
    final List<String> listTitle = [
      if (cus.business != null) "TOP",
      "Profil Usaha",
      "Profil Pemilik",
      "PIC",
      "Legalitas"
    ];
    final List<Widget> listWidget = [
      if (cus.business != null) const _Paylater(),
      const _BusinessProfile(),
      const _BusinessCustomer(),
      const _BusinessPic(),
      const _BusinessLegal(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Bisnis'),
      ),
      body: Column(
        children: [
          const SizedBox(height: Dimens.px12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.px12,
              ),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (_pageIndex != index) {
                  return OutlinedButton(
                    onPressed: () => _onPageChanged(
                      index,
                    ),
                    child: Text(listTitle[index]),
                  );
                }
                return ElevatedButton(
                  onPressed: () => _onPageChanged(
                    index,
                  ),
                  child: Text(listTitle[index]),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  width: Dimens.px10,
                );
              },
              itemCount: listTitle.length,
            ),
          ),
          const SizedBox(height: Dimens.px12),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _pageIndex = value;
                  _animateToIndex(_pageIndex);
                });
              },
              children: listWidget,
            ),
          ),
        ],
      ),
    );
  }
}

class _Paylater extends ConsumerWidget {
  const _Paylater({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(businessDetailProvider);

    return value.when(
      error: (error, stackTrace) => Center(
        child: Column(
          children: [
            Text('$error'),
            ElevatedButton(
                onPressed: () => ref.invalidate(businessDetailProvider),
                child: const Text('Refresh'))
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      data: (data) => Container(
        padding: const EdgeInsets.all(Dimens.px16),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Total Tagihan'),
              trailing: Text((data.customer.business?.credit.used ?? 0)
                  .toInt()
                  .currency()),
              shape: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black45
                      : mTextfieldLoginColor,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Jangka Waktu Pembayaran'),
              trailing: Text('${data.customer.business?.credit.term} hari'),
              shape: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black45
                      : mTextfieldLoginColor,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Jangka Waktu Invoice'),
              trailing:
                  Text('${data.customer.business?.credit.termInvoice} hari'),
              shape: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black45
                      : mTextfieldLoginColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessProfile extends ConsumerWidget {
  const _BusinessProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(businessDetailProvider);
    final size = MediaQuery.of(context).size;
    return value.when(
      error: (error, stackTrace) => Center(
        child: Column(
          children: [
            Text('$error'),
            ElevatedButton(
                onPressed: () => ref.invalidate(businessDetailProvider),
                child: const Text('Refresh'))
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.all(Dimens.px16),
        children: [
          AppImagePrimary(
            isOnTap: true,
            imageUrl: data.apply?.customer.imageUrl ?? data.customer.imageUrl,
            height: size.height * 0.3,
            radius: Dimens.px12,
          ),
          const SizedBox(height: Dimens.px20),
          TextFormField(
            initialValue: data.customer.name,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Nama Usaha',
              hintText: 'Masukkan nama usaha',
            ),
          ),
          const SizedBox(height: Dimens.px20),
          TextFormField(
            initialValue: data.apply?.customer.address ??
                data.customer.business!.customer.address,
            enabled: false,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Alamat Usaha',
              hintText: 'Masukkan alamat usaha',
              suffixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: Dimens.px20),
          InkWell(
            onTap: () {
              _showAddress(context, data.customer.business!.address);
            },
            child: TextFormField(
              initialValue: data.apply?.customer.address.length.toString() ??
                  data.customer.business!.address.length.toString(),
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Alamat Pengantaran',
                hintText: 'Masukkan alamat pengantaran',
                suffixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showAddress(BuildContext context, List<BusinessAddress> address) {
    showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Dimens.px30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: Dimens.px20),
                  Text(
                    "Alamat Pengantaran",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: address.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Alamat ${index + 1}"),
                              Text(
                                address[index].name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BusinessCustomer extends ConsumerWidget {
  const _BusinessCustomer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(businessDetailProvider);
    final size = MediaQuery.of(context).size;
    return value.when(
      error: (error, stackTrace) => Center(
        child: Column(
          children: [
            Text('$error'),
            ElevatedButton(
                onPressed: () => ref.invalidate(businessDetailProvider),
                child: const Text('Refresh'))
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      data: (data) {
        final getImage = ref.watch(getImageFirebase(
            data.apply?.customer.idCardPath ??
                data.customer.business!.customer.idCardPath));
        return ListView(
          padding: const EdgeInsets.all(Dimens.px16),
          children: [
            AppImagePrimary(
              isOnTap: true,
              imageUrl: getImage.asData?.value ?? "",
              height: size.height * 0.3,
              radius: Dimens.px12,
            ),
            const SizedBox(height: Dimens.px20),
            TextFormField(
              initialValue: data.apply?.customer.idCardNumber ??
                  data.customer.business!.customer.idCardNumber,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'NIK',
                hintText: 'Masukkan NIK',
              ),
            ),
            const SizedBox(height: Dimens.px20),
            TextFormField(
              initialValue: data.apply?.customer.phone ?? data.customer.phone,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon Pemilik',
                hintText: 'Masukkan nomor telepon',
              ),
            ),
            const SizedBox(height: Dimens.px20),
            TextFormField(
              initialValue: data.apply?.customer.email ?? data.customer.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email Pemilik',
                hintText: 'Masukkan email pemilik',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BusinessPic extends ConsumerWidget {
  const _BusinessPic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(businessDetailProvider);
    final size = MediaQuery.of(context).size;
    return value.when(
      error: (error, stackTrace) => const Center(
        child: Text('Error'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      data: (data) {
        final getImage = ref.watch(getImageFirebase(
            data.apply?.pic.idCardPath ??
                data.customer.business!.pic.idCardPath));
        return ListView(
          padding: const EdgeInsets.all(Dimens.px16),
          children: [
            AppImagePrimary(
              isOnTap: true,
              imageUrl: getImage.asData?.value ?? "",
              height: size.height * 0.3,
              radius: Dimens.px12,
            ),
            const SizedBox(height: Dimens.px20),
            TextFormField(
              initialValue: data.apply?.pic.idCardNumber ??
                  data.customer.business!.pic.idCardNumber,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'NIK PIC',
                hintText: 'Masukkan NIK PIC',
              ),
            ),
            const SizedBox(height: Dimens.px20),
            TextFormField(
              initialValue:
                  data.apply?.pic.name ?? data.customer.business!.pic.name,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Nama PIC',
                hintText: 'Masukkan nama PIC',
              ),
            ),
            const SizedBox(height: Dimens.px20),
            TextFormField(
              initialValue: data.apply?.pic.address ??
                  data.customer.business!.pic.address,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Alamat PIC',
                hintText: 'Masukkan alamat PIC',
              ),
            ),
            const SizedBox(height: Dimens.px20),
            TextFormField(
              initialValue:
                  data.apply?.pic.phone ?? data.customer.business!.pic.phone,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon PIC',
                hintText: 'Masukkan nomor telepon PIC',
              ),
            ),
            const SizedBox(height: Dimens.px20),
            TextFormField(
              initialValue:
                  data.apply?.pic.email ?? data.customer.business!.pic.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email PIC',
                hintText: 'Masukkan email PIC',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BusinessLegal extends ConsumerWidget {
  const _BusinessLegal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String strDays(int? day) {
      switch (day) {
        case 1:
          return "Senin";
        case 2:
          return "Selasa";
        case 3:
          return "Rabu";
        case 4:
          return "kamis";
        case 5:
          return "Jum'At";
        case 6:
          return "Sabtu";
        case 0:
          return "Minggu";
        default:
          return "Minggu";
      }
    }

    final value = ref.watch(businessDetailProvider);
    final size = MediaQuery.of(context).size;
    return value.when(
      error: (error, stackTrace) => const Center(
        child: Text('Error'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      data: (data) {
        if (data.customer.business?.tax == null) {
          return const AppEmptyWidget(
              title: "Pelanggan tidak memiliki legalitas");
        }
        return ListView(
          padding: const EdgeInsets.all(Dimens.px16),
          children: [
            data.customer.business?.tax == null
                ? Container()
                : Consumer(
                    builder: (context, ref, child) {
                      final result = ref.watch(getImageFirebase(
                          data.customer.business?.tax?.legalityPath ?? ''));
                      return AppImagePrimary(
                        isOnTap: true,
                        imageUrl: result.when(
                          data: (i) => i,
                          error: (error, stackTrace) => '',
                          loading: () => '',
                        ),
                        height: size.height * 0.3,
                        radius: Dimens.px12,
                      );
                    },
                  ),
            const SizedBox(height: Dimens.px20),
            TextFormField(
              initialValue: strDays(data.apply?.tax?.exchangeDay ??
                  data.customer.business?.tax?.exchangeDay),
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Hari Tukar Faktur',
                hintText: 'Pilih hari tukar faktur',
              ),
            ),
            const SizedBox(height: Dimens.px20),
            TextFormField(
              initialValue:
                  data.customer.business?.tax?.type == 1 ? "PKP" : "NON PKP",
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Status Pajak',
                hintText: 'Pilih status pajak',
              ),
            ),
          ],
        );
      },
    );
  }
}
