import 'package:chat_app/models/dio_client.dart';
import 'package:chat_app/components/common_api.dart';

// 放纯数据模型
// 单个用户/好友的数据模型
class User {
  final String userId;
  final String? username;
  final String? email;
  final String? phone;
  final bool? noDisturb;
  final bool? isTop;

  const User({
    required this.userId,
    this.username,
    this.email,
    this.phone,
    this.noDisturb,
    this.isTop,
  });

  factory User.fromJson(JsonMap json) {
    return User(
      userId: json['userId'].toString(),
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      noDisturb: json['noDisturb'] as bool?,
      isTop: json['isTop'] as bool?,
    );
  }

  JsonMap toJson() => {
    'userId': userId,
    'username': username,
    'email': email,
    'phone': phone,
    'noDisturb': noDisturb,
    'isTop': isTop,
  };

  User copyWith({
    String? userId,
    String? username,
    String? email,
    String? phone,
    bool? noDisturb,
    bool? isTop,
  }) => User(
    userId: userId ?? this.userId,
    username: username ?? this.username,
    email: email ?? this.email,
    phone: phone ?? this.phone,
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
        .then((res) => res.data);
    if (data is! Map) return null;
    final token = data['token'] as String?;
    return (token == null || token.isEmpty) ? null : token; // 把空字符串的情况也处理成null
  }

  // 发送验证码
  static Future<bool> sendCode({
    required String target,
    required String type,
  }) async {
    bool data = await dio
        .post('/api/sendCode', data: {'target': target, 'type': type})
        .then((res) => res.data);
    return data;
  }

  // 验证验证码（独立验证，用于找回密码场景）
  static Future<bool> verifyCode({
    required String target,
    required String code,
  }) async {
    bool data = await dio
        .post('/api/verifyCode', data: {'target': target, 'code': code})
        .then((res) => res.data);
    return data;
  }

  // 注册（后端在 register 接口内部会再验一次 code）
  static Future<bool> register({
    required String username,
    required String password,
    required String target,
    required String code,
  }) async {
    final data = await dio
        .post(
          '/api/register',
          data: {
            'username': username,
            'password': password,
            'target': target,
            'code': code,
          },
        )
        .then((res) => res.data);
    return data is Map; // 注册成功返回 {id, username}
  }
}

// 账号级全局配置状态模型
class UserConfigState {
  final String? userId;
  final List<User>? userInfos;

  const UserConfigState({this.userId, this.userInfos});
}
