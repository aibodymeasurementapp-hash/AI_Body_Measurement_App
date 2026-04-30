import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_profile.dart';
import '../../providers/app_state_provider.dart';
import '../../services/revenuecat_service.dart'; // ← add this

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _weightController = TextEditingController();

  Gender _selectedGender = Gender.male;
  double _heightCm = 170.0;
  int _age = 25;

  @override
  void initState() {
    super.initState();

    // ✅ After successful register → show paywall if not premium, then navigate
    ref.listenManual(authStateProvider, (previous, next) async {
      if (next.isAuthenticated && !next.isLoading) {
        ref.read(appStateProvider.notifier).setUserProfile(next.user!);

        // New users will never be premium — paywall will always show here.
        // They can purchase or dismiss and continue.
        await RevenueCatService.presentPaywallIfNeeded(context);

        if (context.mounted) context.goNamed('category');
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final userProfile = UserProfile(
        id: '',
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _selectedGender,
        heightCm: _heightCm,
        weightKg: double.tryParse(_weightController.text) ?? 0.0,
        age: _age,
      );

      await ref.read(authStateProvider.notifier).register(
        userProfile,
        _passwordController.text,
      );
    }
  }

  void _incHeight() {
    if (_heightCm < 220) setState(() => _heightCm++);
  }

  void _decHeight() {
    if (_heightCm > 100) setState(() => _heightCm--);
  }

  void _incAge() {
    if (_age < 80) setState(() => _age++);
  }

  void _decAge() {
    if (_age > 10) setState(() => _age--);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Create Account',
        onBackPressed: () => context.goNamed('login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  controller: _fullNameController,
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter name' : null,
                ),
                const SizedBox(height: 20),

                AppTextField(
                  label: 'Email',
                  hintText: 'Enter email',
                  controller: _emailController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                AppTextField(
                  label: 'Phone',
                  hintText: 'Enter phone',
                  controller: _phoneController,
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter phone' : null,
                ),
                const SizedBox(height: 20),

                AppTextField(
                  label: 'Password',
                  hintText: 'Enter password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    if (v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                AppTextField(
                  label: 'Confirm Password',
                  hintText: 'Confirm password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (v) =>
                  v != _passwordController.text ? 'Not match' : null,
                ),
                const SizedBox(height: 24),

                Row(
                  children: Gender.values.map((g) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGender = g),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedGender == g
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMedium),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            g.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedGender == g
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Height'),
                    Row(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _decHeight),
                        Text('${_heightCm.toInt()} cm'),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _incHeight),
                      ],
                    ),
                    Slider(
                      value: _heightCm,
                      min: 100,
                      max: 220,
                      divisions: 120,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _heightCm = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Age'),
                    Row(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _decAge),
                        Text('$_age years'),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _incAge),
                      ],
                    ),
                    Slider(
                      value: _age.toDouble(),
                      min: 10,
                      max: 80,
                      divisions: 70,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _age = v.round()),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                AppTextField(
                  label: 'Weight (kg)',
                  hintText: 'Enter your weight',
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter weight';
                    if (double.tryParse(v) == null) return 'Invalid weight';
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                if (authState.error != null)
                  Text(authState.error!,
                      style: const TextStyle(color: AppColors.error)),

                const SizedBox(height: 10),

                PrimaryButton(
                  text: 'Create Account',
                  onPressed: _register,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => context.goNamed('login'),
                  child: const Text(
                    'Already have account? Login',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}