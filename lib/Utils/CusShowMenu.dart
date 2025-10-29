import 'package:chat_app/Utils/CommonApi.dart';
import 'package:flutter/material.dart';

// 可选按钮位置
enum MenuPosition { top, bottom }

class CusShowMenu {
  final GlobalKey buttonKey;
  final BuildContext context;
  final MenuPosition menuPosition;
  final Color color;
  final List<PopupMenuItem> items;

  const CusShowMenu({
    required this.buttonKey,
    required this.context,
    required this.menuPosition,
    this.color = const Color(0xFF545454),
    required this.items,
  });

  void popMenu() {
    // 获取按钮节点对象
    final RenderBox btn =
        buttonKey.currentContext!.findRenderObject() as RenderBox;
    // 获得相对于屏幕左上角的坐标
    // 注：不传ancestor参数 默认相对于整个屏幕左上角 ancestor表示参考节点
    final Offset offset = btn.localToGlobal(Offset.zero);
    // 弹出菜单
    showMenu(
      context: context,
      // Menu相对于屏幕的边距
      position: _getPosition(offset, btn),
      color: color,
      menuPadding: EdgeInsets.all(0), // 去除默认内边距
      shape: MenuShape(triangleOffset: 20.rpx, menuPosition: menuPosition),
      items: items,
    );
  }

  RelativeRect _getPosition(Offset offset, RenderBox btn) {
    switch (menuPosition) {
      case MenuPosition.bottom:
        return RelativeRect.fromLTRB(
          // offset是按钮左上角坐标 但是showMenu会自动计算 避免超出屏幕 所以实际效果是贴着屏幕边缘
          (offset.dx * 2).rpx, // left 距离屏幕左边缘位置
          // top 位置在按钮下方 所以要加上按钮高度
          ((offset.dy + btn.size.height) * 2).rpx,
          0, // right 距离屏幕右边缘位置 只要确定了前两个值后两个可以忽略
          0, // bottom 一旦top确定 bottom会被忽略
        );
      case MenuPosition.top:
        return RelativeRect.fromLTRB(
          (offset.dx * 2).rpx,
          0,
          0,
          (offset.dy * 2).rpx,
        );
    }
  }
}

// 因为是自定义图形 所以只能用继承类的形式 如果是常规图形 可以定义方法返回ShapeBorder的子类实例
class MenuShape extends ShapeBorder {
  final double borderRadius; // 圆角半径
  final double triangleSize; // 三角形的边长
  final double triangleOffset; // 三角形距离右侧的偏移量
  final MenuPosition menuPosition;

  const MenuShape({
    this.borderRadius = 8,
    this.triangleSize = 10,
    this.triangleOffset = 20,
    required this.menuPosition,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => this;

  // 外边框
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // 先绘制整体图形
    final path = Path()
      ..moveTo(rect.left + borderRadius, rect.top) // 从左上角开始 移动到圆角起点
      ..arcToPoint(
        Offset(rect.left, rect.top + borderRadius),
        radius: Radius.circular(borderRadius),
        clockwise: false, // 逆时针画圆角
      ) // 画圆角
      ..lineTo(rect.left, rect.bottom - borderRadius)
      ..arcToPoint(
        Offset(rect.left + borderRadius, rect.bottom),
        radius: Radius.circular(borderRadius),
        clockwise: false,
      )
      ..lineTo(rect.right - borderRadius, rect.bottom)
      ..arcToPoint(
        Offset(rect.right, rect.bottom - borderRadius),
        radius: Radius.circular(borderRadius),
        clockwise: false,
      )
      ..lineTo(rect.right, rect.top + borderRadius)
      ..arcToPoint(
        Offset(rect.right - borderRadius, rect.top),
        radius: Radius.circular(borderRadius),
        clockwise: false,
      )
      ..close();
    // 区分画小三角位置
    switch (menuPosition) {
      case MenuPosition.bottom:
        path
          ..moveTo(rect.right - triangleOffset, rect.top)
          ..lineTo(
            rect.right - triangleOffset - triangleSize / 2,
            rect.top - triangleSize / 2,
          ) // 三角顶点
          ..lineTo(
            rect.right - triangleOffset - triangleSize,
            rect.top,
          ) // 三角左侧点
          ..close();
        break;
      case MenuPosition.top:
        path
          ..moveTo(rect.right - triangleOffset, rect.bottom)
          ..lineTo(
            rect.right - triangleOffset - triangleSize / 2,
            rect.bottom + triangleSize / 2,
          )
          ..lineTo(rect.right - triangleOffset - triangleSize, rect.bottom)
          ..close();
        break;
    }
    return path;
  }

  // 内部裁剪
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}
