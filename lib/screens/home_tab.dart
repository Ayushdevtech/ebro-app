import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/supabase_service.dart';
import 'ai_tool_detail_screen.dart';

/// The dashboard tab: greeting, search bar, stats, quick-access site grid.
/// Tapping a quick-access tile or running a search hands the URL up to
/// HomeScreen, which switches to the Browser tab and loads it there —
/// this keeps "search" and "browse" feeling like one connected app
/// instead of two disconnected screens.
class HomeTab extends StatefulWidget {
  final void Function(String url) onOpenUrl;
  const HomeTab({super.key, required this.onOpenUrl});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _searchCtrl = TextEditingController();
  String userName = '';
  Map<String, dynamic>? profile;

  final List<Map<String, dynamic>> quickSites = [
    {'name': 'YouTube', 'url': 'https://youtube.com', 'color': Color(0xFFFF0000), 'letter': 'Y'},
    {'name': 'Twitter', 'url': 'https://twitter.com', 'color': Color(0xFF1DA1F2), 'letter': 'X'},
    {'name': 'Amazon', 'url': 'https://amazon.in', 'color': Color(0xFFFF9900), 'letter': 'A'},
    {'name': 'Flipkart', 'url': 'https://flipkart.com', 'color': Color(0xFF2874F0), 'letter': 'F'},
    {'name': 'Reddit', 'url': 'https://reddit.com', 'color': Color(0xFFFF4500), 'letter': 'R'},
    {'name': 'GitHub', 'url': 'https://github.com', 'color': Color(0xFF24292E), 'letter': 'G'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await SupabaseService.getProfile();
    if (mounted) {
      setState(() {
        profile = data;
        userName = data?['full_name'] ?? 'there';
      });
    }
  }

  void _runSearch() {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    final url = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    widget.onOpenUrl(url);
    _searchCtrl.clear();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            '$_greeting${userName.isNotEmpty ? ', $userName' : ''}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            _formattedDate(),
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          _buildSearchCard(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          const Text('Quick Access', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _buildQuickGrid(),
          const SizedBox(height: 24),
          _buildNoBsTeaser(),
        ],
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _runSearch(),
              decoration: const InputDecoration(
                hintText: 'What do you want to know?',
                border: InputBorder.none,
                isCollapsed: true,
                filled: false,
              ),
              style: const TextStyle(fontSize: 14.5, color: AppColors.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: _runSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(20)),
              child: const Text('Go', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final trackers = profile?['trackers_blocked'] ?? 0;
    final ads = profile?['ads_blocked'] ?? 0;
    final pages = profile?['pages_visited'] ?? 0;

    return Row(
      children: [
        Expanded(child: _statCard('$trackers', 'Trackers Blocked')),
        const SizedBox(width: 10),
        Expanded(child: _statCard('$ads', 'Ads Blocked')),
        const SizedBox(width: 10),
        Expanded(child: _statCard('$pages', 'Pages Visited')),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accentLight)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildQuickGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quickSites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, i) {
        final site = quickSites[i];
        return GestureDetector(
          onTap: () => widget.onOpenUrl(site['url'] as String),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: site['color'] as Color, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(site['letter'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 6),
              Text(site['name'] as String, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoBsTeaser() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AiToolDetailScreen(toolId: 'nobs')),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.coralDim,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.coral.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.bolt, color: AppColors.coral, size: 22),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Try No-BS Mode — paste any clickbait headline and see the truth.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
