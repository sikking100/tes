import 'package:flutter/material.dart';

class PagePhotoView extends StatelessWidget {
  final String imgUrl;
  const PagePhotoView({Key? key, required this.imgUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Stack(
        children: [
          InteractiveViewer(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(imgUrl))),
            ),
          )
        ],
      ),
    );
  }
}
