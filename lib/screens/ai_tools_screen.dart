import 'package:flutter/material.dart';
import '../theme.dart';
import 'ai_tool_detail_screen.dart';

class AiToolsScreen extends StatelessWidget {
  const AiToolsScreen({super.key});

  static const tools = [
    {'id': 'nobs', 'name': 'No-BS Mode', 'desc': 'Strips clickbait, shows the real story.', 'icon': Icons.bolt, 'color': AppColors.coral, 'hot': true},
    {'id': 'factcheck', 'name': 'Live Fact Checker', 'desc': 'Verifies claims in real time.', 'icon': Icons.fact_check_outlined, 'color': AppColors.green, 'hot': false},
    {'id': 'explain', 'name': "Explain Like I'm 5", 'desc': 'Turns complex text into plain English.', 'icon': Icons.lightbulb_outline, 'color': AppColors.accentLight, 'hot': false},
    {'id': 'tone', 'name': 'Tone Detector', 'desc': 'Detects anger, bias, or manipulation in text.', 'icon': Icons.graphic_eq, 'color': Color(0xFFC084FC), 'hot': false},
    {'id': 'darkpattern', 'name': 'Dark Pattern Detector', 'desc': 'Exposes fake urgency and hidden traps.', 'icon': Icons.warning_amber_outlined, 'color': AppColors.coral, 'hot': true},
    {'id': 'scamcheck', 'name': 'Scam Lookup', 'desc': 'Checks if a number or message is a scam.', 'icon': Icons.phonelink_lock_outlined, 'color': AppColors.amber, 'hot': false},
    {'id': 'trueprice', 'name': 'True Price Mode', 'desc': 'Reveals hidden fees before you buy.', 'icon': Icons.payments_outlined, 'color': AppColors.accentLight, 'hot': false},
    {'id': 'fakereviews', 'name': 'Fake Review Scanner', 'desc': 'Gives products a real trust score.', 'icon': Icons.reviews_outlined, 'color': AppColors.green, 'hot': false},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('AI Tools', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Powered by Gemini', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          ...tools.map((tool) => _toolCard(context, tool)),
        ],
      ),
    );
  }

  Widget _toolCard(BuildContext context, Map<String, dynamic> tool) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AiToolDetailScreen(toolId: tool['id'] as String)),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (tool['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(tool['icon'] as IconData, color: tool['color'] as Color, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(tool['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          if (tool['hot'] as bool) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.coralDim, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Hot', style: TextStyle(fontSize: 9, color: AppColors.coral, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(tool['desc'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                    ],
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
