import 'package:flutter/material.dart';
import 'theme/tokens.dart';
import 'theme/app_palette.dart';
import 'widgets/bottom_nav.dart';
import 'pages/tasks_page.dart';
import 'pages/jtasks_page.dart';
import 'pages/shop_page.dart';
import 'pages/history_page.dart';
import 'pages/profile_page.dart';

/// 宿主 Shell：管理底部导航 + 手机宽度居中适配（桌面/平板）。
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  NavKey _nav = NavKey.tasks;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > AppTokens.phoneMaxWidth + 32;
    final pages = [
      const TasksPage(),
      const JTasksPage(),
      const ShopPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];
    final child = Scaffold(
      backgroundColor: p.background,
      body: IndexedStack(index: _nav.index, children: pages),
      bottomNavigationBar: BottomNav(
        active: _nav,
        onTap: (k) => setState(() => _nav = k),
      ),
    );

    if (!isWide) return child;

    // 桌面 / 平板：居中手机宽度容器 + 仿手机外壳
    return Container(
      color: const Color(0xFF0B0B0F),
      alignment: Alignment.center,
      child: Container(
        width: AppTokens.phoneMaxWidth,
        margin: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: p.background,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 60,
              offset: Offset(0, 24),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

extension on NavKey {
  int get index => switch (this) {
        NavKey.tasks => 0,
        NavKey.jtasks => 1,
        NavKey.shop => 2,
        NavKey.history => 3,
        NavKey.profile => 4,
      };
}
