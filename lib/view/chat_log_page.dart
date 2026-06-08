import 'package:chat_app/components/common_api.dart';
import 'package:chat_app/components/cus_app_bar.dart';
import 'package:chat_app/components/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:developer' as developer;

class ChatLogPage extends StatefulWidget {
  const ChatLogPage({super.key});

  @override
  State<ChatLogPage> createState() => _ChatLogPageState();
}

class _ChatLogPageState extends State<ChatLogPage> {
  // 不能放在build里 否则失去焦点时会重新build 重新生成绑定Controller 导致输入框被清空
  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();
  bool showExtra = false; // 滑入显示功能面板
  final double extraPanelSize = 330.rpx;

  @override
  Widget build(BuildContext context) {
    final args = context.arguments<Map<String, dynamic>>(); // 接收参数
    double bottom = MediaQuery.of(context).viewInsets.bottom;
    // 测试数据
    final messages = [
      Message(text: "你好呀", time: DateTime(2025, 10, 30, 9, 30), userId: '1'),
      Message(text: "早上好", time: DateTime(2025, 10, 30, 9, 32), userId: '222'),
      Message(
        text:
            "今天下午有空吗？asmdoiajsiodjasiojdasjdioasjdiojwihidsuniuanbsduiasnduiansdiunasdnasnuduiasndui",
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

    // double bottom = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        // 让当前任何获得焦点的控件失焦
        _inputFocus.unfocus();
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
              onPressed: () => Navigator.pushNamed(
                context,
                '/chat_detail',
                arguments: {'userId': args?['userId'] ?? ''},
              ),
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
                  duration: Duration(milliseconds: bottom > 0 ? 0 : 300),
                  padding: EdgeInsetsGeometry.only(
                    bottom: bottom > 0
                        ? bottom
                        : (showExtra ? extraPanelSize : 0),
                  ),
                  child: Container(
                    color: Colors.grey[200],
                    padding: EdgeInsets.fromLTRB(
                      20.rpx,
                      20.rpx,
                      20.rpx,
                      // 底部弹出输入法时 动态插入内边距 加20.rpx与输入法分开点距离
                      // max(MediaQuery.of(context).viewInsets.bottom + 20.rpx, 40.rpx),
                      (bottom > 0 || showExtra) ? 10.rpx : 40.rpx,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController, // 输入框内容
                            focusNode: _inputFocus, // 焦点 跟软键盘有关
                            maxLines: null,
                            decoration: InputDecoration(
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
                                developer.log(
                                  "发送消息: $value",
                                  name: 'ChatLogPage',
                                );
                                _inputController.clear(); // 发送后清除输入内容
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (bottom > 0) {
                              _inputFocus.unfocus();
                              setState(() {
                                showExtra = true;
                              });
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
              // 不显示软键盘时才显示动画过渡
              duration: Duration(milliseconds: bottom == 0 ? 300 : 0),
              left: 0,
              right: 0,
              bottom: showExtra ? 0 : -extraPanelSize,
              height: bottom > 0 ? bottom : extraPanelSize,
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
