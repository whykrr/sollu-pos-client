import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'held_bills_drawer.dart';

class HoldOrdersDialog extends ConsumerWidget {
  const HoldOrdersDialog({super.key});

  static Future<void> show(BuildContext context) {
    return HeldBillsDrawer.showAsDialog(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const HeldBillsDrawer();
  }
}
