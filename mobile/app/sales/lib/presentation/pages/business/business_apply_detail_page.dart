import 'package:api/customer/model.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/presentation/pages/business/provider/business_detail_provider.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/widgets/app_empty_widget.dart';
import 'package:sales/presentation/widgets/app_image_widget.dart';
import 'package:sales/config/functions.dart';

class BusinessApplyDetailPage extends ConsumerWidget {
  const BusinessApplyDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(businessDetailProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengajuan Bisnis"),
      ),
      body: RefreshIndicator(
        color: theme.primaryColor,
        onRefresh: () async {
          return ref
              .watch(businessDetailProvider.notifier)
              .init(ref.watch(customerStateProvider));
        },
        child: data.when(
            data: (customer) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(Dimens.px16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppImagePrimary(
                              isOnTap: true,
                              imageUrl: customer.customer.imageUrl,
                              height: 64,
                              width: 64,
                              radius: 100,
                            ),
                            const SizedBox(width: Dimens.px12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.customer.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customer.customer.phone,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            Consumer(
                              builder: (context, ref, child) => ElevatedButton(
                                onPressed: () async {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.businessDetail,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text('Detail'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Color(Colors.grey.shade200.value),
                        child: Column(
                          children: [
                            text(
                                context,
                                "Limit",
                                customer.apply!.creditProposal.limit
                                    .toInt()
                                    .currency()),
                            text(context, "Tenor",
                                "${customer.apply!.creditProposal.term} Hari"),
                            text(context, "Term Invoice",
                                "${customer.apply!.creditProposal.termInvoice} Hari"),
                          ],
                        ),
                      ),
                      customer.apply!.userApprover.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(Dimens.px16),
                              child: Text(
                                "Approver",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            )
                          : const SizedBox(),
                      Column(
                        children: List.generate(
                          customer.apply!.userApprover.length,
                          (index) => approver(
                            context,
                            customer.apply!.userApprover[index],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                const AppEmptyWidget(title: "Data tidak ditemukan")),
      ),
    );
  }
}

Widget approver(BuildContext context, ApplyUserApprover user) {
  Icon icon(int status) {
    switch (status) {
      case 4:
        return const Icon(Icons.cancel, color: Colors.red);
      case 0:
        return const Icon(null);

      case 1:
        return const Icon(Icons.pending, color: Colors.orange);

      case 2:
        return const Icon(Icons.pending, color: Colors.orange);

      default:
        return const Icon(Icons.check_circle, color: Colors.green);
    }
  }

  if (user.status != 0 && user.note != "approve by system") {
    return Column(
      children: [
        ListTile(
          title: Text(user.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(roleString(user.roles)),
              user.status == 2
                  ? Text(user.updatedAt!.toTimeago)
                  : Text(user.updatedAt!.toDDMMMMYYYYHH),
              if (user.note.isNotEmpty) Text("Note: ${user.note}"),
              if (user.status != 0) Text(StatusString.business(user.status)),
            ],
          ),
          leading: AppImagePrimary(
            isOnTap: true,
            imageUrl: user.imageUrl,
            height: 50,
            width: 50,
            radius: 100,
          ),
          trailing: icon(user.status),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.px16),
          child: Divider(),
        )
      ],
    );
  }
  return Container();
}

Widget text(BuildContext context, String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: Dimens.px16, vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
        ),
        const SizedBox(width: Dimens.px16),
        Flexible(
          child: Text(
            value,
          ),
        ),
      ],
    ),
  );
}
