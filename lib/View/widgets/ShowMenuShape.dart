import 'package:flutter/material.dart';

class ShowMenuShape extends ShapeBorder {
  final double borderRadius; // 圆角半径
  final double triangleSize; // 三角形的边长
  final double triangleOffset; // 三角形距离右侧的偏移量

  const ShowMenuShape({
    this.borderRadius = 8,
    this.triangleSize = 10,
    this.triangleOffset = 20,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => this;

  // 外边框
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
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
      ..lineTo(rect.right - triangleOffset, rect.top) // 开始画三角
      ..lineTo(
        rect.right - triangleOffset - triangleSize / 2,
        rect.top - triangleSize,
      ) // 三角顶点
      ..lineTo(rect.right - triangleOffset - triangleSize, rect.top) // 三角左侧点
      ..close(); // 闭合路径

    return path;
  }

  // 内部裁剪
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}
