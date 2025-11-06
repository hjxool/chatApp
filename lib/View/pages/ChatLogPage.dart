import 'dart:math';
import 'package:chat_app/Utils/CommonApi.dart';
import 'package:chat_app/Utils/CusAppBar.dart';
import 'package:chat_app/View/widgets/ChatBubble.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ChatLogPage extends StatefulWidget {
  const ChatLogPage({super.key});

  @override
  State<ChatLogPage> createState() => _ChatLogPageState();
}

class _ChatLogPageState extends State<ChatLogPage> {
  // 不能放在build里 否则失去焦点时会重新build 重新生成绑定Controller 导致输入框被清空
  final _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = context.arguments<Map<String, dynamic>>(); // 接收参数

    // 测试数据
    final messages = [
      Message(text: "你好呀", time: DateTime(2025, 10, 30, 9, 30), userId: '1'),
      Message(text: "早上好", time: DateTime(2025, 10, 30, 9, 32), userId: '222'),
      Message(
        text: "今天下午有空吗？",
        time: DateTime(2025, 10, 30, 14, 10),
        userId: '222',
      ),
      Message(text: "可以的", time: DateTime(2025, 10, 30, 14, 12), userId: '1'),
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
    ];

    return GestureDetector(
      onTap: () {
        // 让当前任何获得焦点的控件失焦
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
        body: ChatBubble(list: messages),
        bottomNavigationBar: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.fromLTRB(
            20.rpx,
            20.rpx,
            20.rpx,
            // 底部弹出输入法时 动态插入内边距 加20.rpx与输入法分开点距离
            max(MediaQuery.of(context).viewInsets.bottom + 20.rpx, 40.rpx),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '说点什么吧...', // 同placeholder
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.rpx),
                      borderSide: BorderSide.none, // 取消边框
                    ),
                    filled: true, // 开启填充 否则不生效
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.only(left: 20.rpx), // 内容框内边距
                  ),
                  textInputAction: TextInputAction.send, // 输入法回车设置为发送
                  onSubmitted: (value) {
                    // 发送后触发
                    if (value.trim().isNotEmpty) {
                      print("发送消息: $value");
                      _inputController.clear(); // 发送后清除输入内容
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.emoji_emotions_outlined),
                onPressed: () {},
              ),
              IconButton(icon: Icon(Icons.add), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
