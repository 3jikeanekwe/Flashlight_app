// lib/services/subscription_service.dart
// Handles $2/month premium subscription logic

import ‘dart:async’;
import ‘package:flutter/foundation.dart’;
import ‘package:in_app_purchase/in_app_purchase.dart’;
import ‘package:shared_preferences/shared_preferences.dart’;

class SubscriptionService extends ChangeNotifier {
static const String _premiumKey = ‘is_premium’;
static const String kSubscriptionId = ‘flashlight_premium_monthly’; // Set your product ID here

bool _isPremium = false;
bool get isPremium => _isPremium;

StreamSubscription<List<PurchaseDetails>>? _subscription;
final InAppPurchase _iap = InAppPurchase.instance;

SubscriptionService() {
_loadPremiumStatus();
_listenToPurchaseUpdates();
}

Future<void> _loadPremiumStatus() async {
final prefs = await SharedPreferences.getInstance();
_isPremium = prefs.getBool(_premiumKey) ?? false;
notifyListeners();
}

Future<void> _savePremiumStatus(bool value) async {
final prefs = await SharedPreferences.getInstance();
await prefs.setBool(_premiumKey, value);
_isPremium = value;
notifyListeners();
}

void _listenToPurchaseUpdates() {
_subscription = _iap.purchaseStream.listen((purchases) {
for (var purchase in purchases) {
_handlePurchase(purchase);
}
});
}

void _handlePurchase(PurchaseDetails purchase) {
if (purchase.productID == kSubscriptionId) {
if (purchase.status == PurchaseStatus.purchased ||
purchase.status == PurchaseStatus.restored) {
_savePremiumStatus(true);
} else if (purchase.status == PurchaseStatus.error) {
debugPrint(‘Purchase error: ${purchase.error}’);
}
if (purchase.pendingCompletePurchase) {
_iap.completePurchase(purchase);
}
}
}

Future<bool> subscribe() async {
final available = await _iap.isAvailable();
if (!available) return false;

```
final response = await _iap.queryProductDetails({kSubscriptionId});
if (response.productDetails.isEmpty) return false;

final purchaseParam = PurchaseParam(
  productDetails: response.productDetails.first,
);
return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
```

}

Future<void> restorePurchases() async {
await _iap.restorePurchases();
}

@override
void dispose() {
_subscription?.cancel();
super.dispose();
}
}
