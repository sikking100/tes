import 'package:api/api.dart';

// class ArgWebView {
//   final String url;

//   ArgWebView(this.url);
// }

class ArgTracking {
  final String id;

  ArgTracking(this.id);
}

class ArgPhotoView {
  final String imgUrl;
  final bool isFb;

  ArgPhotoView(this.imgUrl, [this.isFb = false]);
}

class ArgProductDetail {
  final String id;

  ArgProductDetail(this.id);
}

class ArgProductList {
  final String title;
  final String? idBrand;

  ArgProductList({required this.title, this.idBrand});
}

class ArgOrderDetail {
  final String id;

  ArgOrderDetail(this.id);
}

class ArgBusinessDetail {
  final Customer? customer;
  final Apply? apply;

  ArgBusinessDetail({this.customer, this.apply});
}

class ArgBusinessListAddress {
  final List<BusinessAddress> items;
  final bool isCheckout;

  ArgBusinessListAddress(this.items, {this.isCheckout = false});
}

class ArgOrderHistory {
  final int index;

  ArgOrderHistory(this.index);
}

class ArgMap {
  final BusinessAddress? address;
  final bool isCheckout;
  final Function(BusinessAddress)? action;

  ArgMap({this.address, this.action, this.isCheckout = false});
}

class ArgReport {
  final String id;
  final bool isMasuk;

  ArgReport(this.id, [this.isMasuk = true]);
}

class ArgPerformance {
  final String id;
  final String type;

  ArgPerformance(this.id, this.type);
}

class ArgPdf {
  final String title;
  final String url;

  ArgPdf(this.title, this.url);
}
