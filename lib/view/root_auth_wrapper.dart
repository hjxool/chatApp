// 核心：动态控制登录页与主页层叠的状态包裹器
import 'package:chat_app/components/common_api.dart';
import 'package:chat_app/providers/global_notifier.dart';
import 'package:chat_app/view/login_page.dart';
import 'package:chat_app/view/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RootAuthWrapper extends ConsumerStatefulWidget {
  const RootAuthWrapper({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RootAuthWrapperState();
}

class _RootAuthWrapperState extends ConsumerState<RootAuthWrapper> {
  // 用于控制即使过渡动画，只要没播完，LoginPage 依然留在树里
  bool _forceShowLogin = false;

  @override
  Widget build(BuildContext context) {
    // 监听全局的登录状态
    final authAsync = ref.watch(authProvider);
    // 判断是否拥有 Token
    final bool hasToken = authAsync.value != null;
    // 如果没 Token，说明需要登录
    if (!hasToken) {
      _forceShowLogin = true;
    }

    return Stack(
      children: [
        // 1. 底层永远是 MainPage，登录成功时它已经在默默预加载数据了
        const MainPage(),
        // 2. 如果未登录，或者动画正在播放中，则把登录页盖在上面
        if (!hasToken || _forceShowLogin)
          LoginPage(
            onTransitionComplete: () {
              consoleLog('是否触发', tag: 'RootAuthWrapper');
              // 动画完全播完后，将登录页彻底从树中销毁，完美露出底部的 MainPage
              setState(() {
                _forceShowLogin = false;
              });
            },
          ),
      ],
    );
  }
}
