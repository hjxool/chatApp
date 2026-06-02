// 放请求接口 通常是封装 http 调用
import 'package:chat_app/data_models/net/dio_client.dart';
import '../models/user.dart';

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
