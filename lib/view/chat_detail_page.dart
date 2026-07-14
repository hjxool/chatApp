import 'package:chat_app/models/user.dart';
import 'package:chat_app/providers/global_notifier.dart';
import 'package:chat_app/components/common_api.dart';
import 'package:chat_app/components/cus_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/components/popup.dart';

class ChatDetailPage extends ConsumerWidget {
  const ChatDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = context.arguments<JsonMap>();
    // #region
    // select 监听特定属性变化
    // 会执行两次select 一次是修改状态后 一次是下面watch触发build重新执行到select时 因为很冗余这里不需要select
    // final curUser = ref.watch(
    //   UserConfigProvider.select((state) {
    //     return state.value?.userInfos?.firstWhere(
    //       (e) => e.userId == args?['userId'],
    //       orElse: () => User(userId: '', noDisturb: true, isTop: true),
    //     );
    //   }),
    // );
    // #endregion

    // 组件只保留一个watch监听整个异步状态
    final configState = ref.watch(UserConfigProvider);

    return Scaffold(
      appBar: CusAppBar(title: '详情'),
      body: Container(
        color: Colors.grey[200],
        child: configState.when(
          data: (data) {
            consoleLog('用户详情', obj: data.userInfos);
            final curUser = data.userInfos?.firstWhere(
              (e) => e.userId == args?['userId'],
              orElse: () => User(userId: '', noDisturb: true, isTop: true),
            );
            return Column(
              children: [
                rowStyle(
                  '查找聊天内容',
                  newline: true,
                  icon: Icons.arrow_forward_ios,
                ),
                rowStyle(
                  '消息免打扰',
                  onOff: CupertinoSwitch(
                    value: curUser?.noDisturb ?? false,
                    onChanged: (value) {
                      ref
                          .read(UserConfigProvider.notifier)
                          .setUserInfo(args?['userId'] ?? '', noDisturb: value);
                    },
                  ),
                ),
                rowStyle(
                  '置顶聊天',
                  newline: true,
                  onOff: CupertinoSwitch(
                    value: curUser?.isTop ?? false,
                    onChanged: (value) {
                      ref
                          .read(UserConfigProvider.notifier)
                          .setUserInfo(args?['userId'] ?? '', isTop: value);
                    },
                  ),
                ),
                rowStyle(
                  '设置当前聊天背景',
                  newline: true,
                  icon: Icons.arrow_forward_ios,
                ),
                rowStyle('清空聊天记录', newline: false, context: context),
              ],
            );
          },
          error: (err, _) => Center(child: Text('加载失败: $err')),
          loading: () => null,
        ),
      ),
    );
  }

  // 构建行内相同样式
  Widget rowStyle(
    String label, {
    IconData? icon,
    bool newline = false,
    Widget? onOff,
    BuildContext? context,
  }) {
    return GestureDetector(
      onTap: () {
        consoleLog('点击了$label', tag: '详情页点击');
        if (label == '清空聊天记录') {
          final List<PopItem> items = [
            PopItem(
              label: '清空聊天记录',
              color: Colors.red[300],
              onTap: (e) => consoleLog('底部弹窗事件', obj: e),
            ),
          ];
          popBottom(context: context!, items: items);
        }
      },
      child: Container(
        height: 120.rpx,
        padding: EdgeInsets.symmetric(horizontal: 20.rpx),
        margin: newline ? EdgeInsets.only(bottom: 12.rpx) : null,
        decoration: BoxDecoration(
          color: Colors.white,
          border: newline
              ? null
              : BoxBorder.fromLTRB(
                  bottom: BorderSide(color: Color(0xFFE5E5E5), width: 2.rpx),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.black87, fontSize: 32.rpx),
            ),
            if (icon != null) Icon(icon, size: 32.rpx, color: Colors.grey[400]),
            if (onOff != null) onOff,
          ],
        ),
      ),
    );
  }
}
