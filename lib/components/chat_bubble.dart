import 'package:chat_app/providers/global_notifier.dart';
import 'package:chat_app/components/common_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class Message {
  final String text;
  final DateTime time;
  final String userId;

  Message({required this.text, required this.time, required this.userId});
}

class ChatBubble extends ConsumerWidget {
  final List<Message> list;

  const ChatBubble({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConfig = ref.watch(UserConfigProvider);

    return asyncConfig.when(
      data: (data) {
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            final msg = list[index];
            final showDate =
                index == 0 || !isSameTime(msg.time, list[index - 1].time);

            return Column(
              children: [
                if (showDate) dateStyle(msg.time),
                messageStyle(msg, data.userId ?? '', index),
              ],
            );
          },
        );
      },
      error: (err, stack) => Text('加载失败: $err'),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  // 判断是否为同一天 则合并日期显示
  bool isSameTime(DateTime current, DateTime previous) {
    // 使用 difference 计算时间差 inMinutes 返回相差的整分钟数
    // 使用 abs() 防止时间顺序错乱导致的负数问题
    return current.difference(previous).inMinutes.abs() < 5;
  }

  // 日期样式
  Widget dateStyle(DateTime date) {
    final str = DateFormat('yyyy年MM月dd日 EEEE HH:mm', 'zh_CN').format(date);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.rpx, horizontal: 20.rpx),
      alignment: Alignment.center,
      child: Text(
        str,
        style: TextStyle(
          color: Color.fromRGBO(159, 159, 161, 1),
          fontSize: 28.rpx,
        ),
      ),
    );
  }

  // 消息气泡
  Widget messageStyle(Message msg, String userId, int index) {
    final double margin = 100.rpx; // 消息气泡与屏幕边缘的最小距离

    // 外层用Column 这里用Align区分贴边
    return Align(
      // 区分贴边位置
      alignment: userId == msg.userId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        // 根据发送者调整外边距
        padding: userId == msg.userId
            ? EdgeInsets.fromLTRB(margin, 6.rpx, 40.rpx, 6.rpx)
            : EdgeInsets.fromLTRB(40.rpx, 6.rpx, margin, 6.rpx),
        child: CustomPaint(
          painter: BubblePainter(
            isMe: userId == msg.userId,
            color: userId == msg.userId
                ? Color.fromRGBO(102, 196, 102, 1)
                : Color.fromRGBO(233, 233, 235, 1),
            showTail: showTail(list, index),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.rpx, horizontal: 28.rpx),
            child: Text(
              msg.text,
              style: TextStyle(
                color: userId == msg.userId ? Colors.white : Colors.black87,
                fontSize: 32.rpx,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 判断是否为最后一条消息或是换人 以此显示消息气泡尾巴
  bool showTail(List<Message> list, int index) {
    if (index == list.length - 1) return true;
    final cur = list[index];
    final next = list[index + 1];
    return cur.userId != next.userId;
  }
}

class BubblePainter extends CustomPainter {
  final bool isMe;
  final Color color;
  final double _radius = 16.rpx;
  final bool showTail;

  BubblePainter({
    required this.isMe,
    required this.color,
    required this.showTail,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color; // 画笔颜色
    // 绘制整体图形
    final path = Path()
      ..moveTo(0, _radius)
      ..arcToPoint(Offset(_radius, 0), radius: Radius.circular(_radius))
      ..lineTo(size.width - _radius, 0)
      ..arcToPoint(
        Offset(size.width, _radius),
        radius: Radius.circular(_radius),
      )
      ..lineTo(size.width, size.height - _radius)
      ..arcToPoint(
        Offset(size.width - _radius, size.height),
        radius: Radius.circular(_radius),
      )
      ..lineTo(_radius, size.height)
      ..arcToPoint(
        Offset(0, size.height - _radius),
        radius: Radius.circular(_radius),
      );

    if (showTail) {
      // 绘制尖角
      if (isMe) {
        path
          ..moveTo(size.width, size.height - _radius)
          ..quadraticBezierTo(
            size.width + 10.rpx,
            size.height - _radius + 20.rpx,
            size.width + 20.rpx,
            size.height - _radius + 20.rpx,
          )
          ..quadraticBezierTo(
            size.width,
            size.height,
            size.width - _radius,
            size.height,
          )
          ..close();
      } else {
        // path填充规则：如果一个区域被路径包围的方向一致（顺时针或逆时针） 它会被填充
        // 而图形主体是顺时针绘制 因此镜像的左侧尖角(逆时针)绘制重叠部分会裁剪
        path
          ..moveTo(_radius, size.height)
          ..quadraticBezierTo(
            0,
            size.height,
            -20.rpx,
            size.height - _radius + 20.rpx,
          )
          ..quadraticBezierTo(
            -10.rpx,
            size.height - _radius + 20.rpx,
            0,
            size.height - _radius,
          )
          ..close();
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
