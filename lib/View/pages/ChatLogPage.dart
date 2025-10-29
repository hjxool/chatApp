import 'package:chat_app/Utils/CommonApi.dart';
import 'package:chat_app/Utils/CusAppBar.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ChatLogPage extends StatelessWidget {
  const ChatLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = context.arguments<Map<String, dynamic>>();

    return Scaffold(
      appBar: CusAppBar(
        title: (args?['title'] ?? ''),
        actions: [
          IconButton(
            onPressed: null,
            icon: Icon(
              Symbols.more_horiz,
              size: 50.rpx,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      body: Placeholder(color: Colors.red),
    );
  }
}
