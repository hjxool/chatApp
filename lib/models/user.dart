import 'package:chat_app/main.dart';
import 'package:chat_app/models/dio_client.dart';
import 'package:chat_app/components/common_api.dart';

// 放纯数据模型
// 单个用户/好友的数据模型
class User {
  final String userId;
  final bool? noDisturb;
  final bool? isTop;

  const User({required this.userId, this.noDisturb, this.isTop});
  // 通常带有 fromJson / toJson
  factory User.fromJson(JsonMap json) {
    return User(
      userId: json['userId'] as String, // 因为是dynamic 这里加as是保证类型安全
      noDisturb: json['noDisturb'] == true, // 有些接口可能返回1/0或者null 这里做兼容处理
      isTop: json['isTop'] == true,
    );
  }
  JsonMap toJson() => {
    'userId': userId, // dart中因为不存在全局变量 因此在不产生命名冲突时 可以省略this
    'noDisturb': noDisturb,
    'isTop': isTop,
  };
  User copyWith({String? userId, bool? noDisturb, bool? isTop}) => User(
    userId: userId ?? this.userId, // 这里跟局部变量有命名冲突 所以加this
    noDisturb: noDisturb ?? this.noDisturb,
    isTop: isTop ?? this.isTop,
  );
}

// 放请求接口 通常是封装 http 调用
class UserApi {
  UserApi._(); // 构造函数私有化 防止创建实例

  // 模板
  static Future<List<User>> fetchUserInfos({String? userId}) async {
    final data = await dio.get('path').then((res) => res.data).catchError((
      err,
    ) {
      // 测试数据
      return List.generate(
        3,
        (index) => {
          'userId': '$index$index$index',
          'noDisturb': false,
          'isTop': false,
        },
      );
    });
    return (data as List<JsonMap>).map((e) => User.fromJson(e)).toList();
  }

  // 登录接口
  static Future<String?> login({
    required String username,
    required String password,
  }) async {
    final data = await dio
        .post('/api/login', data: {'username': username, 'password': password})
        .then((res) => res.data)
        .catchError((err) {
          consoleLog('登录接口请求失败，详细错误: $err', tag: '登录接口');
          return null;
        });
    if (data == null) return data;
    final token = data['body']['token'] as String?;
    return token!.isEmpty ? null : token; // 把空字符串的情况也处理成null
  }
}

// 账号级全局配置状态模型
class UserConfigState {
  final String? userId;
  final List<User>? userInfos;

  const UserConfigState({this.userId, this.userInfos});
}
