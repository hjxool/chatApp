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
  bool showExtra = false; // 滑入显示功能面板
  final double extraPanelSize = 330.rpx;

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
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
      Message(text: "明天见", time: DateTime(2025, 10, 31, 10, 0), userId: '222'),
    ];

    double bottom = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        // 让当前任何获得焦点的控件失焦
        FocusScope.of(context).unfocus();
        setState(() {
          showExtra = false;
        });
      },
      child: Scaffold(
        // 默认为true 当软键盘弹出时会自动调整body高度
        // 此处设置为false 是因为bottomNavigationBar不会随之自动调整高度所以配合手动计算
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
        body: Stack(
          children: [
            // 主内容区域
            Column(
              children: [
                Expanded(child: ChatBubble(list: messages)),
                // 底部输入框区域
                // 滑入需要手动定位 这里添加过渡垫高
                AnimatedPadding(
                  duration: Duration(milliseconds: aniDuration(bottom)),
                  padding: EdgeInsetsGeometry.only(
                    bottom: showExtra ? max(extraPanelSize, bottom) : bottom,
                  ),
                  child: Container(
                    color: Colors.grey[200],
                    padding: EdgeInsets.fromLTRB(
                      0,
                      20.rpx,
                      20.rpx,
                      // 底部弹出输入法时 动态插入内边距 加20.rpx与输入法分开点距离
                      // max(MediaQuery.of(context).viewInsets.bottom + 20.rpx, 40.rpx),
                      bottom > 0 ? 10.rpx : 40.rpx,
                    ),
                    child: Row(
                      children: [
                        IconButton(onPressed: null, icon: Icon(Icons.mic)),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                        ),
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
                              contentPadding: EdgeInsets.only(
                                left: 20.rpx,
                              ), // 内容框内边距
                            ),
                            textInputAction: TextInputAction.send, // 输入法回车设置为发送
                            onSubmitted: (value) {
                              // 发送后触发 onSubmitted的默认行为会清除输入框焦点自动收齐软键盘
                              if (value.trim().isNotEmpty) {
                                print("发送消息: $value");
                                _inputController.clear(); // 发送后清除输入内容
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            // 如果软键盘展开则延迟滑入面板
                            if (bottom > 0) {
                              FocusScope.of(context).unfocus();
                              if (!showExtra) {
                                setState(() {
                                  showExtra = true;
                                });
                              }
                            } else {
                              setState(() {
                                showExtra = !showExtra;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 想用滑入的方式只能用绝对定位 如果放在Column参与布局只能做伸缩动画
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: 0,
              right: 0,
              bottom: showExtra ? 0 : -extraPanelSize,
              child: Container(
                height: extraPanelSize,
                color: Colors.grey[200],
                child: const Center(child: Text("附加功能面板")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 根据软键盘是否展开以及面板是否显示 综合判断输入框部分动画延迟
  int aniDuration(double bottom) {
    if (showExtra) {
      // 面板展开
      if (bottom > 0) {
        // 软键盘展开
        return 0;
      }
    } else {
      // 面板隐藏
      if (bottom > 0) {
        return 0;
      }
    }
    return 300;
  }
}
