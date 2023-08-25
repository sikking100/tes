import 'package:courier/common/constant.dart';
import 'package:flutter/material.dart';

class PageRating extends StatelessWidget {
  const PageRating({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Play'),
      ),
      body: Padding(
        padding: mPadding,
        child: Image.asset('assets/rating.png'),
      ),
    );
  }
}
