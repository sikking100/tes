import 'dart:io';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:leader/argument.dart';
import 'package:leader/pages/page_activity.dart';
import 'package:leader/pages/page_activity_add.dart';
import 'package:leader/pages/page_approval_business.dart';
import 'package:leader/pages/page_approval_business_detail.dart';
import 'package:leader/pages/page_approval_order.dart';
import 'package:leader/pages/page_approval_order_detail.dart';
import 'package:leader/pages/page_business.dart';
import 'package:leader/pages/page_business_add.dart';
import 'package:leader/pages/page_business_detail.dart';
import 'package:leader/pages/page_business_list_address.dart';
import 'package:leader/pages/page_cart.dart';
import 'package:leader/pages/page_catalogs.dart';
import 'package:leader/pages/page_checkout.dart';
import 'package:leader/pages/page_leaders.dart';
import 'package:leader/pages/page_map.dart';
import 'package:leader/pages/page_order.dart';
import 'package:leader/pages/page_orders.dart';
import 'package:leader/pages/page_pdf.dart';
import 'package:leader/pages/page_performance.dart';
import 'package:leader/pages/page_product.dart';
import 'package:leader/pages/page_products.dart';
import 'package:leader/pages/page_profile.dart';
import 'package:leader/pages/page_report.dart';
import 'package:leader/pages/page_report_add.dart';
import 'package:leader/pages/page_reports.dart';
import 'package:leader/pages/page_search.dart';
import 'package:leader/pages/page_shopping.dart';
import 'package:leader/pages/page_web_view.dart';
import 'package:leader/pages/page_regions.dart';
import 'package:leader/pages/photo_view.dart';

class Routes {
  static const String webView = '/web-view';
  static const String profile = '/profile';

  //dashboard
  static const String performance = '/performance';
  static const String catalog = '/catalog';
  static const String catalogs = '/catalogs';
  static const String orders = '/orders';
  static const String order = '/order';
  static const String business = '/business';
  static const String businessAdd = '/business-add';
  static const String businessDetail = '/business-detail';
  static const String businessListAddress = '/business-list-address';
  static const String shopping = '/shopping';
  static const String products = '/products';
  static const String search = '/search';
  static const String product = '/product';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String approvalOrder = '/approval-order';
  static const String approvalOrderDetail = '/approval-order-detail';
  static const String approvalBusiness = '/approval-business';
  static const String approvalBusinessDetail = '/approval-business-detail';
  static const String report = '/report';
  static const String reports = '/reports';
  static const String leaders = '/leaders';
  static const String reportAdd = '/report-add';

  static const String activity = '/activity';
  static const String activityAdd = '/activity-add';

  static const String map = '/map';

  static const String regions = '/regions';

  static const String photo = '/photo';

  static const String pdf = '/pdf';

  static materialPageRoute({required RouteSettings settings, required Widget child, bool isFull = false}) =>
      MaterialPageRoute(builder: (context) => child, fullscreenDialog: isFull);

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case pdf:
        final arg = settings.arguments as ArgPdf;
        return materialPageRoute(settings: settings, child: PagePdf(arg: arg), isFull: true);
      case photo:
        final args = settings.arguments as ArgPhotoView;
        return materialPageRoute(settings: settings, child: PagePhotoView(arg: args));
      case webView:
        final args = settings.arguments as Map<String, dynamic>;
        return materialPageRoute(settings: settings, child: PageWebView(title: args['title'], url: args['url']));
      case profile:
        return materialPageRoute(settings: settings, child: const PageProfile());
      case activity:
        return materialPageRoute(settings: settings, child: PageActivity(id: settings.arguments as String));
      case activityAdd:
        return materialPageRoute(settings: settings, child: PageActivityAdd(image: settings.arguments as File?));

      case performance:
        final map = settings.arguments as ArgPerformance;
        return materialPageRoute(settings: settings, child: PagePerformance(id: map.id, type: map.type));

      case catalogs:
        return materialPageRoute(settings: settings, child: const PageCatalogs());

      case orders:
        return materialPageRoute(settings: settings, child: const PageOrders());

      case order:
        return materialPageRoute(settings: settings, child: PageOrder(arg: settings.arguments as String));

      case cart:
        return materialPageRoute(settings: settings, child: const PageCart());

      case checkout:
        return materialPageRoute(settings: settings, child: const PageCheckout());

      case businessListAddress:
        return materialPageRoute(settings: settings, child: PageBusinessListAddress(arg: settings.arguments as ArgBusinessListAddress));

      case map:
        return materialPageRoute(settings: settings, child: PageMap(argument: settings.arguments as ArgMap?));

      case reports:
        return materialPageRoute(settings: settings, child: const PageReports());

      case leaders:
        return materialPageRoute(settings: settings, child: const PageLeaders());

      case report:
        return materialPageRoute(settings: settings, child: PageReport(arg: settings.arguments as ArgReport));

      case reportAdd:
        return materialPageRoute(settings: settings, child: PageReportAdd(empTo: settings.arguments as Employee));

      case business:
        return materialPageRoute(settings: settings, child: const PageBusiness());

      case businessDetail:
        return materialPageRoute(settings: settings, child: PageBusinessDetail(arg: settings.arguments as ArgBusinessDetail));

      case businessAdd:
        return materialPageRoute(settings: settings, child: const PageBusinessAdd());

      case shopping:
        return materialPageRoute(settings: settings, child: const PageShopping());

      case products:
        return materialPageRoute(settings: settings, child: PageProducts(arg: settings.arguments as ArgProductList));

      case product:
        return materialPageRoute(settings: settings, child: PageProduct(arg: settings.arguments as ArgProductDetail));

      case search:
        return materialPageRoute(settings: settings, child: const PageSearch());

      case approvalBusiness:
        return materialPageRoute(settings: settings, child: const PageApprovalBusiness());
      case approvalBusinessDetail:
        return materialPageRoute(settings: settings, child: PageApprovalBusinessDetail(settings.arguments as Apply));

      case approvalOrder:
        return materialPageRoute(settings: settings, child: const PageApprovalOrder());
      case approvalOrderDetail:
        return materialPageRoute(settings: settings, child: PageOrderApprovalDetail(orderApply: settings.arguments as OrderApply));

      case regions:
        return materialPageRoute(settings: settings, child: const PageListRegion());

      default:
        return materialPageRoute(
          settings: settings,
          child: const Scaffold(
            body: Center(
              child: Text('Tidak ditemukan'),
            ),
          ),
        );
    }
  }
}
