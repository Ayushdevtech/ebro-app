import 'package:flutter/material.dart';
import '../theme.dart';
import 'ai_tool_detail_screen.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final _searchCtrl = TextEditingController();
  String? searchedQuery;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Smart Shopping', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Compare prices, check fake reviews', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(hintText: 'Search a product...'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => setState(() => searchedQuery = _searchCtrl.text.trim()),
                child: const Text('Compare'),
              ),
            ],
          ),
          if (searchedQuery != null && searchedQuery!.isNotEmpty) _buildResults(),
          const SizedBox(height: 24),
          _featureCard(
            context,
            'True Price Mode',
            'Adds hidden fees, shows real total price.',
            Icons.payments_outlined,
            'trueprice',
          ),
          const SizedBox(height: 10),
          _featureCard(
            context,
            'Fake Review Scanner',
            'Detects bot-written reviews, gives trust score.',
            Icons.reviews_outlined,
            'fakereviews',
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final platforms = [
      {'name': 'Amazon', 'color': const Color(0xFFFF9900), 'url': 'https://www.amazon.in/s?k='},
      {'name': 'Flipkart', 'color': const Color(0xFF2874F0), 'url': 'https://www.flipkart.com/search?q='},
      {'name': 'Meesho', 'color': const Color(0xFFF43397), 'url': 'https://www.meesho.com/search?q='},
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: platforms.map((p) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: p['color'] as Color, borderRadius: BorderRadius.circular(6)),
                  child: Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(searchedQuery!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                const Icon(Icons.open_in_new, size: 14, color: AppColors.textMuted),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _featureCard(BuildContext context, String title, String desc, IconData icon, String toolId) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AiToolDetailScreen(toolId: toolId))),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppColors.accentDim, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.accentLight, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
