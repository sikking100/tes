import 'package:api/api.dart';
import 'package:badges/badges.dart' as b;
import 'package:common/constant/constant.dart';
import 'package:customer/cart.dart';
import 'package:customer/pages/home.dart';
import 'package:customer/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:common/function/function.dart';
import 'package:intl/intl.dart';

class CartWidget extends ConsumerWidget {
  const CartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartStateNotifier);
    return IconButton(
      onPressed: () => Navigator.pushNamed(context, Routes.cart),
      icon: b.Badge(
        showBadge: cart.isNotEmpty,
        position: b.BadgePosition.topEnd(top: -10),
        badgeContent: Text(cart.toSet().length.toString(), style: const TextStyle(color: Colors.white)),
        child: const Icon(
          Icons.shopping_cart_outlined,
        ),
      ),
    );
  }
}

class BadgeWidget extends StatelessWidget {
  final String value;
  final Widget? isChild;
  final double? end;
  final double? top;
  const BadgeWidget({
    Key? key,
    required this.value,
    this.isChild,
    this.end,
    this.top,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return b.Badge(
      badgeContent: Text(value, style: TextStyle(color: Colors.white, fontSize: value.length == 1 ? null : 12)),
      position: b.BadgePosition.topEnd(end: end ?? -15, top: top ?? -10),
      showBadge: int.parse(value) > 0,
      child: isChild ?? const Icon(Icons.person_outline),
      // badgeColor: Theme.of(context).colorScheme.secondary,
    );
  }
}

class WidgetProduct extends StatelessWidget {
  final double radius;
  final VoidCallback productDetail;
  final String name;
  final double padding;
  final Widget price;
  final String sizeProduct;
  final Widget image;
  final Widget buttonCart;
  final double padding10;
  final double padding6;
  final double padding16;
  final bool? isFront;
  final double? isFrontImageHeight;
  const WidgetProduct({
    Key? key,
    required this.radius,
    required this.productDetail,
    required this.name,
    required this.padding,
    required this.price,
    required this.sizeProduct,
    required this.image,
    required this.buttonCart,
    required this.padding10,
    required this.padding6,
    required this.padding16,
    this.isFront,
    this.isFrontImageHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return AspectRatio(
      aspectRatio: 1.0,
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        elevation: 1.5,
        shadowColor: theme.highlightColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: productDetail,
                child: Container(
                  padding: const EdgeInsets.all(Dimens.px16),
                  color: theme.highlightColor.withOpacity(0.3),
                  width: size.width,
                  height: isFrontImageHeight ?? 120,
                  child: image,
                ),
              ),
            ),
            SizedBox(height: padding10),
            SizedBox(
              height: 162,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: padding6),
                    Text(
                      sizeProduct,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: padding6),
                    price,
                    SizedBox(height: padding16),
                  ],
                ),
              ),
            ),
            // if (isFront == true) const Spacer(),
            buttonCart,
          ],
        ),
      ),
    );
  }
}

class TextPrice extends ConsumerWidget {
  final Product product;
  final bool? isFront;
  final bool isPromo;
  const TextPrice({Key? key, required this.product, this.isFront = true, this.isPromo = false}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartStateNotifier.notifier);
    final c = ref.watch(cartStateNotifier).where((element) {
      return element.productId == product.productId;
    });
    final customer = ref.watch(customerStateProvider);
    final price = product.kPrice(customer.business?.priceList.id);
    Widget dcText() {
      final disc = price.discount;
      if (price.discount.isEmpty) return Container();
      if (disc.length == 1) {
        if (c.length < disc.first.min || c.length > (disc.first.max ?? 0)) {
          return Column(
            crossAxisAlignment: isFront == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                '${c.length < (price.discount.first.min) ? 'Min Pembelian ${price.discount.first.min}' : 'Maks Pembelian ${(price.discount.first.max ?? '-')}'}  ',
                maxLines: 1,
              ),
              Text(
                'Disc ${price.discount.first.discount.currency()}',
                maxLines: 1,
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: isFront == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                'Min Pembelian ${c.isEmpty ? price.discount.first.min : cart.discount(product.productId).min}',
                style: const TextStyle(
                  color: Colors.red,
                ),
                maxLines: 1,
              ),
              Text(
                'Disc ${cart.discount(product.productId).discount.currency()}',
                style: const TextStyle(
                  color: Colors.red,
                ),
                maxLines: 1,
              ),
            ],
          );
        }
      } else {
        if (c.length < disc.first.min) {
          return Column(
            crossAxisAlignment: isFront == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                'Min Pembelian ${disc.first.min}',
                maxLines: 1,
              ),
              Text(
                'Disc ${disc.first.discount.currency()}',
                maxLines: 1,
              ),
            ],
          );
        }
        if (cart.discount(product.productId).discount != 0) {
          return Column(
            crossAxisAlignment: isFront == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                '${c.length == cart.discount(product.productId).min ? 'Min Pembelian ${cart.discount(product.productId).min}' : 'Maks Pembelian ${cart.discount(product.productId).max ?? '-'}'} ',
                style: const TextStyle(color: Colors.red),
                maxLines: 1,
              ),
              Text(
                'Disc ${cart.discount(product.productId).discount.currency()}',
                style: const TextStyle(color: Colors.red),
                maxLines: 1,
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: isFront == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              'Maks Pembelian ${disc.last.max ?? '-'}',
              maxLines: 1,
            ),
            Text(
              'Disc ${disc.last.discount.currency()}',
              maxLines: 1,
            ),
          ],
        );
      }
    }

    return Column(
      crossAxisAlignment: isFront == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        cart.discount(product.productId).discount == 0
            ? Text(
                price.price.currency(),
                maxLines: 1,
              )
            : Text(
                price.price.currency(),
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.black,
                  decorationThickness: Theme.of(context).brightness == Brightness.dark ? 3 : 1.5,
                  fontSize: 13,
                ),
                maxLines: 1,
              ),
        const SizedBox(height: 2),
        cart.discount(product.productId).discount == 0
            ? Container()
            : isFront == true
                ? Text(
                    (price.price - cart.discount(product.productId).discount).currency(),
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                    maxLines: 1,
                  )
                : Text(
                    (price.price - cart.discount(product.productId).discount).currency(),
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                    maxLines: 1,
                  ),
        dcText(),
      ],
    );
  }
}

