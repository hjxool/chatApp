import 'package:flutter/material.dart';
import 'rpx.dart';

class BadgeIcon extends StatelessWidget {
  final int badgeCount;
  final Widget icon;
  const BadgeIcon({super.key, required this.badgeCount, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // 默认会裁剪溢出部分
      children: [
        icon,
        if (badgeCount > 0)
          Positioned(
            right: -4.rpx,
            top: -4.rpx,
            child: CircleAvatar(
              radius: 12.rpx,
              backgroundColor: Colors.red,
              child: FittedBox(
                // 自动缩放文字 防止溢出无法居中
                fit: BoxFit.scaleDown,
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 20.rpx,
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
