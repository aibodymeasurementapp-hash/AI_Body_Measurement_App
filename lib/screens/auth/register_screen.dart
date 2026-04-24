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

    /// ✅ FIXED (Riverpod correct usage)
    ref.listenManual(authStateProvider, (previous, next) {
      if (next.isAuthenticated && !next.isLoading) {
        ref.read(appStateProvider.notifier).setUserProfile(next.user!);
        context.goNamed('category');
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

  // ─────────────────────────────
  // ACTIONS
  // ─────────────────────────────

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

  // HEIGHT
  void _incHeight() {
    if (_heightCm < 220) setState(() => _heightCm++);
  }

  void _decHeight() {
    if (_heightCm > 100) setState(() => _heightCm--);
  }

  // AGE
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
      appBar: const CustomAppBar(title: 'Create Account'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                /// NAME
                AppTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  controller: _fullNameController,
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter name' : null,
                ),
                const SizedBox(height: 20),

                /// EMAIL
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

                /// PHONE
                AppTextField(
                  label: 'Phone',
                  hintText: 'Enter phone',
                  controller: _phoneController,
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter phone' : null,
                ),
                const SizedBox(height: 20),

                /// PASSWORD
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

                /// CONFIRM PASSWORD
                AppTextField(
                  label: 'Confirm Password',
                  hintText: 'Confirm password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (v) =>
                  v != _passwordController.text ? 'Not match' : null,
                ),

                const SizedBox(height: 24),

                /// GENDER
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

                /// HEIGHT
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

                /// AGE (Buttons + Slider)
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
                      onChanged: (v) =>
                          setState(() => _age = v.round()),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// WEIGHT
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