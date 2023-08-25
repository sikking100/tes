// import 'dart:convert';
// import 'dart:io';

// import 'package:api/activity/newModel.dart';
// import 'package:api/common.dart';
// import 'package:flutter_test/flutter_test.dart';

// final Activity tActivity = Activity(
//   id: 'string',
//   title: 'string',
//   description: 'string',
//   imageUrl: 'string',
//   videoUrl: 'string',
//   creator: const Creator(
//     id: 'string',
//     description: 'string',
//     imageUrl: 'string',
//     name: 'string',
//     roles: 0,
//   ),
//   createdAt: DateTime.parse('2022-11-27T01:43:19.030Z').toLocal(),
//   updatedAt: DateTime.parse('2022-11-27T01:43:19.030Z').toLocal(),
// );

// const ActivitySave tActivitySave = ActivitySave(
//   title: 'string',
//   description: 'string',
//   videoUrl: 'string',
//   createdBy: CreatedBy(
//     id: 'string',
//     address: Address(),
//     description: 'string',
//     imageUrl: 'string',
//     name: 'string',
//     phone: '',
//     roles: 'string',
//   ),
// );

// final tpActivity = Paging<Activity>(const Item(), const Item(), [tActivity]);

// final tsActivity = [tActivity];

// final Comment tComment = Comment(
//   activityId: 'string',
//   comment: 'string',
//   id: 'string',
//   createdBy: const CreatedBy(
//     id: 'string',
//     address: Address(),
//     description: 'string',
//     imageUrl: 'string',
//     name: 'string',
//     phone: '',
//     roles: 'string',
//   ),
//   createdAt: DateTime.parse('2022-11-27T01:43:19.030Z').toLocal(),
// );

// final tpComment = Paging<Comment>(const Item(), const Item(), [tComment]);

// const SaveComment tSaveComment = SaveComment(
//   activityId: 'string',
//   comment: 'string',
//   createdBy: CreatedBy(
//     id: 'string',
//     address: Address(),
//     description: 'string',
//     imageUrl: 'string',
//     name: 'string',
//     phone: '',
//     roles: 'string',
//   ),
// );

// final jActivity = File('test/activity/activity.json').readAsStringSync();
// final jSaveActivity = File('test/activity/activity_req.json').readAsStringSync();
// final jpActivity = File('test/activity/activity_paging.json').readAsStringSync();
// final jsActivity = File('test/activity/activity_search.json').readAsStringSync();
// final jComment = File('test/activity/comment.json').readAsStringSync();
// final jpComment = File('test/activity/comment_paging.json').readAsStringSync();

// final jSaveComment = File('test/activity/comment_req.json').readAsStringSync();

// void main() {
//   group('Activity Model', () {
//     test('fromMap', () {
//       final result = Activity.fromMap(jsonDecode(jActivity)['data']);
//       expect(result, equals(tActivity));
//     });

//     test('save toMap', () {
//       final result = tActivitySave.toMap();
//       expect(result, jsonDecode(jSaveActivity));
//     });
//   });

//   group('Comment', () {
//     test('fromMap', () {
//       final result = Comment.fromMap(jsonDecode(jComment)['data']);
//       expect(result, equals(tComment));
//     });

//     test('save toMap', () {
//       final result = tSaveComment.toMap();
//       expect(result, jsonDecode(jSaveComment));
//     });
//   });
// }
