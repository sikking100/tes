import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:api/common.dart';

const mPrimaryColor = Color(0xffdc143c);
const mTextfieldLoginColor = Color(0xffdfdfdf);
const mTextfieldLoginNumberColor = Color(0xffd4d4d4);
const mArrowIconColor = Color(0xff606060);
const mOnHoldColor = Color(0xffFF971A);
const mCallColor = Color(0xff3065AC);
const mOrderHistoryTitleColor = Color(0xff839700);

class StatusString {
  static String delivery(int status, [bool? isBatal]) {
    switch (status) {
      case 0:
        return 'Menunggu Persetujuan';
      case 1:
        return 'Pending';
      case 7:
        return 'Sedang diantar';
      case 9:
        if (isBatal == true) return 'Pengantaran Batal';
        return 'Pesanan Diterima';

      case 10:
        return 'Pengantaran Batal';
      default:
        return 'Pengantaran Diproses';
    }
  }

  static String business(int status) {
    switch (status) {
      case 0:
        return 'Mohon maaf pengajuan Bisnis Anda belum disetujui.  Hubungi kami melalui "Pusat Bantuan" untuk info selanjutnya.';

      case 1:
        return 'Sedang Diproses';

      case 2:
        return 'Pengajuan sedang diproses';

      case 3:
        return 'Menunggu persetujuan';

      default:
        return 'Disetujui';
    }
  }

  static String approval(int status) {
    // switch (status) {
    //   case Status.intReject:
    //     return 'Mohon maaf pengajuan Pay Later Anda belum disetujui.  Hubungi kami melalui "Pusat Bantuan" untuk info selanjutnya.';
    //   case Status.intPending:
    //     return 'Sedang Diproses';
    //   case Status.intWaitingApprove:
    //     return 'Menunggu Persetujuan';
    //   default:
    return 'Disetujui';
    // }
  }

  static String invoice(int status, [int? methodPayment]) {
    switch (status) {
      case 4:
        return 'Kedaluwarsa';
      case 1:
        return 'Pending';
      case 0:
        return 'Menunggu persetujuan';
      case 3:
        if (methodPayment == PaymentMethod.trf) return 'Lunas';
        return 'Terbayar';
      default:
        return 'Menunggu Pembayaran';
    }
  }

  static String order(int status) {
    switch (status) {
      case 0:
        return 'Pending';

      case 1:
        return 'Selesai';

      case 2:
        return 'Batal';

      default:
        return 'Pesanan Diproses';
    }
  }

  static String orderApply(int status) {
    switch (status) {
      case 1:
        return 'Menunggu Persetujuan';
      case 3:
        return 'Ditolak';
      case 2:
        return 'Disetujui';
      default:
        return 'Pending';
    }
  }
}

String paymentMethodString(int method) {
  switch (method) {
    case 0:
      return 'Cash On Delivery';
    case 1:
      return 'Term Of Payment';
    default:
      return 'Transfer';
  }
}

String teamString(int team) {
  switch (team) {
    case Team.food:
      return 'Food Service';
    case Team.retail:
      return 'Retail';
    default:
      return 'Default';
  }
}

String roleString(int role, {int? team}) {
  switch (role) {
    case 1:
      return 'System Admin';
    case 2:
    case 6:
      return 'Finance Admin';
    case 3:
    case 7:
      return 'Sales Admin';
    case 4:
    case 8:
      return 'Warehouse Admin';
    case 5:
      return 'Branch Admin';
    case UserRoles.direktur:
      return 'Direktur';
    case UserRoles.gm:
      return 'General Manager';
    case UserRoles.nsm:
      return 'National Sales Manager';

    case UserRoles.rm:
      return 'Regional Manager';

    case UserRoles.am:
      return 'Area Manager';

    case UserRoles.sales:
      if (team != null) return 'Sales ${teamString(team)}';
      return 'Sales';

    case UserRoles.courier:
      return 'Courier';

    default:
      return 'Customer';
  }
}

extension DateParse on DateTime {
  String get fullDate => intl.DateFormat('EEEE, dd MMMM yyyy', 'id').format(this);
  String get fullDateTime => intl.DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'id').format(this);

  String get date {
    final date = intl.DateFormat('dd MMMM yyyy', 'id').format(this);
    return date;
  }
}

extension DoubleParsing on double {
  String currency() {
    return intl.NumberFormat.currency(symbol: 'Rp', locale: 'id', decimalDigits: 2).format(this);
  }

  String currencyWithoutRp() {
    return intl.NumberFormat.currency(symbol: '', locale: 'id', decimalDigits: 2).format(this);
  }

  String currencyWithoutRpDoubleZero() {
    return intl.NumberFormat.currency(symbol: '', locale: 'id', decimalDigits: 0).format(this);
  }
}

extension NumberParsing on int {
  String currency() {
    return intl.NumberFormat.currency(symbol: 'Rp', locale: 'id', decimalDigits: 0).format(this);
  }

  String currencyWithoutRp() {
    return intl.NumberFormat.currency(symbol: '', locale: 'id', decimalDigits: 0).format(this);
  }
}

extension CaseParsing on String {
  String get firstLetter {
    return toLowerCase().replaceFirst(toLowerCase()[0], this[0].toUpperCase());
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter = intl.NumberFormat.simpleCurrency(locale: 'id', decimalDigits: 0, name: '');

    String newText = formatter.format(value / 1);

    return newValue.copyWith(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }
}

String taxStateString(int state) {
  switch (state) {
    case 1:
      return 'PKP';

    default:
      return 'NON PKP';
  }
}

String taxExchangeDayString(int day) {
  switch (day) {
    case 1:
      return 'Senin';
    case 2:
      return 'Selasa';
    case 3:
      return 'Rabu';
    case 4:
      return 'Kamis';
    case 5:
      return "Jum'At";
    case 6:
      return "Sabtu";
    default:
      return 'Minggu';
  }
}
