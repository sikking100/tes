import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoPage extends StatelessWidget {
  const PhotoPage({Key? key, required this.imagePath}) : super(key: key);

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(
          imagePath,
          errorListener: () => const Center(
            child: Text('Gagal mengambil gambar'),
          ),
        ),
        filterQuality: FilterQuality.high,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 2.0,
        loadingBuilder: (context, event) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text('Gagal memuat gambar'));
        },
        backgroundDecoration: const BoxDecoration(color: Colors.white),
      ),
    );
  }
}
