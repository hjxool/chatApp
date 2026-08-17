import 'package:chat_app/view/forgot_password_page.dart';
import 'package:chat_app/view/register_page.dart';
import 'package:chat_app/view/root_auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'components/common_api.dart';
import 'view/chat_log_page.dart';
import 'view/chat_detail_page.dart';

// 定义全局的 navigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // runApp内部会自动调用一次 但是如果要在runApp之前使用Flutter绑定的功能 需要手动调用（如初始化插件、调用平台通道、获取屏幕信息）
  // WidgetsFlutterBinding.ensureInitialized();
  // ScreenSize.init();
  await initializeDateFormatting('zh_CN', null); // intl库初始化
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 屏幕旋转时会自动重新build
    ScreenSize.init(context);

    return MaterialApp(
      // MaterialApp 内部会创建一个 Navigator 如果不绑定 navigatorKey，只能在 widget 内部通过 Navigator.of(context) 找到它
      // 绑定后 就能在全局通过 navigatorKey.currentState 操作路由，不依赖 context
      navigatorKey: navigatorKey,
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
      // initialRoute: '/', // 指定了initialRoute后home会失效
      // routes: {
      //   '/': (_) => const MainPage(),
      //   '/chat_log': (_) => const ChatLogPage(),
      // },
      home: const RootAuthWrapper(), // 将默认主页改为状态包装器
      // 自定义路由跳转动画
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/chat_log':
            builder = (_) => const ChatLogPage();
            break;
          case '/chat_detail':
            builder = (_) => const ChatDetailPage();
            break;
          case '/register_page':
            builder = (_) => const RegisterPage();
            break;
          case '/forgot_password_page':
            builder = (_) => const ForgotPasswordPage();
            break;
          default:
            // 路由默认兜底也回到包装器
            builder = (_) => const RootAuthWrapper();
        }
        return PageRouteBuilder(
          pageBuilder: (context, _, _) => builder(context),
          settings: settings, // 加这个才能通过arguments传参数
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final p = Tween(
              begin: Offset(1, 0),
              end: Offset(0, 0),
            ).chain(CurveTween(curve: Curves.ease));
            return SlideTransition(position: animation.drive(p), child: child);
          },
        );
      },
    );
  }
}
