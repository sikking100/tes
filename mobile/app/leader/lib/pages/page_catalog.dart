import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';

class PageCatalog extends StatelessWidget {
  final Product product;
  const PageCatalog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Katalog Produk'),
      ),
      body: ListView(
        children: [
          Hero(
            tag: product.id,
            child: Container(
              padding: const EdgeInsets.all(Dimens.px16),
              decoration: BoxDecoration(color: theme.highlightColor.withOpacity(0.3)),
              child: Center(
                child: Image.network(
                  product.imageUrl,
                  height: MediaQuery.of(context).size.width * 50 / 100,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimens.px16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xffdfdfdf) : null,
                        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.network(product.brand.imageUrl),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(product.size, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Kategori',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(product.category.name),
                const SizedBox(height: 20),
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(product.description)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
