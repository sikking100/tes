import 'package:courier/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PagePengaturanTema extends ConsumerWidget {
  const PagePengaturanTema({Key? key}) : super(key: key);
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

// class PagePengaturanTema extends ConsumerStatefulWidget {
//   const PagePengaturanTema({Key? key}) : super(key: key);

//   @override
//   ConsumerState<PagePengaturanTema> createState() => _PagePengaturanTemaState();
// }

// class _PagePengaturanTemaState extends ConsumerState<PagePengaturanTema> {
//   @override
//   Widget build(BuildContext context) {
//     final res = ref.watch(mainController);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pengaturan Tema'),
//       ),
//       body: Padding(
//         padding: mPadding,
//         child: Column(
//           children: [
//             RadioListTile<ThemeMode>(
//               value: ThemeMode.light,
//               groupValue: mode,
//               onChanged: (value) {
//                 setState(() {
//                   res.;
//                   mode = value!;
//                 });
//               },
//               title: const Text('Terang'),
//             ),
//             RadioListTile<ThemeMode>(
//               value: ThemeMode.dark,
//               groupValue: mode,
//               onChanged: (value) {
//                 setState(() {
//                   widget.mainController.updateThemeMode(value);
//                   mode = value!;
//                 });
//               },
//               title: const Text('Gelap'),
//             ),
//             RadioListTile<ThemeMode>(
//               value: ThemeMode.system,
//               groupValue: mode,
//               onChanged: (value) {
//                 setState(() {
//                   widget.mainController.updateThemeMode(value);
//                   mode = value!;
//                 });
//               },
//               title: const Text('Mode Sistem'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
