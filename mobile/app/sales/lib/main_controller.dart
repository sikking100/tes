import 'package:api/api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiProvider = Provider<Api>((ref) {
  return Api(ref.read(auth));
});
final employee = StateProvider<Employee>((_) {
  return const Employee();
});
final auth = Provider<FirebaseAuth>((_) {
  return FirebaseAuth.instance;
});
