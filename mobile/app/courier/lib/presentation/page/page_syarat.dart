import 'package:courier/common/constant.dart';
import 'package:flutter/material.dart';

class PageSyarat extends StatelessWidget {
  const PageSyarat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syarat & Ketentuan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: mPadding,
              child: Image.asset('assets/ketentuan.png'),
            ),
            Image.asset('assets/footer.png')
          ],
        ),
      ),
    );
  }
}
