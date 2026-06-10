import 'package:flutter/widgets.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';

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

    // print('屏幕尺寸: width=$width, height=$height, scaleWidth=$scaleWidth');
  }
}

// 给数字类型添加拓展属性
extension CusRpx on num {
  // this 调用者
  double get rpx => this * ScreenSize.scaleWidth;
}

// 路由传参语法糖
extension RouteArgs on BuildContext {
  T? arguments<T>() {
    return ModalRoute.of(this)?.settings.arguments as T;
  }
}

// 全局日志函数
void consoleLog(String message, {String? tag, Object? obj}) {
  if (tag == null) {
    developer.log(message, error: _toJson(obj));
  } else {
    developer.log(message, name: tag, error: _toJson(obj));
  }
}

dynamic _toJson(dynamic obj) {
  switch (obj) {
    case Map():
      // 这里返回的已经是Map类型 不需要调用toList
      return obj.map((key, value) => MapEntry(key.toString(), _toJson(value)));
    case Iterable():
      // Iterable内定义的mao和Map内定义的map不是同一个函数 因此这里要调用toList
      return obj.map((e) => _toJson(e)).toList();
    case num():
    case String():
    case bool():
      return obj;
    case DateTime():
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(obj);
    default:
      if (_hasToJson(obj)) {
        // 这样野生对象实现toJson就不用管内部嵌套的对象 只要外层字段齐全就行
        return _toJson(obj.toJson());
      } else {
        return obj.toString();
      }
  }
}

bool _hasToJson(dynamic obj) {
  try {
    return obj?.toJson != null;
  } catch (e) {
    return false;
  }
}

typedef JsonMap = Map<String, dynamic>;
