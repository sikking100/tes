// import 'package:api/common.dart';
// import 'package:api/employee/repo.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:http/http.dart';

// import '../api_test.dart';

// void main() {
//   late MockAuth auth;
//   late EmployeeRepo repo;
//   setUp(() {
//     auth = MockAuth();
//     repo = EmployeeRepoImpl(Client(), auth);
//   });
//   test('test', () async {
//     when(Client().get(Uri.https(host, 'employee/api/v1/SALES001'),
//         headers: const Headers(
//                 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImNlOWI4ODBmODE4MmRkYTU1N2Y3YzcwZTIwZTRlMzcwZTNkMTI3NDciLCJ0eXAiOiJKV1QifQ.eyJicmFuY2hJZCI6WyJNS1MwMDEiXSwicGhvbmUiOiIrNjI4MTI0NTIyMzY1NCIsInJlZ2lvbklkIjpbXSwicm9sZXMiOjEzLCJ0ZWFtIjoyLCJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZGFpcnktZm9vZC1kZXZlbG9wbWVudCIsImF1ZCI6ImRhaXJ5LWZvb2QtZGV2ZWxvcG1lbnQiLCJhdXRoX3RpbWUiOjE2NzMxNjQ2NTMsInVzZXJfaWQiOiJTQUxFUzAwMSIsInN1YiI6IlNBTEVTMDAxIiwiaWF0IjoxNjczMTY0NjUzLCJleHAiOjE2NzMxNjgyNTMsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnt9LCJzaWduX2luX3Byb3ZpZGVyIjoiY3VzdG9tIn19.nZQr5XVpD3bGpsX8izVoYvKkdmY_FPOuY5Nfk_2nu3ZwjtcK-doZyEpDPNXZtZNDC9viY0Ls_mw520CCbkKurWi-1ZisrSehFyELca4i3z047OQxiEOQoTkDLyI6Kf6OY_JcWLhqgyNAyZGxFG3ytZWr5eRWvPA_csF8yzFkK7f99SjVYmt6uTvuh23MEtCnojVIoc9Uk9i6W2MtHr8kk6Rf27GtMHVNuJA-MkaW7My7k2KLWOmPvEDW_wpFHy1JVz8pUoB4cj6W5Ol-QS1T1FAL5VfR86gbNHGhZC_IsYWUshdceZTjzZ6iNUYlLYykidGuuLd_NrzoCxyt3VBHeQ')
//             .toMap()));

//     final result = await repo.byId('SALES001');

//     print(result);
//   });
// }
