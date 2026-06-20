import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_tab.dart';
import 'browser_tab.dart';
import 'ai_tools_screen.dart';
import 'shopping_screen.dart';
import 'settings_screen.dart';

/// Root screen shown after login. Holds the bottom navigation bar and
/// switches between the five main tabs. The browser tab keeps its own
/// state alive (via IndexedStack) so a loaded webpage isn't lost when
/// the user taps over to AI Tools and back.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final GlobalKey<BrowserTabState> _browserKey = GlobalKey<BrowserTabState>();

  void openUrlInBrowser(String url) {
    setState(() => currentIndex = 1);
    _browserKey.currentState?.loadUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeTab(onOpenUrl: openUrlInBrowser),
      BrowserTab(key: _browserKey),
      const AiToolsScreen(),
      const ShoppingScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                _navItem(Icons.home_outlined, Icons.home, 'Home', 0),
                _navItem(Icons.public_outlined, Icons.public, 'Browse', 1),
                _navItem(Icons.auto_awesome_outlined, Icons.auto_awesome, 'AI Tools', 2),
                _navItem(Icons.shopping_bag_outlined, Icons.shopping_bag, 'Shopping', 3),
                _navItem(Icons.settings_outlined, Icons.settings, 'Settings', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, String label, int index) {
    final selected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 22,
              color: selected ? AppColors.accentLight : AppColors.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.accentLight : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
