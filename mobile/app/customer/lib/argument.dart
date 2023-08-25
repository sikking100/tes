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
  final bool? first;
  final Customer? business;

  ArgBusinessDetail({this.business, this.first = false});
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

  ArgMap({this.address, this.isCheckout = false, this.action});
}

class ArgPdf {
  final String title;
  final String url;

  ArgPdf(this.title, this.url);
}
