import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'View/pages/MainPage.dart';
import 'Utils/CommonApi.dart';
import 'View/pages/ChatLogPage.dart';

void main() {
  // runApp内部会自动调用一次 但是如果要在runApp之前使用Flutter绑定的功能 需要手动调用（如初始化插件、调用平台通道、获取屏幕信息）
  // WidgetsFlutterBinding.ensureInitialized();
  // ScreenSize.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 屏幕旋转时会自动重新build
    ScreenSize.init(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[200],
          elevation: 0, // 去掉阴影
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 34.rpx,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // 沉浸式状态栏
            statusBarIconBrightness: Brightness.dark, // 状态栏黑色图标
          ),
        ),
      ),
      initialRoute: '/', // 指定了initialRoute后home会失效
      routes: {
        '/': (_) => const MainPage(),
        '/chat_log': (_) => const ChatLogPage(),
      },
      // 自定义路由跳转动画
      // onGenerateRoute: (settings) {
      //   WidgetBuilder builder;
      //   switch (settings.name) {
      //     case '/chat_log':
      //       builder = (_) => const ChatLogPage(title: '测试');
      //       break;
      //     default:
      //       builder = (_) => const MainPage();
      //   }
      //   return PageRouteBuilder(
      //     pageBuilder: (context, _, _) => builder(context),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       final p = Tween(
      //         begin: Offset(1, 0),
      //         end: Offset(0, 0),
      //       ).chain(CurveTween(curve: Curves.ease));
      //       return SlideTransition(position: animation.drive(p), child: child);
      //     },
      //   );
      // },
    );
  }
}
