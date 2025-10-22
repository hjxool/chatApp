import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart'; // 第三方图标非内置
import '../../Utils/rpx.dart';
import '../../Utils/BadgeIcon.dart';
import '../../Providers/globalConfig.dart';
import 'ChatPage.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _currentIndex = 0;

  // 对应页面
  Widget _pages(int index) {
    switch (index) {
      case 0:
        return ChatPage();
      case 1:
        return Placeholder(color: Colors.yellow);
      case 2:
        return Placeholder(color: Colors.blue);
      default:
        return Text('页面不存在');
    }
  }

  // 导航栏
  // 因为只能在build内定义或使用因此要用函数
  List<BottomNavigationBarItem> _bottomNavItems() {
    final unreadNum = ref.watch(UnreadMessageProvider);
    return [
      BottomNavigationBarItem(
        icon: BadgeIcon(icon: Icon(Symbols.forum), badgeCount: unreadNum),
        label: '聊天',
      ),
      BottomNavigationBarItem(
        icon: BadgeIcon(icon: Icon(Symbols.money_bag), badgeCount: 0),
        label: '记账',
      ),
      BottomNavigationBarItem(
        icon: BadgeIcon(icon: Icon(Symbols.psychology_alt), badgeCount: 0),
        label: 'AI',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items: _bottomNavItems(),
        backgroundColor: Colors.grey[200],
        selectedItemColor: Color(0xFF07B75B), // 选中项颜色
      ),
    );
  }
}
