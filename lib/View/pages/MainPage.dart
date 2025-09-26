import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart'; // 第三方图标非内置
import '../../Utils/rpx.dart';
import '../widgets/BadgeIcon.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _currentIndex = 0;
  // 对应页面
  final List<Widget> _pages = [
    Placeholder(color: Colors.red),
    Placeholder(color: Colors.green),
    Placeholder(color: Colors.yellow),
  ];
  // 导航栏
  final List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: BadgeIcon(icon: Icon(Symbols.forum), badgeCount: 30),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatWithMe'),
        actions: [
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.add, color: Colors.black),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.rpx),
          child: Divider(
            height: 1.rpx,
            thickness: 1.rpx,
            color: Color(0xFFE5E5E5), // 微信风格发丝线,
          ),
        ),
        backgroundColor: Colors.grey[200],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items: _bottomNavItems,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Color(0xFF07B75B), // 选中项颜色
      ),
    );
  }
}
