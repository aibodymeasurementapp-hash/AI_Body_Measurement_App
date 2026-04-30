import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../services/revenuecat_service.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Option A: Show RevenueCat's pre-built paywall UI inline
    return Scaffold(
      body: PaywallView(
        onDismiss: () {
          Navigator.of(context).pop();
        },
        onPurchaseCompleted: (customerInfo, storeTransaction) {
          // User bought a plan — navigate to success
          Navigator.pushReplacementNamed(context, '/payment-success');
        },
        onRestoreCompleted: (customerInfo) {
          if (customerInfo.entitlements.active
              .containsKey(RevenueCatService.entitlementId)) {
            Navigator.pushReplacementNamed(context, '/payment-success');
          }
        },
        onPurchaseError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Purchase failed: ${error.message}')),
          );
        },
      ),
    );
  }
}