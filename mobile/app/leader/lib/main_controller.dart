import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/widget.dart';

final keyboardProvider = Provider.autoDispose.family<FocusNode, BuildContext>((ref, c) {
  final FocusNode node = FocusNode();
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    node.addListener(() {
      bool hasFocus = node.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(c);
      } else {
        KeyboardOverlay.removerOverlay();
      }
    });
  }
  ref.onDispose(() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      node.dispose();
      KeyboardOverlay.removerOverlay();
    }
  });

  return node;
});

final apiProvider = Provider.autoDispose<Api>((ref) {
  final firebase = FirebaseAuth.instance;
  return Api(firebase);
});

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

final buttonStateProvider = StateProvider.autoDispose<bool>((_) => false);

final customerStateProvider = StateProvider<Customer>((_) {
  return const Customer();
});

final loadingStateProvider = StateProvider.autoDispose<bool>((_) {
  return false;
});

final indexProvider = StateProvider.autoDispose<String>((ref) {
  final emp = ref.read(employeeStateProvider);
  if (emp.roles == UserRoles.rm) {
    return emp.location?.id ?? '';
  }
  if (emp.roles == UserRoles.am) {
    return emp.location?.id ?? '';
  }
  return '';
});
