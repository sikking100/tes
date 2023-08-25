import 'package:api/api.dart';
import 'package:courier/presentation/page/page_edit_profile.dart';
import 'package:courier/presentation/page/page_loaded.dart';
import 'package:courier/presentation/page/page_pengantaran.dart';
import 'package:courier/presentation/page/page_pengaturan_tema.dart';
import 'package:courier/presentation/page/page_photo_view.dart';
import 'package:courier/presentation/page/page_rincian_jemputan.dart';
import 'package:courier/presentation/page/page_rincian_pengantaran.dart';
import 'package:courier/presentation/page/page_rincian_riwayat.dart';
import 'package:courier/presentation/page/page_riwayat_pengantaran.dart';
import 'package:courier/presentation/page/page_selisih_barang.dart';
import 'package:courier/presentation/page/page_webview.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String home = '/home';
  static const String editProfile = '/edit-profile';
  static const String pengaturanTema = '/pengaturan-tema';
  static const String webview = '/webview';

  static const String pengantaran = '/pengantaran';
  static const String rincianPengantaran = '/rincian-pengantaran';
  static const String rincianPackingList = '/rincian-packing-list';
  static const String selisihUang = '/selisih-uang';
  static const String selisihBarang = '/selisih-barang';
  static const String photoview = '/photo-view';
  static const String riwayat = '/riwayat';
  static const String looaded = "/loaded";
  static const String riwayatRincian = '/riwayat-rincian';

  static MaterialPageRoute route(Widget widget) => MaterialPageRoute(builder: (context) => widget);

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case editProfile:
        return route(const PageEditProfile());
      case pengaturanTema:
        return route(const PagePengaturanTema());
      case webview:
        final String args = settings.arguments as String;

        return route(PageWebview(url: args));
      case pengantaran:
        final args = settings.arguments as Map<String, dynamic>;
        return route(PagePengantaran(
          delivery: args['delivery'],
        ));
      case rincianPengantaran:
        final args = settings.arguments as Delivery;
        return route(PageRincianPengantaran(delivery: args));
      case selisihBarang:
        final args = settings.arguments as Map<String, dynamic>;
        return route(
          PageSelisihBarang(
            idDelivery: args['id'],
            status: args['status'],
            products: args['products'],
            defaultNote: args['defaultNote'],
          ),
        );
      case rincianPackingList:
        final args = settings.arguments as Map;
        return route(
          PageRincianJemputan(
            isRestock: args['isRestock'] ?? false,
            packingList: args['list'],
          ),
        );
      case photoview:
        final args = settings.arguments as Map<String, dynamic>;
        return route(PagePhotoView(imgUrl: args['img']));

      case riwayat:
        return route(const PageRiwayatPengantaran());
      case looaded:
        return route(const PageLoaded());
      case riwayatRincian:
        return route(PageRincianRiwayat(id: settings.arguments as String));
      default:
        return route(
          const Scaffold(
            body: Center(
              child: Text('Tidak ada halaman'),
            ),
          ),
        );
    }
  }
}
