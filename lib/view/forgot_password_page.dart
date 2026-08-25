import 'dart:async';

import 'package:chat_app/components/animated_background.dart';
import 'package:chat_app/components/common_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 忘记密码页面
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  final _confirmPasswordController = TextEditingController();
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  void _handleResetPassword() async {
    FocusScope.of(context).unfocus();
    // 触发所有表单校验
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // TODO: 调用重置密码 API
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('密码重置成功，请重新登录')));
        Navigator.pop(context);
      }
    }
  }

  // 验证码倒计时
  int _countdownSeconds = 0;
  Timer? _timer;
  void _startCountdown() {
    final input = _accountController.text.trim();
    final accountType = checkAccountType(input);
    if (accountType == AccountType.invalid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入正确的邮箱或手机号格式')));
      return;
    }
    // 开启倒计时
    setState(() {
      _countdownSeconds = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _countdownSeconds = 0;
        });
      }
    });

    final typeText = accountType == AccountType.phone ? '手机' : '邮箱';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('重置验证码已发送至您的$typeText')));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accountController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '找回密码',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30.rpx,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.rpx),
                            Text(
                              '验证账号信息以设置新密码',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30.rpx,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 36.rpx),
                            // 绑定邮箱/手机号
                            TextFormField(
                              controller: _accountController,
                              decoration: InputDecoration(
                                labelText: '绑定邮箱 / 手机号',
                                prefixIcon: const Icon(
                                  Icons.account_box_outlined,
                                ),
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
                            // 验证码输入与获取按钮
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _codeController,
                                    decoration: InputDecoration(
                                      labelText: '验证码',
                                      prefixIcon: const Icon(
                                        Icons.verified_outlined,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.rpx,
                                        ),
                                      ),
                                    ),
                                    validator: (val) =>
                                        (val == null || val.trim().isEmpty)
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
                            SizedBox(height: 16.rpx),
                            // 新密码
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: !_isNewPasswordVisible,
                              decoration: InputDecoration(
                                labelText: '新密码',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isNewPasswordVisible =
                                          !_isNewPasswordVisible;
                                    });
                                  },
                                  icon: Icon(
                                    _isNewPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.rpx),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return '请输入密码';
                                if (val.contains(' ')) return '密码不能包含空格';
                                if (val.length < 6) return '密码长度不能少于6位';
                                return null;
                              },
                            ),
                            SizedBox(height: 16.rpx),
                            // 确认新密码
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                labelText: '确认新密码',
                                prefixIcon: const Icon(Icons.lock_reset),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
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
                              validator: (val) {
                                if (val != _newPasswordController.text) {
                                  return '两次输入的密码不一致';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 28.rpx),
                            // 重置密码提交按钮
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _handleResetPassword,
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
                                        '重置密码',
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
