import 'package:customer/argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PagePdf extends StatelessWidget {
  final ArgPdf arg;
  const PagePdf({
    Key? key,
    required this.arg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(arg.title),
      ),
      body: const PDF().cachedFromUrl(
        arg.url,
        placeholder: (progress) => Center(
          child: Text('$progress%'),
        ),
        errorWidget: (error) => Center(
          child: Text('$error'),
        ),
      ),
    );
  }
}
