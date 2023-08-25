import 'package:customer/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageTheme extends ConsumerWidget {
  const PageTheme({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(mainController);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Tema'),
      ),
      body: Column(
        children: [
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: res.themeMode,
            onChanged: (value) {
              res.updateThemeMode(value);
            },
            title: const Text('Terang'),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: res.themeMode,
            onChanged: (value) {
              res.updateThemeMode(value);
            },
            title: const Text('Gelap'),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: res.themeMode,
            onChanged: (value) {
              res.updateThemeMode(value);
            },
            title: const Text('Mode Sistem'),
          ),
        ],
      ),
    );
  }
}
