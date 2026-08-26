// 全局设置请求拦截器等通用配置
import 'package:chat_app/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// 单例模式
// 使用示例 dio = DioClient().dio
// class DioClient {
//   // 注意！工厂函数 必须 返回当前类或其子类实例 不能是其他类！
//   // 所以这里要继承Dio类 并用super将配置项传给父类(弃用) 因为要实现一大堆抽象方法 改为组合使用
//   static final DioClient _instance = DioClient._internal();
//   late Dio dio;
//   static String? _token;

//   factory DioClient() => _instance;

//   DioClient._internal() {
//     dio = Dio(
//       BaseOptions(
//         baseUrl: 'http://192.168.137.136:8080',
//         connectTimeout: const Duration(seconds: 5),
//         receiveTimeout: const Duration(seconds: 5),
//         headers: {'Content-Type': 'application/json'},
//       ),
//     );
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         // 这是拦截器 因此每次请求都会读最新的token
//         // 不能直接在拦截器里返回response.data 因此要传入的类型是Response
//         onRequest: (options, handler) {
//           if (_token != null) {
//             // 这里其实修改的就是实例身上的options
//             options.headers['Authorization'] = 'Bearer $_token';
//           }
//           return handler.next(options);
//         },
//       ),
//     );
//   }

//   static void updateToken(String token) {
//     _token = token;
//   }
// }

// 改成全局模式
// 私有的 Token 变量，只在这个文件内可见
String? _token;
// 直接定义并导出配置好的 dio 实例（去掉 class，直接挂载配置）
final dio =
    Dio(
        BaseOptions(
          baseUrl: 'http://192.168.137.176:8080',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {'Content-Type': 'application/json'},
        ),
      )
      ..interceptors.add(
        InterceptorsWrapper(
          // 添加请求头
          onRequest: (options, handler) {
            if (_token != null) {
              options.headers['Authorization'] = 'Bearer $_token';
            }
            return handler.next(options);
          },
          // 过滤响应结果
          onResponse: (response, handler) {
            final data = response.data;
            if (data is Map) {
              final code = data['head']?['code'] ?? data['code'];
              final body = data['body'];
              // 剥离外层head 只返回布尔值或实际数据
              if (code == 200 || code == '200') {
                // 若 body 为 null、空 Map 或空 List/String，则返回 true，否则返回具体 body
                if (body == null ||
                    (body is Map && body.isEmpty) ||
                    (body is Iterable && body.isEmpty) ||
                    (body is String && body.trim().isEmpty)) {
                  response.data = true;
                } else {
                  response.data = body;
                }
              } else {
                // 业务失败 (code 为 200 以外的值)
                final errorMsg =
                    data['head']?['message'] ?? data['message'] ?? '请求失败，请稍后重试';
                _showErrorDialog(errorMsg.toString());
                response.data = false;
              }
            }
            return handler.next(response);
          },
          // 处理网络请求异常 200–299 以外的响应会进入onError
          onError: (error, handler) {
            String errorMsg = '网络好像有点问题，请检查网络设置';
            if (error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout) {
              errorMsg = '网络连接超时';
            } else if (error.response != null) {
              // HTTP 状态码错误
              final responseData = error.response?.data;
              if (responseData is Map) {
                errorMsg =
                    (responseData['head']?['message'] ??
                            responseData['message'] ??
                            '服务器异常 (${error.response?.statusCode})')
                        .toString();
              } else {
                errorMsg = '服务器异常 (${error.response?.statusCode})';
              }
            }
            _showErrorDialog(errorMsg);
            // 将网络异常转换为普通成功响应返回 false，不再抛出异常给业务层
            return handler.resolve(
              Response(requestOptions: error.requestOptions, data: false),
            );
          },
        ),
      );

// 导出一个修改 Token 的全局函数
void updateToken(String token) {
  _token = token;
}

// 提取统一弹窗的私有函数
void _showErrorDialog(String message) {
  // 从全局 navigatorKey 中获取当前最顶层的 context
  final context = navigatorKey.currentContext;
  if (context == null) return;
  // 使用 WidgetsBinding 确保在当前帧渲染完成后再弹窗，防止在请求极快时与页面构建产生冲突
  // WidgetsBinding 是应用级别的绑定对象，而不是某个 Widget 的实例 用于将 Widget层和 Flutter Engine（渲染层）绑定起来
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: true, // 点击背景可以关闭
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('提示'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            // Navigator.of 找到的是和当前 BuildContext 最近的 Navigator
            // navigatorKey.currentState 操作的是全局 Navigator 用全局的容易导致路由页面也关掉
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  });
}
