import 'package:api/delivery/model.dart';
import 'package:customer/argument.dart';
import 'package:customer/pages/business_detail.dart';
import 'package:customer/pages/business_list_address.dart';
import 'package:customer/pages/cart.dart';
import 'package:customer/pages/checkout.dart';
import 'package:customer/pages/map.dart';
import 'package:customer/pages/order_detail.dart';
import 'package:customer/pages/order_history.dart';
import 'package:customer/pages/page_pdf.dart';
import 'package:customer/pages/pay_later.dart';
import 'package:customer/pages/photo_view.dart';
import 'package:customer/pages/product_detail.dart';
import 'package:customer/pages/product_list.dart';
import 'package:customer/pages/profile.dart';
import 'package:customer/pages/search.dart';
import 'package:customer/pages/theme.dart';
import 'package:customer/pages/tracking.dart';
import 'package:customer/pages/web_view.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String profile = '/profile';
  static const String upgradeAccount = '/upgrade-account';
  static const String updateBusiness = '/update-business';
  static const String theme = '/theme';
  static const String webview = '/webview';

  static const String listProduct = '/list-product';
  static const String productDetail = '/product-detail';
  static const String checkout = '/checkout';
  static const String orderHistory = '/order-history';
  static const String deliveryAddress = '/delivery-address';
  static const String mapPick = '/map-pick';
  static const String search = '/search';
  static const String payLater = '/pay-later';
  static const String photoView = '/photo-view';
  static const String business = '/business-list';
  static const String businessDetail = '/business-detail';
  static const String businessAddress = '/business-list-address';
  static const String peringatan = '/peringatan';
  static const String orderDetail = '/order-detail';
  static const String tracking = '/tracking';
  static const String cart = '/cart';
  static const String pdf = '/pdf';

  static MaterialPageRoute route(RouteSettings settings, Widget widget, [bool isFull = false]) =>
      MaterialPageRoute(settings: settings, builder: (context) => widget, fullscreenDialog: isFull);

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case pdf:
        final arg = settings.arguments as ArgPdf;
        return route(settings, PagePdf(arg: arg), true);
      case profile:
        return route(settings, const PageProfile());
      case theme:
        return route(settings, const PageTheme());
      case webview:
        final args = settings.arguments as Map<String, dynamic>;
        return route(settings, PageWebView(title: args['title'], url: args['url']));
      case listProduct:
        return route(settings, PageProductList(arg: settings.arguments as ArgProductList));
      case productDetail:
        return route(settings, PageProductDetail(arg: settings.arguments as ArgProductDetail));
      case checkout:
        return route(settings, const PageCheckout());
      case orderHistory:
        return route(settings, const PageOrderHistory());
      case orderDetail:
        return route(settings, PageOrderDetail(arg: settings.arguments as String));
      case mapPick:
        return route(settings, PageMap(argument: settings.arguments as ArgMap?));
      case search:
        return route(settings, const PageSearch());
      case payLater:
        return route(settings, const PagePayLater());
      case photoView:
        return route(settings, PagePhotoView(arg: settings.arguments as ArgPhotoView));
      case business:
        return route(settings, Container());
      case businessDetail:
        return route(settings, PageBusinessDetail(arg: settings.arguments as ArgBusinessDetail));
      case businessAddress:
        return route(settings, PageBusinessListAddress(arg: settings.arguments as ArgBusinessListAddress));
      case tracking:
        return route(settings, PageTracking(arg: settings.arguments as Delivery));
      case cart:
        return route(settings, const PageCart());
      default:
        return route(
          settings,
          const Scaffold(
            body: Center(
              child: Text('Halamana tidak ditemukan'),
            ),
          ),
        );
    }
  }
}
