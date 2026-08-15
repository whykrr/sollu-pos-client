import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';

class AppliedDiscount {
  final String? promoId;
  final String name;
  final String type; // 'percentage', 'fixed'
  final double value;
  final double? maxDiscount;
  final bool isManual;

  const AppliedDiscount({
    this.promoId,
    required this.name,
    required this.type,
    required this.value,
    this.maxDiscount,
    this.isManual = false,
  });

  double calculateDiscount(double subtotal) {
    if (subtotal <= 0) return 0.0;
    
    double disc = 0.0;
    if (type == 'percentage') {
      disc = (subtotal * value) / 100.0;
      if (maxDiscount != null && maxDiscount! > 0 && disc > maxDiscount!) {
        disc = maxDiscount!;
      }
    } else {
      disc = value;
    }

    if (disc > subtotal) {
      disc = subtotal;
    }
    return disc;
  }
}

class AppliedDiscountNotifier extends Notifier<AppliedDiscount?> {
  @override
  AppliedDiscount? build() => null;

  void applyPromo(Promo promo) {
    state = AppliedDiscount(
      promoId: promo.id,
      name: promo.name,
      type: promo.promoType,
      value: promo.discountValue,
      maxDiscount: promo.maxDiscount,
      isManual: false,
    );
  }

  void applyManualDiscount({
    required String type,
    required double value,
    String? name,
  }) {
    state = AppliedDiscount(
      promoId: null,
      name: name ?? (type == 'percentage' ? 'Diskon $value%' : 'Potongan Harga'),
      type: type,
      value: value,
      isManual: true,
    );
  }

  void clearDiscount() {
    state = null;
  }
}

final appliedDiscountProvider = NotifierProvider<AppliedDiscountNotifier, AppliedDiscount?>(AppliedDiscountNotifier.new);
