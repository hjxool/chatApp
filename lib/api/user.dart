import 'package:chat_app/api/dio_client.dart';

// 放纯数据模型
class User {
  final String userId;
  final bool? noDisturb;

  const User({required this.userId, this.noDisturb});
  // 通常带有 fromJson / toJson
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String, // 因为是dynamic 这里加as是保证类型安全
      noDisturb: json['noDisturb'] as bool?, // bool? 表示可为空
    );
  }
  Map<String, dynamic> toJson() => {
    'userId': userId, // dart中因为不存在全局变量 因此在不产生命名冲突时 可以省略this
    'noDisturb': noDisturb,
  };
  User copyWith({String? userId, bool? noDisturb}) => User(
    userId: userId ?? this.userId, // 这里跟局部变量有命名冲突 所以加this
    noDisturb: noDisturb ?? this.noDisturb,
  );
}

// 放请求接口 通常是封装 http 调用
class UserApi {
  UserApi._(); // 构造函数私有化 防止创建实例

  static Future<List<User>> fetchUser({String? userId}) async {
    final dio = DioClient().dio;
    final data = await dio.get('path').then((res) => res.data).catchError((
      err,
    ) {
      // 测试数据
      return List.generate(
        3,
        (index) => User(userId: '$index$index$index', noDisturb: false),
      );
    });
    return (data as List).map((e) => User.fromJson(e)).toList();
  }
}
