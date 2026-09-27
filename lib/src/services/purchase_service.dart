import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/app_config.dart';

class PurchaseService extends ChangeNotifier {
  PurchaseService(this.config);

  final AppConfig config;
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final Set<String> _ownedProducts = <String>{};
  List<ProductDetails> _products = const [];
  bool _available = false;

  List<ProductDetails> get products => _products;

  bool get isAvailable => _available;

  Set<String> get ownedProducts => Set.unmodifiable(_ownedProducts);

  bool isPurchased(String productId) => _ownedProducts.contains(productId);

  Future<void> init() async {
    if (config.productIds.isEmpty) return;
    _available = await _iap.isAvailable();
    if (!_available) return;
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object error) => debugPrint('purchaseStream error: $error'),
    );
    await loadProducts();
  }

  Future<void> loadProducts() async {
    if (!_available || config.productIds.isEmpty) return;
    final response = await _iap.queryProductDetails(config.productIds.toSet());
    _products = response.productDetails;
    notifyListeners();
  }

  Future<void> buy(ProductDetails product) async {
    if (!_available) return;
    final params = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: params);
  }

  Future<void> restore() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _ownedProducts.add(purchase.productID);
        case PurchaseStatus.error:
          debugPrint('purchase error: ${purchase.error}');
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
