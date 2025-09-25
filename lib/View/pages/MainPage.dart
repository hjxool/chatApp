import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart'; // 第三方图标非内置
import '../../Utils/rpx.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  // 对应页面
  final List<Widget> _pages = [
    Placeholder(color: Colors.red),
    Placeholder(color: Colors.white),
    Placeholder(color: Colors.green),
  ];
  // 导航栏
  final List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(icon: Icon(Symbols.chat), label: '聊天'),
    BottomNavigationBarItem(icon: Icon(Symbols.money_bag), label: '记账'),
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
      ),
    );
  }
}
