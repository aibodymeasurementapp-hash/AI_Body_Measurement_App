// lib/services/revenuecat_service.dart

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService {
  static const String _apiKey      = 'test_mvgzKGsKhjjmsMtKOqGlivClTzs';

  // ⚠️  Must exactly match the Entitlement identifier in your RC dashboard
  //     Dashboard → Entitlements → copy the identifier string
  static const String entitlementId = 'pro'; // ← verify this in dashboard

  // ─── Initialize ───────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(_apiKey));
    debugPrint('[RC] ✅ Initialized');
    await debugOfferings();
  }

  // ─── Firebase user sync ───────────────────────────────────────────────────
  static Future<void> loginUser(String firebaseUid) async {
    try {
      await Purchases.logIn(firebaseUid);
      debugPrint('[RC] ✅ Logged in: $firebaseUid');
    } catch (e) {
      debugPrint('[RC] ❌ loginUser error: $e');
    }
  }

  static Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('[RC] ❌ logoutUser error: $e');
    }
  }

  // ─── Premium check ────────────────────────────────────────────────────────
  static Future<bool> isPremium() async {
    try {
      final CustomerInfo info = await Purchases.getCustomerInfo();
      final active = info.entitlements.active;
      debugPrint('[RC] Active entitlements: ${active.keys.toList()}');
      debugPrint('[RC] Looking for: "$entitlementId"');
      return active.containsKey(entitlementId);
    } catch (e) {
      debugPrint('[RC] ❌ isPremium error: $e');
      return false;
    }
  }

  // ─── Debug helper ─────────────────────────────────────────────────────────
  // Check your debug console for [RC] lines after running the app.
  // NOTE: Offering has no .paywall getter in the Flutter SDK — we check
  //       offering + packages only. If packages are empty, the paywall
  //       has nothing to show even if the template exists in the dashboard.
  static Future<void> debugOfferings() async {
    try {
      final Offerings offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        debugPrint('[RC] ❌ NO current offering!');
        debugPrint('[RC]    Fix: Dashboard → Offerings → set one as Current');
        return;
      }

      final current = offerings.current!;
      debugPrint('[RC] ✅ Current offering: "${current.identifier}"');

      final packages = current.availablePackages;
      if (packages.isEmpty) {
        debugPrint('[RC] ❌ Offering has NO packages!');
        debugPrint('[RC]    Fix: Dashboard → Products → add products to your offering');
      } else {
        debugPrint('[RC] ✅ Packages: ${packages.map((p) => "${p.identifier} (${p.storeProduct.priceString})").toList()}');
      }

      // List all offerings for reference
      debugPrint('[RC] All offering IDs: ${offerings.all.keys.toList()}');
    } catch (e) {
      debugPrint('[RC] ❌ debugOfferings error: $e');
    }
  }

  // ─── Present paywall (always shows) ──────────────────────────────────────
  static Future<bool> presentPaywall(BuildContext context) async {
    try {
      await debugOfferings();
      final PaywallResult result = await RevenueCatUI.presentPaywall(
        displayCloseButton: true,
      );
      debugPrint('[RC] presentPaywall result: $result');
      return result == PaywallResult.purchased || result == PaywallResult.restored;
    } catch (e) {
      debugPrint('[RC] ❌ presentPaywall error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paywall error: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  // ─── Present paywall only if NOT premium ─────────────────────────────────
  static Future<bool> presentPaywallIfNeeded(BuildContext context) async {
    try {
      await debugOfferings();
      final PaywallResult result = await RevenueCatUI.presentPaywallIfNeeded(
        entitlementId,
        displayCloseButton: true,
      );
      debugPrint('[RC] presentPaywallIfNeeded result: $result');
      // PaywallResult values:
      //   notPresented → user already has entitlement (premium), paywall skipped ✅
      //   cancelled    → user dismissed without buying
      //   purchased    → successful purchase ✅
      //   restored     → successful restore ✅
      //   error        → something went wrong
      return result == PaywallResult.purchased || result == PaywallResult.restored;
    } catch (e) {
      debugPrint('[RC] ❌ presentPaywallIfNeeded error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paywall error: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  // ─── Restore purchases ────────────────────────────────────────────────────
  static Future<bool> restorePurchases() async {
    try {
      final CustomerInfo info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      debugPrint('[RC] ❌ restorePurchases error: $e');
      return false;
    }
  }
}