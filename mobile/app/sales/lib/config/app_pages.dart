import 'package:api/product/model.dart';
import 'package:flutter/material.dart';
import 'package:sales/presentation/pages/auth/login_page.dart';
import 'package:sales/presentation/pages/auth/verification_page.dart';
import 'package:sales/presentation/pages/business/business_apply_detail_page.dart';
import 'package:sales/presentation/pages/business/business_create_page.dart';
import 'package:sales/presentation/pages/business/business_detail_page.dart';

import 'package:sales/presentation/pages/home/home_page.dart';
import 'package:sales/presentation/pages/maps/maps_page.dart';
import 'package:sales/presentation/pages/cart/cart_page.dart';
import 'package:sales/presentation/pages/order/order_checkout_page.dart';
import 'package:sales/presentation/pages/order/order_detail_page.dart';
import 'package:sales/presentation/pages/order/order_page.dart';
import 'package:sales/presentation/pages/photo/pdfsync_page.dart';
import 'package:sales/presentation/pages/photo/photo_page.dart';
import 'package:sales/presentation/pages/product/product_all_page.dart';
import 'package:sales/presentation/pages/product/product_bybrand_page.dart';
import 'package:sales/presentation/pages/product/product_detail_page.dart';
import 'package:sales/presentation/pages/product/product_page.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/pages/setting/account_page.dart';
import 'package:sales/presentation/pages/webview/webview_page.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const verify = '/verify';
  static const home = "/home";
  //cart
  static const cartPage = "/cart-page";

  // order
  static const orderState = "/order-state";
  static const orderCheckout = "/order-checkout";
  static const orderDetail = "/order-detail";
  //business
  static const businessById = "/business-byid";
  static const businessCreate = "/business-create";
  static const businessDetail = "/business-detail";
  static const businessApplyDetail = "/business-apply-detail";
  //maps
  static const maps = "/maps";
  //product
  static const productDetail = "/product-detail";
  static const productList = "/product-list";
  static const productAllPage = "/product-all-page";
  static const productListByBrand = "/product-list-by-brand";
  //setting
  static const settingAccount = "/setting-account";
  //image
  static const photo = '/photo';
  static const pdfsycn = '/pdfsync';
  //webview
  static const webview = '/webview';
}

class AppPages {
  static MaterialPageRoute route(Widget widget) {
    return MaterialPageRoute(
      builder: (context) => widget,
    );
  }

  Route? onGenerateRoutes(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.login:
        return route(const LoginPage());
      case AppRoutes.verify:
        return route(const VerificationPage());
      case AppRoutes.home:
        return route(const HomePage());
      case AppRoutes.orderState:
        return route(const OrderPage());
      case AppRoutes.businessCreate:
        return route(const BusinessCreatePage());

      case AppRoutes.businessDetail:
        return route(const BusinessDetailPage());

      case AppRoutes.businessApplyDetail:
        return route(const BusinessApplyDetailPage());
      case AppRoutes.maps:
        if (args is String) {
          return route(MapsPage(
            title: args,
          ));
        }
        return route(const _NotFoundPage());
      case AppRoutes.orderCheckout:
        return route(const OrderCheckoutPage());

      case AppRoutes.orderDetail:
        if (args is String) {
          return route(OrderDetailPage(
            id: args,
          ));
        }
        return route(const _NotFoundPage());
      case AppRoutes.cartPage:
        return route(const CartPage());
      case AppRoutes.productList:
        if (args is ArgProductList) {
          return route(ProductPage(
            arg: args,
          ));
        }
        return route(const _NotFoundPage());
      case AppRoutes.productAllPage:
        if (args is ArgProductList) {
          return route(ProductAllPage(
            arg: args,
          ));
        }
        return route(const _NotFoundPage());
      case AppRoutes.productDetail:
        if (args is Product) {
          return route(ProductDetailPage(
            price: args,
          ));
        }
        return route(const _NotFoundPage());
      case AppRoutes.productListByBrand:
        if (args is ArgProductList) {
          return route(ProductByBrandIdPage(
            arg: args,
          ));
        }
        return route(const _NotFoundPage());
      case AppRoutes.photo:
        if (args is Map) {
          return route(PhotoPage(imagePath: args['photo']));
        }
        return route(const _NotFoundPage());

      case AppRoutes.pdfsycn:
        if (args is Map) {
          return route(PdfSyncPage(
            imageUrl: args['pdfsync'],
          ));
        }
        return route(const _NotFoundPage());
      case AppRoutes.settingAccount:
        return route(const SettingAccountPage());
      case AppRoutes.webview:
        if (args is Map<String, dynamic>) {
          return route(WebViewPage(title: args['title'], url: args['url']));
        }
        return route(const _NotFoundPage());

      default:
        return route(const _NotFoundPage());
    }
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oops!'),
      ),
      body: const Center(
        child: Text('Not Found'),
      ),
    );
  }
}
