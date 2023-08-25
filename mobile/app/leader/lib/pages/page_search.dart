import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:leader/argument.dart';
import 'package:leader/cart_provider.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/routes.dart';
import 'package:leader/widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

final searchStateNotifierProvider = StateNotifierProvider.autoDispose<SearchState, AsyncValue<Paging<Product>>>((ref) => SearchState(ref));

class SearchState extends StateNotifier<AsyncValue<Paging<Product>>> {
  SearchState(AutoDisposeRef ref) : super(const AsyncValue.data(Paging(null, []))) {
    api = ref.read(apiProvider);
    branchId = ref.read(customerStateProvider).business?.location.branchId ?? '';
    text = TextEditingController();
    text.addListener(() {
      if (text.text.length > 3) {
        search();
      }
    });
  }

  late final Api api;
  late final String branchId;
  late TextEditingController text;

  void search({String? value}) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => api.product.find(query: branchId, search: value ?? text.text));
    state = result;
  }

  @override
  void dispose() {
    super.dispose();
    text.dispose();
  }
}

final voiceStateProvider = StateNotifierProvider<VoiceState, String>((ref) => VoiceState());

class VoiceState extends StateNotifier<String> {
  VoiceState() : super('') {
    speechToText = SpeechToText();
    _initSpeech();
  }
  late SpeechToText speechToText;
  late bool enabled;
  String lastWords = '';

  void _initSpeech() async {
    state = '';
    enabled = await speechToText.initialize();
    state = '';
  }

  void startListening() async {
    await speechToText.listen(onResult: (e) {
      state = e.recognizedWords;
      lastWords = e.recognizedWords;
    });
  }

  void stopListening() async {
    await speechToText.stop();
    state = lastWords;
  }
}

class PageSearch extends ConsumerWidget {
  const PageSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(searchStateNotifierProvider);
    final cart = ref.watch(cartStateNotifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencarian'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimens.px16),
            child: TextField(
              style: Theme.of(context).brightness == Brightness.light ? null : const TextStyle(color: Colors.black),
              controller: ref.read(searchStateNotifierProvider.notifier).text,
              onSubmitted: (value) => ref.read(searchStateNotifierProvider.notifier).search(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                fillColor: mTextfieldLoginColor,
                alignLabelWithHint: true,
                filled: true,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari Produk',
                suffixIcon: IconButton(
                  onPressed: () async {
                    final result = await Permission.microphone.request();
                    if (result.isGranted && context.mounted) {
                      return showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return const VoiceWidget();
                        },
                      );
                    }
                  },
                  icon: const Icon(Icons.mic),
                ),
              ),
            ),
          ),
          Expanded(
            child: res.when(
              data: (data) {
                return GridView.builder(
                  padding: const EdgeInsets.all(Dimens.px16),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: (MediaQuery.of(context).size.width / 2) / ((MediaQuery.of(context).size.height + 100) / 2),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemBuilder: (context, index) {
                    final price = data.items[index];
                    return WidgetProduct(
                      radius: 15,
                      productDetail: () => Navigator.pushNamed(context, Routes.product, arguments: ArgProductDetail(price.id)),
                      name: price.name,
                      padding: 20,
                      price: TextPrice(product: price),
                      sizeProduct: price.size,
                      image: Image.network(price.imageUrl),
                      buttonCart: ButtonCart(
                        isEmpty: cart.where((element) => element.productId == price.productId).isEmpty,
                        addProduct: () => ref.read(cartStateNotifier.notifier).add(price),
                        px10: 10,
                        px4: 4,
                        buttonColor: mPrimaryColor,
                        removeProduct: () => ref.read(cartStateNotifier.notifier).remove(price.productId),
                        qty: TextCount(product: price),
                      ),
                      padding10: 10,
                      padding6: 6,
                      padding16: 16,
                    );
                  },
                  itemCount: data.items.length,
                );
              },
              error: (e, _) => Center(
                child: Text(e.toString()),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceWidget extends ConsumerStatefulWidget {
  const VoiceWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<VoiceWidget> createState() => _VoiceWidgetState();
}

class _VoiceWidgetState extends ConsumerState<VoiceWidget> {
  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    if (mounted) {
      _initSpeech();
    }
    super.initState();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        _lastWords = result.recognizedWords;
      });
      ref.read(searchStateNotifierProvider.notifier).search(value: result.recognizedWords);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            _lastWords.isNotEmpty
                ? _lastWords
                : _speechEnabled
                    ? 'Tap the microphone'
                    : 'Speech is not available',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.secondary),
            child: IconButton(
              iconSize: 100,
              onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
              icon: const Icon(Icons.mic, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
