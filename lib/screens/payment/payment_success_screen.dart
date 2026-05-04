<<<<<<< HEAD
// lib/screens/payment/payment_success_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _scaleAnim;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final extra     = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final chargeId  = extra?['chargeId']   as String? ?? 'N/A';
    final receiptUrl = extra?['receiptUrl'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // ── Animated check ─────────────────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7ECAC3).withOpacity(0.12),
                    border: Border.all(
                        color: const Color(0xFF7ECAC3).withOpacity(0.4),
                        width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Color(0xFF7ECAC3), size: 52),
                ),
              ),

              const SizedBox(height: 28),

              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [

                    const Text(
                      'Payment Successful!',
                      style: TextStyle(
                        color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'AI Measure Pro is now unlocked.\nCamera measurements are fully available.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white54, fontSize: 14, height: 1.6),
                    ),

                    const SizedBox(height: 28),

                    // ── Transaction details ──────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF2E2E45)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TRANSACTION DETAILS',
                            style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700,
                              color: Colors.white30, letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _row('Status',   'Succeeded ✅'),
                          const SizedBox(height: 8),
                          _row('Amount',   '\$4.99 USD'),
                          const SizedBox(height: 8),
                          _row('Mode',     'Stripe Sandbox'),
                          const SizedBox(height: 8),
                          // Charge ID with copy button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 100,
                                child: Text('Charge ID',
                                    style: TextStyle(
                                        color: Colors.white38, fontSize: 12)),
                              ),
                              Expanded(
                                child: Text(
                                  chargeId,
                                  style: const TextStyle(
                                    color: Color(0xFF7ECAC3),
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: chargeId));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Charge ID copied'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.copy_outlined,
                                    size: 14, color: Colors.white38),
                              ),
                            ],
                          ),
                          if (receiptUrl.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _row('Receipt', 'Available in Stripe Dashboard'),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Stripe dashboard note ────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.open_in_new,
                              size: 14, color: Colors.blue.shade300),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'View this transaction in Stripe Dashboard → Payments (Test mode)',
                              style: TextStyle(
                                  color: Colors.blue.shade300,
                                  fontSize: 11, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Continue button ──────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7ECAC3),
                          foregroundColor: const Color(0xFF0F0F1A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () => context.goNamed('camera-measurement'),
                        child: const Text(
                          'Start AI Measurement',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
=======
import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)?.settings.arguments as Map?;
    final plan = args?['plan'] ?? 'Pro';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7ECAC3).withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF7ECAC3),
                  size: 52,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your $plan subscription is now active.',
                style: const TextStyle(
                    color: Colors.white60, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7ECAC3),
                    foregroundColor: const Color(0xFF1A1A2E),
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                            (_) => false,
                      ),
                  child: const Text(
                    'Start Measuring',
                    style: TextStyle(fontSize: 15),
                  ),
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD

  Widget _row(String label, String value) => Row(
    children: [
      SizedBox(
        width: 100,
        child: Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ),
      Expanded(
        child: Text(value,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    ],
  );
=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
}