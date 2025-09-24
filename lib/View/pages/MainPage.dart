import 'package:flutter/material.dart';
import '../../Utils/rpx.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatWithMe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: null,
          ),
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
      ),
      body: Placeholder(),
    );
  }
}
