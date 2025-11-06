// 放请求接口 通常是封装 http 调用
import 'package:chat_app/DataModels/Net/DioClient.dart';
import '../models/placeholder.dart';

class UserApi {
  final String baseUrl;

  UserApi(this.baseUrl);

  Future<User> fetchUser(String userId) async {
    final dio = DioClient().dio;
    final data = await dio
        .get('path')
        .then((res) => res.data)
        .catchError((err) => print(err));
    return User.fromJson(data);
  }
}
