import 'package:api/api.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:leader/argument.dart';
import 'package:leader/function.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/pages/page_approval_business.dart';
import 'package:leader/routes.dart';

String getApprovalStatus(int code) {
  switch (code) {
    case 1:
      return "Menunggu Persetujuan";
    case 2:
      return "Disetujui";
    case 3:
      return "Ditolak";
    default:
      return "Menunggu";
  }
}

class PageApprovalBusinessDetail extends ConsumerStatefulWidget {
  const PageApprovalBusinessDetail(this.apply, {super.key});

  final Apply apply;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PageApprovalBusinessDetailState();
}

class _PageApprovalBusinessDetailState extends ConsumerState<PageApprovalBusinessDetail> {
  late Api _api;
  Apply _apply = const Apply();
  bool _isloadingGet = false;
  bool _isloadingApprove = false;
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _limitController = TextEditingController();
  final _termController = TextEditingController();
  final _termInvoiceController = TextEditingController();
  bool isNotMe = true;

  void _init() async {
    _noteController.clear();
    _limitController.text = widget.apply.creditProposal.limit.currencyWithoutRpDoubleZero();
    _termController.text = widget.apply.creditProposal.term.toString();
    _termInvoiceController.text = widget.apply.creditProposal.termInvoice.toString();
  }

  void _getApply() async {
    _api = ref.read(apiProvider);

    final emp = ref.read(employeeStateProvider);
    try {
      setState(() => _isloadingGet = true);
      final res = await _api.apply.byId(widget.apply.id);
      setState(() => _apply = res);

      await Future.delayed(const Duration(seconds: 1));
      return;
    } catch (e) {
      // showSnackBar(context, "Gagal menampilkan data bisnis");
      return;
    } finally {
      setState(() {
        _isloadingGet = false;
        isNotMe = _apply.isNotMe(emp.id);
      });
    }
  }

