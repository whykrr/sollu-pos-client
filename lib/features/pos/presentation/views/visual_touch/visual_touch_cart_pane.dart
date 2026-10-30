import 'package:flutter/material.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/cart_panel.dart';

/// Panel Keranjang Visual Touch (VisualTouchCartPane)
/// Menyediakan panel keranjang interaksi sentuh murni untuk mode Visual Touch,
/// terisolasi secara total dari mode retail keyboard / cockpit.
class VisualTouchCartPane extends StatelessWidget {
  final FocusNode? focusNode;

  const VisualTouchCartPane({
    super.key,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CartPanel(focusNode: focusNode);
  }
}
