import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

extension ExtDateFormat on DateTime {
  String get toTimeago {
    timeago.setLocaleMessages("id", timeago.IdMessages());
    timeago.setDefaultLocale("id");
    return timeago.format(
      this,
      locale: "id",
      allowFromNow: true,
    );
  }

  String get toCustomFormat {
    return DateFormat("EEEE, dd MMMM yyyy", "id").format(this);
  }

  String get toDDMMMMYYYY {
    return DateFormat("dd MMMM yyyy", "id").format(this);
  }

  String get toDDMMMYYYY {
    return DateFormat("dd MMM yyyy", "id").format(this);
  }

  String get toHHMM {
    return DateFormat("hh:mm a", "id").format(this);
  }

  String get toDDMMMMYYYYHH {
    return DateFormat("EEEE, dd MMMM yyyy  hh:mm a", "id").format(this);
  }
}

String phoneFormatToIndonesia(
  String phoneNumber,
) {
  if (phoneNumber.isEmpty) {
    return 'Nomor hp tidak boleh kosong!';
  }
  if (phoneNumber.startsWith("0")) {
    phoneNumber = "+62${phoneNumber.substring(1)}";
  } else if (phoneNumber.startsWith("+")) {
    phoneNumber = phoneNumber;
  } else {
    phoneNumber = "+62$phoneNumber";
  }
  return phoneNumber;
}
