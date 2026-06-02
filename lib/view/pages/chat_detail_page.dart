import 'package:chat_app/data_models/models/user.dart';
import 'package:chat_app/providers/global_config.dart';
import 'package:chat_app/utils/common_api.dart';
import 'package:chat_app/utils/cus_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatDetailPage extends ConsumerWidget {
  const ChatDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = context.arguments<Map<String, dynamic>>();
    // select 监听特定属性变化
    final curUser = ref.watch(
      UserConfigProvider.select((state) {
        print('state.value.userInfos:${state.value?.userInfos}');
        return state.value?.userInfos?.firstWhere(
          (e) => e.userId == args?['userId'],
          orElse: () => User(userId: '', noDisturb: true),
        );
      }),
    );

    return Scaffold(
      appBar: CusAppBar(title: '详情'),
      body: Container(
        color: Colors.grey[200],
        child: ref
            .watch(UserConfigProvider)
            .when(
              data: (_) => Column(
                children: [
                  rowStyle(
                    '查找聊天内容',
                    newline: true,
                    icon: Icons.arrow_forward_ios,
                  ),
                  rowStyle(
                    '消息免打扰',
                    onOff: switchStyle(curUser?.noDisturb ?? false, (value) {
                      ref
                          .read(UserConfigProvider.notifier)
                          .setUserInfo(args?['userId'] ?? '', noDisturb: value);
                    }),
                  ),
                  rowStyle('置顶聊天'),
                ],
              ),
              error: (err, _) => Center(child: Text('加载失败: $err')),
              loading: () => null,
            ),
      ),
      // body: ref.watch(UserConfigProvider).when(data: data, error: error, loading: loading),
    );
  }

  // 构建行内相同样式
  Widget rowStyle(
    String label, {
    IconData? icon,
    bool newline = false,
    Widget? onOff,
  }) {
    return Container(
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
    );
  }

  // 开关统一样式
  Widget switchStyle(bool value, void Function(bool) onChanged) {
    return CupertinoSwitch(value: value, onChanged: onChanged);
  }
}
