import 'dart:async';
import 'package:chat_app/components/animated_background.dart';
import 'package:chat_app/components/common_api.dart';
import 'package:chat_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 注册页面
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  // GlobalKey 提供跨 Widget 层级访问某个 StatefulWidget 的 State
  // Form 组件虽然是StatefulWidget 但是并没有将其对应的state私有化 就是为了将其内部状态暴露出来 以供使用
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _confirmPasswordController = TextEditingController();
  bool _isConfirmPasswordVisible = false;

  // 验证码倒计时
  Timer? _timer; // 保存定时器变量 后续清除定时器
  int _countdownSeconds = 0;
  void _startCountdown() async {
    final input = _emailController.text.trim();
    final accountType = checkAccountType(input);
    if (accountType == AccountType.invalid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入正确的邮箱或手机号格式')));
      return;
    }
    final success = await UserApi.sendCode(
      target: input,
      type: accountType == AccountType.phone ? 'sms' : 'email',
    );
    if (!success) return; // 失败由 dio 拦截器弹窗处理
    // 开启倒计时
    setState(() {
      _countdownSeconds = 60;
    });
    // 固定时间自动执行一次回调函数
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        // 倒计时结束
        _timer?.cancel();
        setState(() {
          _countdownSeconds = 0;
        });
      }
    });

    final typeText = accountType == AccountType.phone ? '手机' : '邮箱';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('验证码已发送至您的$typeText')));
  }

  bool _isLoading = false;
  void _handleRegister() async {
    //  清除当前组件内焦点
    FocusScope.of(context).unfocus();
    // 执行表单校验
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final success = await UserApi.register(
        username: _nicknameController.text.trim(),
        password: _passwordController.text,
        target: _emailController.text.trim(),
        code: _codeController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('注册成功，请登录')));
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nicknameController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                // 顶部返回按钮
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 24.rpx),
                      // Form 是为了通过currentState统一校验
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '创建新账号',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30.rpx,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.rpx),
                            Text(
                              '注册以开始您的全新体验',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30.rpx,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 36.rpx),
                            // 用户名
                            TextFormField(
                              controller: _nicknameController,
                              decoration: InputDecoration(
                                labelText: '用户名',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.rpx),
                                ),
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? '请输入用户名'
                                  : null,
                            ),
                            SizedBox(height: 16.rpx),
                            // 邮箱/手机号
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: '邮箱 / 手机号',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.rpx),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '请输入邮箱或手机号';
                                }
                                if (checkAccountType(value) ==
                                    AccountType.invalid) {
                                  return '请输入有效的手机号或邮箱格式';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.rpx),
                            // 验证码
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _codeController,
                                    decoration: InputDecoration(
                                      labelText: '验证码',
                                      prefixIcon: Icon(Icons.verified_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.rpx,
                                        ),
                                      ),
                                    ),
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? '请输入验证码'
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 12.rpx),
                                ElevatedButton(
                                  onPressed: _countdownSeconds == 0
                                      ? _startCountdown
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.blueAccent
                                        .withValues(alpha: 0.7),
                                    disabledForegroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 20.rpx,
                                      horizontal: 16.rpx,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        12.rpx,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _countdownSeconds > 0
                                        ? '${_countdownSeconds}s 后重新发送'
                                        : '获取验证码',
                                    style: TextStyle(fontSize: 24.rpx),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.rpx),
                            // 密码
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: '密码',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  }),
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.rpx),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入密码';
                                } else if (value.contains(' ')) {
                                  return '密码不能包含空格';
                                } else if (value.length < 6) {
                                  return '密码长度不能少于6位';
                                }
                                return null; // 返回null组件才认为校验通过
                              },
                            ),
                            SizedBox(height: 16.rpx),
                            // 确认密码
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                labelText: '确认密码',
                                prefixIcon: const Icon(Icons.lock_reset),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible,
                                  ),
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.rpx),
                                ),
                              ),
                              validator: (value) {
                                // TextEditingController 的text是纯文本 value是完整的编辑状态 包含光标位置、文本内容等
                                if (value != _passwordController.text) {
                                  return '两次输入的密码不一致';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.rpx),
                            // 注册按钮
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.blueAccent
                                    .withValues(alpha: 0.7),
                                padding: EdgeInsets.symmetric(vertical: 16.rpx),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.rpx),
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 20.rpx,
                                        height: 20.rpx,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        '注 册',
                                        style: TextStyle(
                                          fontSize: 30.rpx,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
