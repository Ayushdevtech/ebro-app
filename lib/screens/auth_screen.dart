import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/supabase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginTab = true;
  bool isLoading = false;
  String? errorText;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      errorText = null;
      isLoading = true;
    });

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty || (!isLoginTab && _nameCtrl.text.trim().isEmpty)) {
      setState(() {
        errorText = 'Please fill in all fields.';
        isLoading = false;
      });
      return;
    }

    if (!isLoginTab && password.length < 8) {
      setState(() {
        errorText = 'Password must be at least 8 characters.';
        isLoading = false;
      });
      return;
    }

    final result = isLoginTab
        ? await SupabaseService.signIn(email: email, password: password)
        : await SupabaseService.signUp(
            name: _nameCtrl.text.trim(),
            email: email,
            password: password,
          );

    setState(() => isLoading = false);

    if (result != null) {
      setState(() => errorText = result);
    }
    // On success, main.dart's auth-state listener swaps to HomeScreen automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBrand(),
                const SizedBox(height: 36),
                _buildCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              letterSpacing: -1,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: 'E', style: TextStyle(color: AppColors.accent)),
              TextSpan(text: 'bro'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'The browser that works for you, not against you.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabs(),
          const SizedBox(height: 24),
          if (!isLoginTab) ...[
            _buildLabel('Your Name'),
            const SizedBox(height: 6),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'What should we call you?')),
            const SizedBox(height: 16),
          ],
          _buildLabel('Email'),
          const SizedBox(height: 6),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'you@example.com'),
          ),
          const SizedBox(height: 16),
          _buildLabel('Password'),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            decoration: InputDecoration(
              hintText: isLoginTab ? 'Your password' : 'Min 8 characters',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(isLoginTab ? 'Sign In' : 'Create Account'),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              errorText!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.coral, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      );

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _tabButton('Sign In', true),
          _tabButton('Create Account', false),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool tabIsLogin) {
    final selected = isLoginTab == tabIsLogin;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          isLoginTab = tabIsLogin;
          errorText = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
