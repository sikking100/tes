import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:simple_logger/simple_logger.dart';

class Store {
  static final instance = Store._();
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  factory Store() => instance;
  Store._();

  Stream<DocumentSnapshot<Map<String, dynamic>>> customer(String id) {
    return _store.collection("customer").doc(id).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> order(String id) {
    return _store.collection("order").doc(id).snapshots();
  }

  Stream chat() {
    return _store.collection('chat').snapshots();
  }

  Future updateLoc({required String id, required LocationData loc}) async {
    try {
      _store.doc('tracking/$id').update({'courier.lat': loc.latitude, 'courier.lng': loc.longitude, 'courier.heading': loc.heading});
      return;
    } catch (e) {
      SimpleLogger().info(e.toString());
    }
  }
}
