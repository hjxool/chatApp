import 'package:chat_app/api/dio_client.dart';
import 'package:chat_app/components/common_api.dart';

// 放纯数据模型
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

  static Future<List<User>> fetchUser({String? userId}) async {
    final dio = DioClient().dio;
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
}
