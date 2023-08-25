import 'package:flutter_test/flutter_test.dart';
import 'package:common/common.dart';

void main() {
  group('Status String', () {
    group('delivery', () {
      test('should return string', () {
        final result = StatusString.delivery(0);
        expect(result, isA<String>());
      });

      test('complete should return custom complete text', () {
        final result = StatusString.delivery(0);
        expect(result, equals('Pengantaran Selesai'));
      });

      test('pending should return custom pending text', () {
        final result = StatusString.delivery(0);
        expect(result, equals('Belum Diantar'));
      });

      test('delivery should return custom delivery text', () {
        final result = StatusString.delivery(0);
        expect(result, equals('Mengantar'));
      });

      test('default should return custom default text', () {
        final result = StatusString.delivery(0);
        expect(result, equals('Menunggu'));
      });
    });

    group('business', () {
      test('should return string', () {
        final result = StatusString.business(0);
        expect(result, isA<String>());
      });

      test('reject should return custom reject text', () {
        final result = StatusString.business(0);
        expect(result, equals('Mohon maaf pengajuan Bisnis Anda belum disetujui.  Hubungi kami melalui "Pusat Bantuan" untuk info selanjutnya.'));
      });

      test('pending should return custom pending text', () {
        final result = StatusString.business(0);
        expect(result, equals('Sedang Diproses'));
      });

      test('default should return custom default text', () {
        final result = StatusString.business(0);
        expect(result, equals('Disetujui'));
      });
    });

    group('approval', () {
      test('should return string', () {
        final result = StatusString.approval(0);
        expect(result, isA<String>());
      });

      test('reject should return custom reject text', () {
        final result = StatusString.approval(0);
        expect(result, equals('Mohon maaf pengajuan Pay Later Anda belum disetujui.  Hubungi kami melalui "Pusat Bantuan" untuk info selanjutnya.'));
      });

      test('pending should return custom pending text', () {
        final result = StatusString.approval(0);
        expect(result, equals('Sedang Diproses'));
      });

      test('waiting approve should return custom waiting approve text', () {
        final result = StatusString.approval(0);
        expect(result, equals('Menunggu Persetujuan'));
      });

      test('default should return custom default text', () {
        final result = StatusString.approval(0);
        expect(result, equals('Disetujui'));
      });
    });

    group('invoice', () {
      test('should return string', () {
        final result = StatusString.invoice(0);
        expect(result, isA<String>());
      });

      test('expired should return custom expired text', () {
        final result = StatusString.invoice(0);
        expect(result, equals('Kedaluwarsa'));
      });

      test('paid should return custom paid text', () {
        final result = StatusString.invoice(0);
        expect(result, equals('Terbayar'));
      });

      test('paid transfer should return custom paid transfer text', () {
        final result = StatusString.invoice(0, 0);
        expect(result, equals('Lunas'));
      });

      test('default should return custom default text', () {
        final result = StatusString.invoice(0);
        expect(result, equals('Menunggu Pembayaran'));
      });
    });

    group('order', () {
      test('should return string', () {
        final result = StatusString.order(0);
        expect(result, isA<String>());
      });

      test('pending should return custom pending text', () {
        final result = StatusString.order(0);
        expect(result, equals('Pending'));
      });

      test('paid should return custom paid text', () {
        final result = StatusString.order(0);
        expect(result, equals('Terbayar'));
      });

      test('default should return custom default text', () {
        final result = StatusString.order(0);
        expect(result, equals('Menunggu Pembayaran'));
      });
    });
  });

  group('Extension', () {
    test('fullDate should return string', () {
      final result = DateTime.now().fullDate;
      expect(result, isA<String>());
    });
  });
}