  void _action(bool accept, List<ApplyUserApprover> userApprover, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      try {
        if (formKey.currentState?.validate() == false) return;
        setState(() => _isloadingApprove = true);
        final emp = ref.read(employeeStateProvider);

        final input = ReqApproval(
          userApprover: userApprover,
          team: emp.team,
          id: widget.apply.id,
          note: _noteController.text,
          priceList: widget.apply.priceList,
          creditProposal: Credit(
            used: widget.apply.creditProposal.used,
            limit: double.parse(_limitController.text.split('.').join()),
            term: int.parse(_termController.text),
            termInvoice: int.parse(_termInvoiceController.text),
          ),
        );
        if (accept) {
          await _api.apply.approve(input);
        } else {
          await _api.apply.reject(input);
        }
        setState(() => _apply = const Apply());
        if (!mounted) return;
        Navigator.pop(context);
        Navigator.pop(context);
      } catch (e) {
        Alerts.dialog(context, content: '$e');
      } finally {
        setState(() => _isloadingApprove = false);
        ref.read(businessApprovalProvider(1)).refresh();
      }
    }
  }

  @override
  void initState() {
    _getApply();
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _noteController.clear();
    _termController.clear();
    _termInvoiceController.clear();
    _limitController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengajuan Bisnis"),
      ),
      body: _isloadingGet
          ? const Center(child: CircularProgressIndicator.adaptive())
          : RefreshIndicator.adaptive(
              onRefresh: () async => _getApply(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: AspectRatio(
                            aspectRatio: 1,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(_apply.customer.imageUrl),
                              radius: 100,
                            ),
                          ),
                          title: Text(_apply.customer.name),
                          subtitle: Text(_apply.customer.phone),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.businessDetail, arguments: ArgBusinessDetail(apply: _apply));
                            },
                            child: const Text("Detail"),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          color: Colors.grey[200],
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Status"),
                                  Text(getApprovalStatus(widget.apply.status)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Limit"),
                                  Text((_apply.creditProposal.limit).currency()),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Tenor"),
                                  Text("${_apply.creditProposal.term} Hari"),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Term Invoice"),
                                  Text(
                                    "${_apply.creditProposal.termInvoice} Hari",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Transaksi Bulan Lalu"),
                                  Text(_apply.transactionLastMonth.currency()),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Transaksi Rata - Rata"),
                                  Text(_apply.transactionPerMonth.currency()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        "Approver",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final approver = _apply.user[i];
                        return Column(
                          children: [
                            ListTile(
                              leading: AspectRatio(
                                aspectRatio: 1,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(approver.imageUrl),
                                  radius: 100,
                                ),
                              ),
                              title: Text(approver.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(roleString(approver.roles)),
                                  Text(
                                    approver.status == 1
                                        ? i == 0
                                            ? approver.updatedAt!.toTimeago
                                            : _apply.user[i - 1].updatedAt!.toTimeago
                                        : approver.updatedAt!.toDDMMMMYYYYHH,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    "note: ${approver.note.isEmpty ? '-' : approver.note}",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                color: approver.status == 1
                                    ? Colors.orange
                                    : approver.status == 2
                                        ? Colors.green
                                        : approver.status == 3
                                            ? Colors.red
                                            : Colors.grey,
                                approver.status == 1
                                    ? Icons.pending
                                    : approver.status == 2
                                        ? Icons.check_circle
                                        : approver.status == 3
                                            ? Icons.cancel
                                            : Icons.refresh,
                              ),
                            ),
                            if (i < _apply.userApprover.length - 1) const Divider(),
                          ],
                        );
                      },
                      childCount: _apply.user.length,
                    ),
                  ),
                ],
              ),
            ),
      // bottomNavigationBar: 0 == Status.reject || 0 == Status.approve
      //     ? null
      //     : isNotMe
      //         ? null
      //         : _isloadingGet
      //             ? null
      //             : BottomAppBar(
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(16.0),
      //                   child: Row(
      //                     children: [
      //                       Expanded(
      //                         child: SizedBox(
      //                           height: 50,
      //                           child: OutlinedButton(
      //                             onPressed: () => _execute(false),
      //                             child: const Text("Tolak"),
      //                           ),
      //                         ),
      //                       ),
      //                       const SizedBox(width: 10),
      //                       Expanded(
      //                         child: SizedBox(
      //                           height: 50,
      //                           child: ElevatedButton(
      //                             onPressed: () => _execute(true),
      //                             child: const Text("Terima"),
      //                           ),
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               ),
      bottomNavigationBar: _apply.status == 5 || _apply.status == 4
          ? null
          : isNotMe
              ? null
              : _isloadingGet
                  ? null
                  : BottomAppBar(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: () => _execute(false),
                                  child: const Text("Tolak"),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () => _execute(true),
                                  child: const Text("Terima"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  void _execute(bool accept) {
    _init();
    showDialog(
      context: context,
      builder: (context) => ScaffoldMessenger(
        child: Scaffold(
          appBar: AppBar(
            title: Text(accept ? "Terima Pengajuan" : "Tolak Pengajuan"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final node1 = ref.watch(keyboardProvider(context));

                      return TextFormField(
                        controller: _limitController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Limit*',
                          hintText: 'Masukkan Limit',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Limit tidak boleh kosong';
                          }
                          return null;
                        },
                        focusNode: node1,
                        keyboardType: TextInputType.number,
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final node2 = ref.watch(keyboardProvider(context));

                      return TextFormField(
                        focusNode: node2,
                        keyboardType: TextInputType.number,
                        controller: _termController,
                        decoration: const InputDecoration(
                          labelText: 'Term*',
                          hintText: 'Masukkan Term',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Term tidak boleh kosong';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final node3 = ref.watch(keyboardProvider(context));

                      return TextFormField(
                        focusNode: node3,
                        keyboardType: TextInputType.number,
                        controller: _termInvoiceController,
                        decoration: const InputDecoration(
                          labelText: 'Term Invoice*',
                          hintText: 'Masukkan Term Invoice',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Term Invoice tidak boleh kosong';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (Wajib)',
                      hintText: 'Masukkan Catatan',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Catatan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isloadingApprove
                      ? null
                      : accept
                          ? () => _action(true, _apply.userApprover, _formKey)
                          : () => _action(false, _apply.userApprover, _formKey),
                  child: _isloadingApprove
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(accept ? "Terima" : "Tolak"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter = NumberFormat.simpleCurrency(locale: 'id', decimalDigits: 0, name: '');

    String newText = formatter.format(value / 1);

    return newValue.copyWith(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }
}
