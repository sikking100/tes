import 'package:courier/common/constant.dart';
import 'package:courier/common/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:url_launcher/url_launcher_string.dart';

final SimpleLogger logger = SimpleLogger()
  ..mode = LoggerMode.log
  ..setLevel(Level.INFO, includeCallerInfo: true);

Future<void> launchs(String value, [bool? isPhoneNumber]) async {
  try {
    if (isPhoneNumber != null && isPhoneNumber) {
      value = 'tel:$value';
    }
    if (await canLaunchUrlString(value)) {
      await launchUrlString(value);
      return;
    }
  } catch (e) {
    rethrow;
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter = NumberFormat.simpleCurrency(locale: 'id', decimalDigits: 0, name: '');

    String newText = formatter.format(value / 1);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

extension DateParsing on DateTime {
  String get parseDate {
    return DateFormat('dd MMMM yyyy').format(this);
  }

  String get parseTime {
    return DateFormat('HH:mm').format(this);
  }

  String get parseFull {
    final date = DateFormat('EEEE, dd MMMM yyyy', 'id').format(this);
    // final time = hour;
    // return '$date\n${orderingTime(time)}';
    return date;
  }
}

String orderingTime(int time) {
  if (time < 12) return 'Pagi (Sebelum jam 12 siang)';
  if (time > 16) return 'Sore (Diatas jam 16:00)';
  return 'Siang (Jam 12:00 - 16:00)';
}

String paymentString(String method) {
  switch (method) {
    case PaymentMethod.cod:
      return 'Pembayaran COD';
    case PaymentMethod.top:
      return 'Pembayaran TOP';

    default:
      return 'Pembayaran Transfer';
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
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}
