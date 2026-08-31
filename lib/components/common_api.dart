import 'package:flutter/widgets.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';

// 使用context版本
class ScreenSize {
  static double width = 375;
  static double height = 812;
  static double scaleWidth = 375 / 750; // 默认缩放比 0.5，防止 ThemeData 等在 init 执行前访问 .rpx 抛出 LateInitializationError

  static void init(BuildContext context, {double designWidth = 750}) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return;
    final size = mediaQuery.size;
    if (size.width == 0) return;
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

// 登陆账号类型
enum AccountType { email, phone, invalid }

// 账号类型识别与正则校验
AccountType checkAccountType(String input) {
  final text = input.trim();
  if (text.isEmpty) return AccountType.invalid;
  // r'...' 代表原始字符串 作用是让字符串内的反斜杠 \ 保持原样，不需要写成 \\ 来转义
  final phoneRegex = RegExp(
    r'^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$',
  );
  // 里面有单引号外面用双引号
  final emailRegex = RegExp(r"^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$");
  if (phoneRegex.hasMatch(text)) {
    return AccountType.phone;
  } else if (emailRegex.hasMatch(text)) {
    return AccountType.email;
  }
  return AccountType.invalid;
}
