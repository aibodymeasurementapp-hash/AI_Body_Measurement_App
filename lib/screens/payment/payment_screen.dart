<<<<<<< HEAD
// lib/screens/payment/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/stripe_service.dart';
import '../../providers/app_state_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with SingleTickerProviderStateMixin {

  final _cardNumberCtrl = TextEditingController(text: '4242 4242 4242 4242');
  final _expiryCtrl     = TextEditingController(text: '12/28');
  final _cvcCtrl        = TextEditingController(text: '123');
  final _nameCtrl       = TextEditingController(text: 'Test User');

  bool    _isProcessing = false;
  String? _errorMessage;

  late AnimationController _shakeCtrl;
  late Animation<double>   _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    _nameCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_isProcessing) return;
    setState(() { _isProcessing = true; _errorMessage = null; });

    final cardNum = _cardNumberCtrl.text.replaceAll(' ', '');
    final token = cardNum == '4000000000000002'
        ? 'tok_chargeDeclined'
        : 'tok_visa';

    final result = await StripeService.createTestCharge(testToken: token);

    if (!mounted) return;

    if (result.success) {
      ref.read(appStateProvider.notifier).setPremium(true);
      context.goNamed('payment-success', extra: {
        'chargeId':    result.chargeId   ?? 'N/A',
        'receiptUrl':  result.receiptUrl ?? '',
      });
    } else {
      setState(() {
        _isProcessing = false;
        _errorMessage = result.errorMessage ?? 'Payment declined.';
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Sandbox badge ────────────────────────────────────────────
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  border: Border.all(color: Colors.amber.shade600),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.science_outlined, size: 14, color: Colors.amber.shade400),
                    const SizedBox(width: 6),
                    Text(
                      'SANDBOX MODE — No real charges',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: Colors.amber.shade400, letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Order summary ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF7ECAC3).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7ECAC3).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.straighten_outlined,
                        color: Color(0xFF7ECAC3), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Measure Pro',
                          style: TextStyle(
                            color: Colors.white, fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          StripeService.productDescription,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '\$4.99',
                    style: TextStyle(
                      color: Color(0xFF7ECAC3), fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Test card hint box ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.green.shade400),
                      const SizedBox(width: 6),
                      Text(
                        'Test Cards (pre-filled for demo)',
                        style: TextStyle(
                          color: Colors.green.shade400, fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _testCardRow('4242 4242 4242 4242', '→ Always succeeds ✅', Colors.green.shade300),
                  const SizedBox(height: 3),
                  _testCardRow('4000 0000 0000 0002', '→ Always declines ❌', Colors.red.shade300),
                  const SizedBox(height: 6),
                  const Text(
                    'Any future expiry · Any 3-digit CVC\nTransactions appear in Stripe Dashboard → Payments',
                    style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Card visual preview ──────────────────────────────────────
            _CardPreview(
              number: _cardNumberCtrl.text,
              name:   _nameCtrl.text,
              expiry: _expiryCtrl.text,
            ),

            const SizedBox(height: 16),

            // ── Form fields ──────────────────────────────────────────────
            _buildField(label: 'Cardholder Name', controller: _nameCtrl),
            const SizedBox(height: 12),
            _buildField(
              label: 'Card Number',
              controller: _cardNumberCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CardNumberFormatter(),
                LengthLimitingTextInputFormatter(19),
              ],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    label: 'Expiry MM/YY',
                    controller: _expiryCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ExpiryFormatter(),
                      LengthLimitingTextInputFormatter(5),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    label: 'CVC',
                    controller: _cvcCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Error ────────────────────────────────────────────────────
            if (_errorMessage != null) ...[
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) {
                  final offset = ((_shakeAnim.value * 4).round() % 2 == 0 ? 1 : -1)
                      * _shakeAnim.value * 8;
                  return Transform.translate(offset: Offset(offset, 0), child: child);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    border: Border.all(color: Colors.red.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!,
                            style: TextStyle(color: Colors.red.shade300, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Pay button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7ECAC3),
                  foregroundColor: const Color(0xFF0F0F1A),
                  disabledBackgroundColor: const Color(0xFF7ECAC3).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Color(0xFF0F0F1A),
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 18),
                    SizedBox(width: 8),
                    Text('Pay \$4.99',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.security, size: 12, color: Colors.white24),
                  const SizedBox(width: 4),
                  const Text('Powered by Stripe · Test environment',
                      style: TextStyle(fontSize: 11, color: Colors.white24)),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _testCardRow(String number, String label, Color color) => Row(
    children: [
      Icon(Icons.credit_card, size: 12, color: color.withOpacity(0.8)),
      const SizedBox(width: 6),
      Text(number,
          style: TextStyle(color: color, fontSize: 12,
              fontFamily: 'monospace', fontWeight: FontWeight.w600)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
    ],
  );

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter> inputFormatters = const [],
    bool obscureText = false,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E1E30),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2E2E45)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2E2E45)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF7ECAC3), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Card Visual Preview ───────────────────────────────────────────────────────
class _CardPreview extends StatelessWidget {
  final String number, name, expiry;
  const _CardPreview({required this.number, required this.name, required this.expiry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2A35), Color(0xFF0D1F2D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7ECAC3).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AI MEASURE PRO',
                  style: TextStyle(
                      color: Color(0xFF7ECAC3), fontSize: 10,
                      letterSpacing: 2, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF7ECAC3).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('TEST',
                    style: TextStyle(
                        color: Color(0xFF7ECAC3), fontSize: 9,
                        letterSpacing: 1, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          Text(
            number.isEmpty ? '•••• •••• •••• ••••' : number,
            style: const TextStyle(
                color: Colors.white, fontSize: 15,
                fontFamily: 'monospace', letterSpacing: 2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name.isEmpty ? 'CARDHOLDER NAME' : name.toUpperCase(),
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
              Text(expiry.isEmpty ? 'MM/YY' : expiry,
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Input Formatters ──────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final str = buf.toString();
    return next.copyWith(
        text: str, selection: TextSelection.collapsed(offset: str.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll('/', '');
    if (digits.length >= 3) {
      final str = '${digits.substring(0, 2)}/${digits.substring(2)}';
      return next.copyWith(
          text: str, selection: TextSelection.collapsed(offset: str.length));
    }
    return next;
  }
=======
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
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
}