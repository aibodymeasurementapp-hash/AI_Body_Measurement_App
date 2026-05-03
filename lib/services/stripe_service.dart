// lib/services/stripe_service.dart
//
// Stripe SANDBOX demo service for academic project.
// Uses Stripe test-mode API. No real money is charged.
// Test card: 4242 4242 4242 4242 | any future expiry | any CVC
//
// Setup steps:
//   1. Create a free Stripe account at https://dashboard.stripe.com
//   2. Go to Developers → API Keys → copy the TEST secret key (sk_test_...)
//      and TEST publishable key (pk_test_...)
//   3. Paste them below
//   4. Transactions appear in Stripe Dashboard → Payments (test mode)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StripeService {
  // 🔑 Replace with your own Stripe TEST keys
  static const String _testSecretKey =
      'sk_test_51TSYTmBaceXbibm0QBIe9CxSHHFG4ImTNqVph4fE2bA1TEM9PdU5P4V7DlA72A9tktLDiHTA7tcCA7M50i1S8GDa00J0sNpNp1';

  static const String productName = 'AI Measure Pro';
  static const String productPrice = '\$4.99';
  static const String productDescription =
      'Unlimited AI body scans, measurement history & size recommendations';

  /// Creates a test charge using a Stripe test token.
  /// tok_visa          → succeeds always
  /// tok_chargeDeclined → declines always
  static Future<StripeChargeResult> createTestCharge({
    required String testToken,
    String currency = 'usd',
    int amountCents = 499,
  }) async {
    debugPrint('[Stripe] Creating test charge with token: $testToken');

    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/charges'),
        headers: {
          'Authorization': 'Bearer $_testSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountCents.toString(),
          'currency': currency,
          'source': testToken,
          'description': '$productName — Academic Demo',
          'metadata[app]': 'AI Body Measure App',
          'metadata[mode]': 'sandbox_demo',
        },
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final chargeId = json['id'] as String;
        final status = json['status'] as String;
        final paid = json['paid'] as bool;
        final receiptUrl = json['receipt_url'] as String? ?? '';

        debugPrint('[Stripe] ✅ Charge $chargeId — status: $status');

        return StripeChargeResult(
          success: paid && status == 'succeeded',
          chargeId: chargeId,
          status: status,
          receiptUrl: receiptUrl,
          errorMessage: null,
        );
      } else {
        final error = json['error'] as Map<String, dynamic>?;
        final msg = error?['message'] as String? ?? 'Unknown error';
        debugPrint('[Stripe] ❌ Charge failed: $msg');
        return StripeChargeResult(
          success: false,
          chargeId: null,
          status: 'failed',
          receiptUrl: null,
          errorMessage: msg,
        );
      }
    } catch (e) {
      debugPrint('[Stripe] ❌ Network error: $e');
      return StripeChargeResult(
        success: false,
        chargeId: null,
        status: 'error',
        receiptUrl: null,
        errorMessage: e.toString(),
      );
    }
  }

  /// Charge with the default test Visa token (always succeeds)
  static Future<StripeChargeResult> chargeTestVisa() =>
      createTestCharge(testToken: 'tok_visa');
}

// ── Result model ──────────────────────────────────────────────────────────────
class StripeChargeResult {
  final bool success;
  final String? chargeId;
  final String status;
  final String? receiptUrl;
  final String? errorMessage;

  const StripeChargeResult({
    required this.success,
    required this.chargeId,
    required this.status,
    required this.receiptUrl,
    required this.errorMessage,
  });
}