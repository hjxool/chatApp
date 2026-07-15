import 'package:chat_app/components/common_api.dart';
import 'package:chat_app/providers/global_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class LoginPage extends ConsumerStatefulWidget {
  // 添加一个动画完成后的回调
  final VoidCallback? onTransitionComplete;
  const LoginPage({super.key, this.onTransitionComplete});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

// 存在多个动画控制器用 TickerProviderStateMixin 只有一个动画控制器用 SingleTickerProviderStateMixin
class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  // 标识 Form 组件 通过这个 key 执行表单验证及保存
  final _formKey = GlobalKey<FormState>();
  // TextField/TextFormField 控制器 取文本框的值 监听输入变化 校验或联动
  // 不依赖于 TickerProvider/BuildContext 只需要分配内存 因此可以声明时直接初始化
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isLoginSuccess = false; // 是否登录成功，用于触发第二阶段动画

  // 动画控制器 因为绑定渲染/动画系统 需要 vsync 参数 只有在 initState 之后才能安全地作为 vsync 使用
  late AnimationController _contentFadeController; // 控制输入框等组件的渐隐
  late AnimationController _welcomeFadeController; // 控制“欢迎，xxx”的渐显
  late AnimationController _pageFadeController; // 控制整个登录页面的渐隐
  late AnimationController _backgroundController; // 背景动画控制器

  @override
  void initState() {
    super.initState();

    // 初始化动画：内容渐隐（1 -> 0）
    _contentFadeController = AnimationController(
      vsync: this, // 传入实现了 TickerProvider 的当前类实例
      duration: const Duration(milliseconds: 500),
    );
    // 初始化动画：欢迎语渐显（0 -> 1）
    _welcomeFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // 初始化动画：整页渐隐（1 -> 0）
    _pageFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // 背景循环动画
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _contentFadeController.dispose();
    _welcomeFadeController.dispose();
    _pageFadeController.dispose();
    _backgroundController.dispose();
    super.dispose(); // 最后清理父类 避免子类使用的资源被清理导致错误
  }

  // 核心登录与动画编排逻辑
  void _handleLogin() async {
    // 点击登录时立刻收回键盘，让输入框失去焦点
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // 触发表单校验
      setState(() {
        _isLoading = true;
      });
      try {
        // 1. 模拟网络请求（实际开发请调用你的 dio_client.dart）
        await Future.delayed(const Duration(seconds: 2));
        // 调用你 global_notifier 内的方法更新状态
        // await ref.read(authProvider.notifier).login(_usernameController.text, _passwordController.text);
        // 3. 开启第一阶段动画：输入框等组件渐隐
        setState(() {
          _isLoginSuccess = true;
        });
        await _contentFadeController.forward(); // 开始播放动画
        // 4. 开启第二阶段动画：欢迎文本渐显
        await _welcomeFadeController.forward(); // await等待动画播放完成再执行后续代码
        // 欢迎语稍微停留展示一下
        await Future.delayed(const Duration(milliseconds: 800));
        // 5. 开启第三阶段动画：整个页面渐隐，露出底层的主界面
        await _pageFadeController.forward();

        // State 对象自带 mounted 表示当前页面是否被销毁
        // 如果页面被 pop 掉 mounted 会变成 false
        if (mounted) {
          widget.onTransitionComplete?.call(); // 执行回调通知父级
          // 动画完全结束后，准备替换路由 执行前先确认当前页面还存在 避免用户在动画过程中离开了页面
          // pushReplacementNamed 会把当前页面从路由栈中移除 用一个新的页面替换它
          // Navigator.pushReplacementNamed(context, '/main_page'); // 确保后退不会回到登录页
        }
      } catch (e) {
        // 异常处理：重置按钮加载状态
        setState(() {
          _isLoading = false;
          _isLoginSuccess = false;
        });
        if (mounted) {
          // StatefulWidget 自带 context 因为当前类继承自 State
          // 而 StatelessWidget 不是 State 类 因此必须通过参数传递才能使用 context
          // ScaffoldMessenger 是消息管理器
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('登录失败: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 反向 Animation 让内容从 1 渐隐到 0
    // Tween 只是简单的定义数值范围 但因其继承自 Animatable 所以也拥有 animate 方法 将自身的范围绑定到Animation上
    final _contentAlpha = Tween<double>(begin: 1, end: 0).animate(
      // 曲线计算公式 定义变化速度
      // parent指定由哪个控制器套用该计算公式
      CurvedAnimation(parent: _contentFadeController, curve: Curves.easeInOut),
    );
    final _welcomeAlpha = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _welcomeFadeController,
        curve: const Interval(0, 0.7, curve: Curves.easeInOut),
      ),
    );
    // 欢迎文字从屏幕下方往上滑动的动画
    final _welcomeSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _welcomeFadeController,
            curve: Curves.easeOutBack,
          ),
        );
    final _pageAlpha = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _pageFadeController, curve: Curves.easeInOut),
    );
    return GestureDetector(
      // 点击屏幕任意空白处皆可收起键盘
      onTap: () => FocusScope.of(context).unfocus(),
      child: FadeTransition(
        // 最外层：控制整页的渐隐（露出底部的背景或主界面过渡）
        opacity: _pageAlpha,
        child: Scaffold(
          body: Stack(
            children: [
              // 流光特效背景层
              AnimatedBuilder(
                animation: _backgroundController,
                builder: (BuildContext context, Widget? child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.withOpacity(
                            0.05 +
                                0.05 *
                                    math.sin(
                                      _backgroundController.value * 2 * math.pi,
                                    ),
                          ),
                          Colors.purple.withOpacity(
                            0.05 +
                                0.05 *
                                    math.cos(
                                      _backgroundController.value * 2 * math.pi,
                                    ),
                          ),
                          Colors.white,
                        ],
                      ),
                    ),
                  );
                },
              ),
              // 主体部分
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.rpx),
                    child: Stack(
                      // 绝对定位布局 alignment 决定 children 里的元素在哪个位置重叠 除非用 Positioned 包裹定位 否则都叠在一起
                      alignment: Alignment.center,
                      children: [
                        // 层叠结构 1：登录输入表单等核心内容
                        FadeTransition(
                          opacity: _contentAlpha,
                          // 当开始渐隐时，为了防止表单还能被点击，用 IgnorePointer 包裹
                          child: IgnorePointer(
                            ignoring: _isLoginSuccess,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // 横向拉伸
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 32.rpx,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 48.rpx),
                                  // 用户名
                                  TextFormField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      labelText: '用户名/邮箱',
                                      prefixIcon: const Icon(
                                        Icons.person_outline,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.rpx,
                                        ),
                                      ),
                                    ),
                                    validator: (value) =>
                                        // 验证器
                                        (value == null || value.trim().isEmpty)
                                        ? '请输入用户名'
                                        : null,
                                  ),
                                  SizedBox(height: 16.rpx),
                                  // 密码
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    decoration: InputDecoration(
                                      labelText: '密码',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _isPasswordVisible =
                                              !_isPasswordVisible,
                                        ),
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.rpx,
                                        ),
                                      ),
                                    ),
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                        ? '请输入密码'
                                        : null,
                                  ),
                                  SizedBox(height: 24.rpx),
                                  // 登录按钮 (使用 AnimatedSwitcher 实现文字变加载图标)
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.rpx,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.rpx,
                                        ),
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 20.rpx,
                                              height: 20.rpx,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              '登 录',
                                              style: TextStyle(
                                                fontSize: 32.rpx,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 层叠结构 2：登录成功后渐显的“欢迎，xxx”
                        FadeTransition(
                          opacity: _welcomeAlpha,
                          child: AnimatedBuilder(
                            animation: _welcomeSlide,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Colors.blueAccent,
                                          Colors.purpleAccent,
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    '欢迎回来',
                                    style: TextStyle(
                                      fontSize: 54.rpx,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // 配合 ShaderMask 使用
                                      letterSpacing: 4.rpx,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.rpx),
                                Text(
                                  '正在为您加载精彩世界...',
                                  style: TextStyle(
                                    fontSize: 24.rpx,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            builder: (BuildContext context, Widget? child) {
                              return Transform.translate(
                                offset:
                                    _welcomeSlide.value * 200, // 向上位移 200 像素
                                child: child,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
