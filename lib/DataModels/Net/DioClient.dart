// 全局设置请求拦截器等通用配置
import 'package:dio/dio.dart';

// 单例模式
// 使用示例 dio = DioClient().dio
class DioClient {
  // 注意！工厂函数 必须 返回当前类或其子类实例 不能是其他类！
  // 所以这里要继承Dio类 并用super将配置项传给父类(弃用) 因为要实现一大堆抽象方法 改为组合使用
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  static String? _token;

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        // 这是拦截器 因此每次请求都会读最新的token
        // 不能直接在拦截器里返回response.data 因此要传入的类型是Response
        onRequest: (options, handler) {
          if (_token != null) {
            // 这里其实修改的就是实例身上的options
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  static void updateToken(String token) {
    _token = token;
  }
}
