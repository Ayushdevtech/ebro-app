import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/supabase_service.dart';
import '../services/gemini_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? profile;
  String? userApiKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SupabaseService.getProfile();
    final key = await GeminiService.getUserApiKey();
    if (mounted) setState(() {
      profile = p;
      userApiKey = key;
    });
  }

  Future<void> _editName() async {
    final ctrl = TextEditingController(text: profile?['full_name'] ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Edit Name', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await SupabaseService.updateName(result);
      _load();
    }
  }

  Future<void> _setApiKey() async {
    final ctrl = TextEditingController(text: userApiKey ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Gemini API Key', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'AIza...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await GeminiService.saveUserApiKey(result);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API key saved on this device')));
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Clear browsing history?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('This cannot be undone.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: AppColors.coral))),
        ],
      ),
    );
    if (confirm == true) {
      await SupabaseService.clearHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History cleared')));
      }
    }
  }

  Future<void> _signOut() async {
    await SupabaseService.signOut();
    // main.dart's auth listener will automatically show AuthScreen.
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          _group('Account', [
            _row('Display Name', profile?['full_name'] ?? '—', trailing: _smallButton('Edit', _editName)),
            _row('Email', profile?['email'] ?? '—'),
          ]),
          const SizedBox(height: 16),
          _group('AI Engine', [
            _row(
              'Your Gemini API Key',
              userApiKey != null && userApiKey!.isNotEmpty ? 'Set on this device' : 'Using admin default (if set)',
              trailing: _smallButton('Set Key', _setApiKey),
            ),
          ]),
          const SizedBox(height: 16),
          _group('Data', [
            _row('Browsing History', 'Stored in your account', trailing: _smallButton('Clear', _clearHistory, danger: true)),
            _row('Sign Out', 'Log out of Ebro', trailing: _smallButton('Sign Out', _signOut, danger: true)),
          ]),
        ],
      ),
    );
  }

  Widget _group(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: const BoxDecoration(
              color: AppColors.bgSurface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.6)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String name, String value, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _smallButton(String label, VoidCallback onTap, {bool danger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: danger ? AppColors.coralDim : AppColors.bgHover,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: danger ? AppColors.coral.withOpacity(0.3) : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 11.5, color: danger ? AppColors.coral : AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