class ButtonCart extends StatelessWidget {
  final bool isEmpty;
  final VoidCallback addProduct;
  final VoidCallback removeProduct;
  final double px10;
  final double px4;
  final Color buttonColor;
  final Widget qty;

  const ButtonCart({
    Key? key,
    required this.isEmpty,
    required this.addProduct,
    required this.px10,
    required this.px4,
    required this.buttonColor,
    required this.removeProduct,
    required this.qty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    if (isEmpty) {
      return Material(
        color: buttonColor,
        child: InkWell(
          onTap: addProduct,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: px10,
              vertical: px10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                SizedBox(width: px4),
                Flexible(
                  child: Text(
                    'keranjang',
                    maxLines: 1,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      width: size.width,
      color: theme.appBarTheme.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: buttonColor,
            child: InkWell(
              onTap: removeProduct,
              child: Padding(
                padding: EdgeInsets.all(px10),
                child: const Icon(Icons.remove, color: Colors.white),
              ),
            ),
          ),
          qty,
          Material(
            color: buttonColor,
            child: InkWell(
              onTap: addProduct,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WidgetDetailProduct extends StatelessWidget {
  final VoidCallback photoView;
  final Widget bannerImage;
  final Widget brandImage;
  final String name;
  final String size;
  final String category;
  final String description;
  final Widget plusMinusButton;
  final VoidCallback checkout;
  final String subtotal;
  final Widget textPrice;

  const WidgetDetailProduct({
    Key? key,
    required this.photoView,
    required this.bannerImage,
    required this.brandImage,
    required this.name,
    required this.size,
    required this.textPrice,
    required this.category,
    required this.description,
    required this.plusMinusButton,
    required this.checkout,
    required this.subtotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              GestureDetector(
                onTap: photoView,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xffdfdfdf),
                  child: bannerImage,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Dimens.px16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xffdfdfdf) : null,
                            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black12),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: brandImage,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              // const SizedBox(height: 10),
                              Text(size, style: const TextStyle(fontWeight: FontWeight.bold)),
                              // const SizedBox(height: 10),
                              textPrice,
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Kategori',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(category),
                    const SizedBox(height: 20),
                    const Text(
                      'Deskripsi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(description)
                  ],
                ),
              )
            ],
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                // width: MediaQuery.of(context).size.width * 45 / 100,
                padding: const EdgeInsets.only(
                  bottom: 40,
                ),
                child: plusMinusButton,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: checkout,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary, borderRadius: const BorderRadius.only(topRight: Radius.circular(30))),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Sub Total',
                          ),
                          const SizedBox(height: 5),
                          Text(
                            // ref.watch(cartStateNotifier.notifier).totalProduct(branch?.zone, business?.businessProfil.type, listPromo).currency(),
                            subtotal,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}

class WidgetPlusMinusButton extends StatelessWidget {
  const WidgetPlusMinusButton({Key? key, this.isCenter, required this.add, required this.remove, required this.qty, required this.qtys})
      : super(key: key);
  final bool? isCenter;
  final VoidCallback add;
  final VoidCallback remove;
  final Widget qty;
  final int qtys;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isCenter == true ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: remove,

          child: Icon(
            Icons.remove_circle,
            color: qtys > 0 ? null : const Color(0xffdfdfdf),
          ),
          // iconSize: 30,
        ),
        isCenter == false ? Container() : const Spacer(),
        qty,
        isCenter == false ? Container() : const Spacer(),
        GestureDetector(
          // padding: const EdgeInsets.only(left: 10),
          onTap: add,

          child: const Icon(
            Icons.add_circle,
            // color: Colors.green.shade800,
          ),
          //   constraints: const BoxConstraints(minWidth: 0),
          //   iconSize: 30,
          // ),
        )
      ],
    );
  }
}

class TextCount extends ConsumerStatefulWidget {
  const TextCount({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  ConsumerState<TextCount> createState() => _TextCountState();
}

class _TextCountState extends ConsumerState<TextCount> {
  late TextEditingController controller;
  FocusNode node = FocusNode();

  @override
  void initState() {
    super.initState();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      node.addListener(() {
        final isListen = node.hasFocus;
        if (isListen) {
          KeyboardOverlay.showOverlay(context);
        } else {
          KeyboardOverlay.removerOverlay();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    node.dispose();
    controller.dispose();
    KeyboardOverlay.removerOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(cartStateNotifier).where((element) => element.productId == widget.product.productId).toList().length;
    controller = TextEditingController(text: count.toString());
    return SizedBox(
      width: 40,
      child: TextField(
        onSubmitted: (value) async {
          ref.read(cartStateNotifier.notifier).clear(widget.product.productId);
          if (value != '0' && value.isNotEmpty) {
            for (var i = 0; i < int.parse(value); i++) {
              ref.read(cartStateNotifier.notifier).add(widget.product);
            }
          }
        },
        onChanged: (value) async {
          ref.read(cartStateNotifier.notifier).clear(widget.product.productId);
          if (controller.text != '0' && value.isNotEmpty) {
            for (var i = 0; i < int.parse(controller.text); i++) {
              ref.read(cartStateNotifier.notifier).add(widget.product);
            }
          }
        },
        controller: controller,
        style: Theme.of(context).textTheme.titleLarge,
        inputFormatters: [
          LengthLimitingTextInputFormatter(3),
          FilteringTextInputFormatter.digitsOnly,
        ],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        focusNode: node,
      ),
    );
  }
}

class KeyboardOverlay {
  static OverlayEntry? _overlayEntry;

  static showOverlay(BuildContext context) {
    if (_overlayEntry != null) return;
    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: const InputDoneView(),
        );
      },
    );
    overlayState.insert(_overlayEntry!);
  }

  static removerOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }
}

class InputDoneView extends StatelessWidget {
  const InputDoneView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: CupertinoColors.systemGrey6,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: CupertinoButton(
            padding: const EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
            onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: const Text(
              'Done',
              style: TextStyle(color: CupertinoColors.systemBlue),
            ),
          ),
        ),
      ),
    );
  }
}

