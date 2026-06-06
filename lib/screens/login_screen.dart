import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await context.read<AuthProvider>().login(
            _emailController.text,
            _passwordController.text,
          );
      if (success) {
        if (mounted) context.go('/');
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('Connection error') || errorStr.contains('SocketException')) {
        setState(() => _error = 'Connection error: Please check your internet connection');
      } else {
        setState(() => _error = 'Invalid Email / Password');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDemoLogin() async {
    _emailController.text = 'admin@ecosevaks.com';
    _passwordController.text = 'Admin@123';
    _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go('/'),
                icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              // Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/images/app_icon.png', width: 60, height: 60),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome back',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to continue your eco journey',
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 40),

              // Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                ),
                child: Column(
                  children: [
                    CustomInput(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      leftIcon: Icon(LucideIcons.mail, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                    const SizedBox(height: 20),
                    CustomInput(
                      label: 'Password',
                      controller: _passwordController,
                      isPassword: true,
                      leftIcon: Icon(LucideIcons.lock, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.alertCircle, color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                      fullWidth: true,
                      leftIcon: const Icon(LucideIcons.logIn, size: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: const Text(
                      'Register',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(child: Divider(color: isDark ? const Color(0xFF334155) : Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Or try demo', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: isDark ? const Color(0xFF334155) : Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Login as Admin',
                onPressed: _handleDemoLogin,
                variant: ButtonVariant.outline,
                fullWidth: true,
                leftIcon: const Icon(LucideIcons.shield, size: 20, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'admin@ecosevaks.com',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

