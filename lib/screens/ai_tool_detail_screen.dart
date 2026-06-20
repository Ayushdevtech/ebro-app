import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/gemini_service.dart';

/// Generic screen that runs any of the AI tools. Takes a toolId, looks up
/// the right title/placeholder/prompt-builder, and makes a real call to
/// Gemini through GeminiService when the user taps Run.
class AiToolDetailScreen extends StatefulWidget {
  final String toolId;
  const AiToolDetailScreen({super.key, required this.toolId});

  @override
  State<AiToolDetailScreen> createState() => _AiToolDetailScreenState();
}

class _AiToolDetailScreenState extends State<AiToolDetailScreen> {
  final _inputCtrl = TextEditingController();
  bool isLoading = false;
  String? output;
  String? errorText;

  static final Map<String, _ToolMeta> _meta = {
    'nobs': _ToolMeta('No-BS Mode', 'Paste a headline or article text...', GeminiService.noBsPrompt),
    'factcheck': _ToolMeta('Live Fact Checker', 'Paste a claim to fact-check...', GeminiService.factCheckPrompt),
    'explain': _ToolMeta("Explain Like I'm 5", 'Paste complex text here...', GeminiService.explainPrompt),
    'tone': _ToolMeta('Tone Detector', 'Paste any text...', GeminiService.tonePrompt),
    'darkpattern': _ToolMeta('Dark Pattern Detector', 'Paste website text or UI copy...', GeminiService.darkPatternPrompt),
    'scamcheck': _ToolMeta('Scam Lookup', 'Paste a number or message...', GeminiService.scamCheckPrompt),
    'trueprice': _ToolMeta('True Price Mode', 'Paste product price details...', GeminiService.truePricePrompt),
    'fakereviews': _ToolMeta('Fake Review Scanner', 'Paste product reviews...', GeminiService.fakeReviewPrompt),
  };

  _ToolMeta get meta => _meta[widget.toolId]!;

  Future<void> _run() async {
    final input = _inputCtrl.text.trim();
    if (input.isEmpty) return;

    setState(() {
      isLoading = true;
      errorText = null;
      output = null;
    });

    try {
      final result = await GeminiService.generate(meta.promptBuilder(input));
      setState(() => output = result);
    } catch (e) {
      setState(() => errorText = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(meta.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: TextField(
                controller: _inputCtrl,
                maxLines: 6,
                style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                decoration: InputDecoration(hintText: meta.placeholder, border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: isLoading ? null : _run,
              child: isLoading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Run Analysis'),
            ),
            const SizedBox(height: 20),
            if (errorText != null) _buildError(),
            if (output != null) _buildOutput(),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.coralDim,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.coral.withOpacity(0.3)),
      ),
      child: Text(errorText!, style: const TextStyle(color: AppColors.coral, fontSize: 12.5)),
    );
  }

  Widget _buildOutput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: SelectableText(output!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.6)),
    );
  }
}

class _ToolMeta {
  final String title;
  final String placeholder;
  final String Function(String) promptBuilder;
  _ToolMeta(this.title, this.placeholder, this.promptBuilder);
}