class WidgetCheckoutTextTitle extends StatelessWidget {
  final String title;
  const WidgetCheckoutTextTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class WidgetCheckoutJadwalPengantaran extends StatelessWidget {
  final VoidCallback onTanggalTap;
  final DateTime? tanggal;
  const WidgetCheckoutJadwalPengantaran({
    Key? key,
    required this.onTanggalTap,
    required this.tanggal,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTanggalTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onBackground),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range_outlined),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                tanggal != null ? DateFormat('dd MMMM yyyy').format(tanggal!) : 'Pilih tanggal',
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetCheckoutCatatanPengantaran extends StatelessWidget {
  final TextEditingController textEditingController;
  const WidgetCheckoutCatatanPengantaran({Key? key, required this.textEditingController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      decoration: const InputDecoration(
        suffixIcon: Icon(Icons.edit_outlined),
        suffixIconConstraints: BoxConstraints(
          minWidth: 0,
        ),
        focusedBorder: UnderlineInputBorder(),
        contentPadding: EdgeInsets.only(bottom: 10),
        isCollapsed: true,
      ),
    );
  }
}

class WidgetCheckoutRincianPembayaran extends StatelessWidget {
  final String title;
  final String value;
  const WidgetCheckoutRincianPembayaran({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title), Text(value)]);
  }
}

class WidgetCheckoutOpsiPembayaran extends StatelessWidget {
  final int groupValue;
  final void Function(int?) onChanged;
  final String title;
  final int value;
  const WidgetCheckoutOpsiPembayaran({Key? key, required this.groupValue, required this.onChanged, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RadioListTile<int>(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
      title: Text(title),
      dense: true,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      visualDensity: const VisualDensity(
        horizontal: VisualDensity.minimumDensity,
        vertical: VisualDensity.minimumDensity,
      ),
    );
  }
}

class WidgetCheckoutProsesButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const WidgetCheckoutProsesButton({Key? key, required this.isLoading, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: MediaQuery.of(context).size.width * 15 / 100,
        width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 50 / 100),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: const BorderRadius.only(topRight: Radius.circular(30))),
        child: isLoading
            ? const Center(child: FittedBox(child: CircularProgressIndicator.adaptive(backgroundColor: Colors.white)))
            : const Text(
                'Proses',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}

Future<void> warning(BuildContext context, {String? title, required String errorText, required void Function()? onPressed}) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title ?? 'Oops'),
        content: Text(errorText),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: onPressed,
            child: const Text('Ya'),
          ),
        ],
      ),
    );
    return;
  }
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title ?? 'Oops'),
      content: Text(errorText),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.secondary,
            side: BorderSide(color: Theme.of(context).colorScheme.secondary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Tidak'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: onPressed,
          child: const Text('Ya'),
        ),
      ],
    ),
  );
  return;
}
