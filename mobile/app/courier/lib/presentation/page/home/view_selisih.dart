import 'package:courier/common/constant.dart';
import 'package:flutter/material.dart';

class ViewSelisih extends StatelessWidget {
  const ViewSelisih({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: mPadding,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(mImage),
                radius: 23,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toko Cookies by Tamara',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Pembayaran COD',
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                          color: mPrimaryColor,
                        ),
                  ),
                  const SizedBox(height: 5),
                  const Text('Selesai 26 Nov 2021, 11:20'),
                  const SizedBox(height: 5),
                  Text(
                    'Menunggu Persetujuan',
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                          color: mOnHoldColor,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: mArrowIconColor,
              )
            ],
          )
        ],
      ),
    );
  }
}
