import 'package:flutter/material.dart';
import '../views/fast_retail/fast_retail_keyboard_guide_dialog.dart';

/// Legacy alias / wrapper untuk FastRetailKeyboardGuideDialog
class ShortcutCheatSheetDialog extends StatelessWidget {
  const ShortcutCheatSheetDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ShortcutCheatSheetDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const FastRetailKeyboardGuideDialog();
  }
}
