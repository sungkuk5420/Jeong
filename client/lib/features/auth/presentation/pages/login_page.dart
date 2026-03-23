import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  void _signInWithGoogle(BuildContext context, WidgetRef ref) {
    ref.read(authProvider.notifier).signInWithGoogle();
    context.goNamed('home');
  }

  void _signInWithApple(BuildContext context, WidgetRef ref) {
    ref.read(authProvider.notifier).signInWithApple();
    context.goNamed('home');
  }

  void _continueAsGuest(BuildContext context, WidgetRef ref) {
    ref.read(authProvider.notifier).signInAsGuest();
    context.goNamed('home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo area
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 40,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text('Jeong', style: AppTextStyles.heading1),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Discover Korea like a local',
                style: AppTextStyles.body.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(flex: 2),

              // Social Login Buttons
              SocialLoginButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                borderColor: colorScheme.outlineVariant,
                onPressed: () => _signInWithGoogle(context, ref),
              ),
              const SizedBox(height: AppSizes.sm),
              SocialLoginButton(
                label: 'Continue with Apple',
                icon: Icons.apple_rounded,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                onPressed: () => _signInWithApple(context, ref),
              ),
              const SizedBox(height: AppSizes.sm),
              SocialLoginButton(
                label: 'Sign up with Email',
                icon: Icons.email_outlined,
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                onPressed: () => _signInWithGoogle(context, ref),
              ),

              const SizedBox(height: AppSizes.lg),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    child: Text(
                      'or',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                ],
              ),

              const SizedBox(height: AppSizes.lg),

              // Guest Mode
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _continueAsGuest(context, ref),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  child: Text(
                    'Browse as Guest',
                    style: AppTextStyles.button.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Terms
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.lg),
                child: Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  style: AppTextStyles.caption.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
