import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state_provider.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authStateProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Navigate on successful authentication
    ref.listen(authStateProvider, (previous, next) {
      if (next.isAuthenticated && !next.isLoading) {
        ref.read(appStateProvider.notifier).setUserProfile(next.user!);
        context.goNamed('category');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingLarge,
              vertical: 24,
            ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                
                // Logo/Title
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                  ),
                  child: const Icon(
                    Icons.straighten,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Sign in to continue measuring',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Email/Phone Field
                AppTextField(
                  label: 'Email or Phone',
                  hintText: 'Enter your email or phone number',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email or phone';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Password Field
                AppTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Error Message
                if (authState.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                
                // Login Button
                PrimaryButton(
                  text: 'Login',
                  onPressed: _login,
                  isLoading: authState.isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.goNamed('register'),
                      child: const Text(
                        'Create new account',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ) ,
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      ),
      );
  }
}
