import 'package:flutter/widgets.dart';

// 全局版本
// class ScreenSize with WidgetsBindingObserver {
//   static late double width;
//   static late double height;
//   static late double scaleWidth;
//   static late double designWidth;
//   // 单例模式 因为注册监听器需要一个不会变的实例
//   static final ScreenSize _instance = ScreenSize();
//   factory ScreenSize() => _instance;

//   static void init({double designWidth = 750}) {
//     ScreenSize.designWidth = designWidth;
//     _updateSize();
//     // 注册监听器
//     WidgetsBinding.instance.addObserver(_instance);
//   }

//   static void _updateSize() {
//     // 访问 platformDispatcher.views.first 会触发 didChangeMetrics 事件 导致死循环
//     final view = WidgetsBinding.instance.platformDispatcher.views.first;
//     // WidgetsBinding只能获取到物理像素 除以设备像素比 得到逻辑像素
//     final logicalSize = view.physicalSize / view.devicePixelRatio;
//     width = logicalSize.width;
//     height = logicalSize.height;
//     scaleWidth = width / designWidth;

//     print('屏幕尺寸更新: width=$width, height=$height');
//   }

//   // 屏幕尺寸变化时触发
//   @override
//   void didChangeMetrics() {
//     _updateSize();
//   }
// }

// 使用context版本
class ScreenSize {
  static late double width;
  static late double height;
  static late double scaleWidth;
  static void init(BuildContext context, {double designWidth = 750}) {
    final size = MediaQuery.of(context).size;
    width = (size.width * 100).round() / 100;
    height = (size.height * 100).round() / 100;
    scaleWidth = (width / designWidth * 100).round() / 100;

    print('屏幕尺寸: width=$width, height=$height, scaleWidth=$scaleWidth');
  }
}

extension CusRpx on num {
  double get rpx => this * ScreenSize.scaleWidth;
}
