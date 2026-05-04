<<<<<<< HEAD
// lib/screens/payment/plan_screen.dart

=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('Pro Access',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const SizedBox(height: 16),

            // ── Hero icon ──────────────────────────────────────────────
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7ECAC3).withOpacity(0.12),
                border: Border.all(
                    color: const Color(0xFF7ECAC3).withOpacity(0.3)),
              ),
              child: const Icon(Icons.workspace_premium_outlined,
                  color: Color(0xFF7ECAC3), size: 40),
            ),

            const SizedBox(height: 20),

            const Text(
              'Unlock AI Body Measurements',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white, fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'One-time payment · No subscription',
              style: TextStyle(color: Color(0xFF7ECAC3), fontSize: 13),
            ),

            const SizedBox(height: 28),

            // ── Features list ──────────────────────────────────────────
            _featureRow('Unlimited AI camera scans'),
            _featureRow('Full measurement history'),
            _featureRow('Smart size recommendations'),
            _featureRow('Detailed body analysis report'),

            const SizedBox(height: 32),

            // ── Price card ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF7ECAC3).withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  const Text(
                    '\$4.99',
                    style: TextStyle(
                      color: Color(0xFF7ECAC3), fontSize: 42,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text('one-time · sandbox demo',
                      style: TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.goNamed('payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7ECAC3),
                        foregroundColor: const Color(0xFF0F0F1A),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue to Payment',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 13, color: Colors.white24),
                const SizedBox(width: 4),
                const Text('Stripe Sandbox · No real charges',
                    style: TextStyle(fontSize: 11, color: Colors.white24)),
              ],
            ),

            const SizedBox(height: 32),
          ],
=======
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text('Pro Access'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                color: Color(0xFF7ECAC3),
                size: 72,
              ),
              const SizedBox(height: 20),
              const Text(
                'Unlock AI Body Measurements',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Get unlimited scans, progress history, PDF export, and advanced measurement features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => context.push('/payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7ECAC3),
                  foregroundColor: const Color(0xFF1A1A2E),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'View Plans',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
        ),
      ),
    );
  }
<<<<<<< HEAD

  Widget _featureRow(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7ECAC3).withOpacity(0.15),
          ),
          child: const Icon(Icons.check, color: Color(0xFF7ECAC3), size: 13),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    ),
  );
=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
}