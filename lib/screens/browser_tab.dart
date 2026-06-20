import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme.dart';
import '../services/supabase_service.dart';

/// This is the real browser. WebViewController under the hood runs on
/// Chromium on Android and WebKit on iOS — the exact same rendering
/// engines Chrome and Safari use. This is what makes Google, Instagram,
/// Amazon etc. actually load and work, unlike the iframe in a web app.
class BrowserTab extends StatefulWidget {
  const BrowserTab({super.key});

  @override
  State<BrowserTab> createState() => BrowserTabState();
}

class BrowserTabState extends State<BrowserTab> {
  late final WebViewController _controller;
  final _urlBarCtrl = TextEditingController();

  bool isLoading = false;
  bool hasPage = false;
  bool canGoBack = false;
  bool canGoForward = false;
  String currentUrl = '';
  String currentTitle = '';
  bool incognito = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
              currentUrl = url;
              _urlBarCtrl.text = url;
            });
          },
          onPageFinished: (url) async {
            final title = await _controller.getTitle();
            final back = await _controller.canGoBack();
            final fwd = await _controller.canGoForward();
            setState(() {
              isLoading = false;
              currentUrl = url;
              currentTitle = title ?? url;
              canGoBack = back;
              canGoForward = fwd;
            });
            if (!incognito) {
              SupabaseService.addHistory(url, title ?? url);
              SupabaseService.incrementPagesVisited();
            }
          },
          onWebResourceError: (error) {
            setState(() => isLoading = false);
          },
        ),
      );
  }

  void loadUrl(String input) {
    String url = input.trim();
    if (url.isEmpty) return;

    final looksLikeUrl = url.contains('.') && !url.contains(' ');
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = looksLikeUrl
          ? 'https://$url'
          : 'https://www.google.com/search?q=${Uri.encodeComponent(url)}';
    }

    setState(() => hasPage = true);
    _controller.loadRequest(Uri.parse(url));
  }

  void _toggleIncognito() {
    setState(() => incognito = !incognito);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(incognito ? 'Private mode on — history won\'t be saved' : 'Private mode off'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.bgCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildNavBar(),
          if (isLoading) const LinearProgressIndicator(minHeight: 2, color: AppColors.accent, backgroundColor: Colors.transparent),
          Expanded(
            child: hasPage
                ? WebViewWidget(controller: _controller)
                : _buildPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            color: canGoBack ? AppColors.textPrimary : AppColors.textMuted,
            onPressed: canGoBack ? () => _controller.goBack() : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, size: 20),
            color: canGoForward ? AppColors.textPrimary : AppColors.textMuted,
            onPressed: canGoForward ? () => _controller.goForward() : null,
          ),
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, size: 12, color: AppColors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _urlBarCtrl,
                      onSubmitted: loadUrl,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Search or enter URL',
                        border: InputBorder.none,
                        isCollapsed: true,
                        filled: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, size: 20, color: hasPage ? AppColors.textPrimary : AppColors.textMuted),
            onPressed: hasPage ? () => _controller.reload() : null,
          ),
          IconButton(
            icon: Icon(
              incognito ? Icons.visibility_off : Icons.visibility_off_outlined,
              size: 19,
              color: incognito ? AppColors.accentLight : AppColors.textMuted,
            ),
            onPressed: _toggleIncognito,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 14),
            const Text(
              'Enter a URL or search above',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 6),
            const Text(
              'This is a real browser engine — every site, including Google and Instagram, will load normally.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}
