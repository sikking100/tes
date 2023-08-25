import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/argument.dart';
import 'package:leader/storage.dart';

final fbImageProvider = FutureProvider.autoDispose.family<String, String>((ref, arg) async {
  return await Storages.instance.getImageUrl(arg);
});

class PageBusinessDetail extends StatefulWidget {
  const PageBusinessDetail({super.key, required this.arg});

  final ArgBusinessDetail arg;

  @override
  State<PageBusinessDetail> createState() => _PageBusinessDetailState();
}

class _PageBusinessDetailState extends State<PageBusinessDetail> {
  final _scrollController = ScrollController();
  final _pageController = PageController();

  int _index = 0;

  void _animateToIndex(int index) {
    _scrollController.animateTo(
      index * 100,
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _changePage(int index) {
    setState(() {
      _index = index;
      _pageController.jumpToPage(index);
      _animateToIndex(index);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listTitle = widget.arg.apply != null
        ? ["Profil Usaha", "Profil Pemilik", "PIC", "Legalitas"]
        : ["Profil Usaha", "Profil Pemilik", "PIC", "Legalitas", "TOP"];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Detail"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              scrollDirection: Axis.horizontal,
              itemCount: listTitle.length,
              itemBuilder: (_, index) {
                final title = listTitle[index];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0.2,
                    backgroundColor: _index == index ? scheme.error : Colors.grey[300],
                    foregroundColor: _index == index ? Colors.white : Colors.black,
                  ),
                  onPressed: () => _changePage(index),
                  child: Text(title),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
            ),
          ),
          Expanded(
            child: PageView(
              onPageChanged: _changePage,
              controller: _pageController,
              children: widget.arg.apply != null
                  ? [
                      _businessProfile,
                      _ownerProfile,
                      _pic,
                      _legality,
                    ]
                  : [
                      _businessProfile,
                      _ownerProfile,
                      _pic,
                      _legality,
                      _payLater,
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get _businessProfile => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ImageChoiceWidget(
            imageUrl: widget.arg.customer != null ? widget.arg.customer!.imageUrl : widget.arg.apply!.customer.imageUrl,
            title: 'Foto tampak depan usaha',
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: widget.arg.customer != null ? widget.arg.customer!.name : widget.arg.apply!.customer.name,
            enabled: false,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Nama Usaha',
              hintText: 'Masukkan nama usaha',
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: TextEditingController(text: widget.arg.customer?.business?.customer.address ?? widget.arg.apply?.customer.address),
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 4,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Alamat Usaha',
              hintText: 'Masukkan alamat usaha',
              suffixIcon: IconButton(
                icon: Icon(Icons.location_on_outlined),
                onPressed: null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller:
                TextEditingController(text: widget.arg.customer?.business?.address.length.toString() ?? widget.arg.apply?.address.length.toString()),
            textInputAction: TextInputAction.done,
            maxLines: null,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Alamat Pengantaran',
              hintText: 'Masukkan alamat pengantaran',
              suffixIcon: IconButton(
                icon: Icon(Icons.location_on_outlined),
                onPressed: null,
              ),
            ),
          ),
        ],
      );

  Widget get _ownerProfile => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // _ImageChoiceWidget(
          //   imageUrl: widget.arg.customer != null ? widget.arg.customer!.imageUrl : widget.arg.apply!.customer.imageUrl,
          //   title: 'Foto KTP',
          // ),
          Consumer(
            builder: (context, ref, child) {
              final image =
                  ref.watch(fbImageProvider(widget.arg.customer?.business?.customer.idCardPath ?? widget.arg.apply?.customer.idCardPath ?? ''));
              return Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width,
                decoration: image.whenOrNull(
                  data: (data) => BoxDecoration(
                    color: theme.highlightColor,
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(data),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue:
                widget.arg.customer != null ? widget.arg.customer!.business?.customer.idCardNumber : widget.arg.apply!.customer.idCardNumber,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'NIK',
              hintText: 'Masukkan NIK',
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: widget.arg.customer != null ? widget.arg.customer!.phone : widget.arg.apply!.customer.phone,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Nomor Telepon',
              hintText: 'Masukkan nomor telepon',
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: widget.arg.customer != null ? widget.arg.customer!.email : widget.arg.apply!.customer.email,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Masukkan email',
            ),
          ),
        ],
      );

  Widget get _pic => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Consumer(
            builder: (context, ref, child) {
              final image = ref.watch(fbImageProvider(widget.arg.customer?.business?.pic.idCardPath ?? widget.arg.apply?.pic.idCardPath ?? ''));
              return Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width,
                decoration: image.whenOrNull(
                  data: (data) => BoxDecoration(
                    color: theme.highlightColor,
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(data),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: widget.arg.customer != null ? widget.arg.customer!.business!.pic.idCardNumber : widget.arg.apply!.pic.idCardNumber,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'NIK',
              hintText: 'Masukkan NIK',
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: widget.arg.customer != null ? widget.arg.customer!.business!.pic.name : widget.arg.apply!.pic.name,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Nama',
              hintText: 'Masukkan nama',
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: widget.arg.customer != null ? widget.arg.customer!.business!.pic.address : widget.arg.apply!.pic.address,
            enabled: false,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Alamat',
              hintText: 'Masukkan alamat',
              suffixIcon: IconButton(
                icon: Icon(Icons.location_on_outlined),
                onPressed: null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: widget.arg.customer != null ? widget.arg.customer!.business!.pic.phone : widget.arg.apply!.pic.phone,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Nomor Telepon',
              hintText: 'Masukkan nomor telepon',
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: widget.arg.customer != null ? widget.arg.customer!.business!.pic.email : widget.arg.apply!.pic.email,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Masukkan email',
            ),
          ),
        ],
      );

  Widget get _legality {
    (widget.arg.apply?.tax == null);
    // if (widget.arg.customer?.business?.tax == null) {
    //   return const Center(child: Text('Belum ada data'));
    // }
    // if (widget.arg.apply?.tax == null) {
    //   return const Center(child: Text('Belum ada data'));
    // }
    if (widget.arg.customer != null) {
      if (widget.arg.customer?.business?.tax == null) {
        return const Center(child: Text('Belum ada data'));
      }
    }

    if (widget.arg.apply != null) {
      if (widget.arg.apply?.tax == null) {
        return const Center(child: Text('Belum ada data'));
      }
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Consumer(
          builder: (context, ref, child) {
            final image = ref.watch(fbImageProvider(widget.arg.customer?.business?.tax?.legalityPath ?? widget.arg.apply?.tax?.legalityPath ?? ''));
            return Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              decoration: image.whenOrNull(
                data: (data) => BoxDecoration(
                  color: theme.highlightColor,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(data),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
        TextFormField(
          initialValue: widget.arg.customer != null
              ? widget.arg.customer?.business?.tax?.exchangeDay.toString()
              : widget.arg.apply!.tax?.exchangeDay.toString(),
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Hari Tukar Faktur (*jika berlaku)',
            hintText: 'Pilih hari tukar faktur',
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: widget.arg.customer != null
              ? widget.arg.customer?.business?.tax?.type == 0
                  ? 'PKP'
                  : 'Non PKP'
              : widget.arg.apply!.tax?.type == 0
                  ? 'PKP'
                  : 'Non PKP',
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Status Pajak (*jika berlaku)',
            hintText: 'Pilih status pajak',
          ),
        ),
      ],
    );
  }

  Widget get _payLater => ListView(
        children: [
          ListTile(
            title: const Text('Total Tagihan'),
            trailing: Text((widget.arg.customer?.business?.credit.used ?? 0).toInt().currency()),
            shape: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
              ),
            ),
          ),
          ListTile(
            title: const Text('Sisa Limit'),
            trailing:
                Text(((widget.arg.customer?.business?.credit.limit ?? 0) - (widget.arg.customer?.business?.credit.used ?? 0)).toInt().currency()),
            shape: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
              ),
            ),
          ),
          ListTile(
            title: const Text('Jangka Waktu Pembayaran'),
            trailing: Text('${widget.arg.customer?.business?.credit.term ?? widget.arg.apply?.creditProposal.term ?? 0} hari'),
            shape: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
              ),
            ),
          ),
          ListTile(
            title: const Text('Jangka Waktu Invoice'),
            trailing: Text('${widget.arg.customer?.business?.credit.termInvoice ?? widget.arg.apply?.creditProposal.termInvoice ?? 0} hari'),
            shape: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : mTextfieldLoginColor,
              ),
            ),
          ),
        ],
      );
}

class _ImageChoiceWidget extends StatelessWidget {
  const _ImageChoiceWidget({
    required this.imageUrl,
    required this.title,
  });

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.3,
      width: size.width,
      decoration: BoxDecoration(
        color: theme.highlightColor,
        borderRadius: BorderRadius.circular(16),
        image: imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl.isNotEmpty
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_rounded,
                  size: 80,
                  color: Theme.of(context).dividerColor,
                ),
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
    );
  }
}
