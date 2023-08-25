library api;

import 'package:api/activity/new_repo.dart';
import 'package:api/auth/repo.dart';
import 'package:api/banner/repo.dart';
import 'package:api/branch/repo.dart';
import 'package:api/brand/repo.dart';
import 'package:api/category/repo.dart';
import 'package:api/customer/repo.dart';
import 'package:api/employee/repo.dart';
import 'package:api/delivery/repo.dart';
import 'package:api/invoice/repo.dart';
import 'package:api/maps/repo.dart';
import 'package:api/order/repo.dart';
import 'package:api/price_list/repo.dart';
import 'package:api/product/repo.dart';
import 'package:api/recipe/repo.dart';
import 'package:api/region/repo.dart';
import 'package:api/report/repo.dart';

export 'package:api/activity/new_model.dart';
export 'package:api/auth/model.dart';
export 'package:api/banner/new_model.dart';
export 'package:api/branch/model.dart';
export 'package:api/brand/model.dart';
export 'package:api/category/model.dart';
export 'package:api/customer/model.dart';
export 'package:api/delivery/model.dart' hide Warehouse;
export 'package:api/employee/model.dart';
export 'package:api/invoice/model.dart';
export 'package:api/maps/model.dart';
export 'package:api/order/model.dart';
export 'package:api/product/model.dart';
export 'package:api/recipe/model.dart';
export 'package:api/region/model.dart';
export 'package:api/report/model.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:simple_logger/simple_logger.dart';
import 'package:http/http.dart';

final logger = SimpleLogger()
  ..mode = LoggerMode.log
  ..setLevel(Level.INFO, includeCallerInfo: true);

class Api {
  static final Api instance = Api._();

  factory Api([FirebaseAuth? fbAuth]) {
    final client = Client();
    final auth = fbAuth ?? FirebaseAuth.instance;
    instance.activity = ActivityRepoImpl(client, auth);
    instance.auth = AuthRepoImpl(client);
    instance.banner = BannerRepoImpl(client, auth);
    instance.branch = BranchRepoImpl(client, auth);
    instance.brand = BrandhRepoImpl(client, auth);
    instance.category = CategoryRepoImpl(client, auth);
    instance.customer = CustomerRepoImpl(client, auth);
    instance.apply = ApplyRepoImpl(client, auth);
    instance.delivery = DeliveryRepoImpl(client, auth);
    instance.invoice = InvoiceRepoImpl(client, auth);
    instance.employee = EmployeeRepoImpl(client, auth);
    instance.maps = MapsRepoImpl(client);
    instance.order = OrderRepoImpl(client, auth);
    instance.orderApply = OrderApplyRepoImpl(client, auth);
    instance.product = ProductRepoImpl(client, auth);
    instance.priceList = PriceRepoImpl(client, auth);
    instance.recipe = RecipeRepoImpl(client, auth);
    instance.region = RegionRepoImpl(client, auth);
    instance.report = ReportRepoImpl(client, auth);
    return instance;
  }

  Api._();

  late ActivityRepo activity;
  late AuthRepo auth;
  late BannerRepo banner;
  late BranchRepo branch;
  late BrandRepo brand;
  late CategoryRepo category;
  late CustomerRepo customer;

  ///pengajuan bisnis
  late ApplyRepo apply;
  late DeliveryRepo delivery;
  late EmployeeRepo employee;
  late InvoiceRepo invoice;
  late MapsRepo maps;
  late OrderRepo order;
  late OrderApplyRepo orderApply;
  late ProductRepo product;
  late PriceRepoImpl priceList;
  late RecipeRepo recipe;
  late RegionRepo region;
  late ReportRepo report;
}
