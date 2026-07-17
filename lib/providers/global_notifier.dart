import 'dart:async';
import 'package:chat_app/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/components/common_api.dart';
import 'package:chat_app/models/dio_client.dart';

// 未读消息
class UnreadMessage extends Notifier<int> {
  @override
  int build() => 13;

  void increment() => state++;
}

final UnreadMessageProvider = NotifierProvider<UnreadMessage, int>(
  UnreadMessage.new,
);

// 使用AsyncNotifier 返回值就不再是单纯的UserConfigState 而是AsyncValue<T>
class UserConfigNotifier extends AsyncNotifier<UserConfigState> {
  @override
  // FutureOr 表示支持同步异步两种方式
  Future<UserConfigState> build() async {
    // 监听 authProvider
    final authAsync = ref.watch(authProvider);
    // 因为是AsyncNotifier返回的异步state 因此要用.value
    if (authAsync.value == null) {
      return const UserConfigState(userId: null, userInfos: []);
    }
    consoleLog('检测到 Token，开始获取用户同步配置...', tag: '用户数据');
    final List<User> userInfos = await UserApi.fetchUserInfos();
    return UserConfigState(userId: '1', userInfos: userInfos);
  }

  void setValue({String? userId, List<User>? userInfos}) {
    // 因为state类型变为AsyncValue<T> 因此用AsyncValue.data包裹
    final data = state.value; // 并且取值变成.value
    if (data == null) return;
    state = AsyncData(
      UserConfigState(
        userId: userId ?? data.userId,
        userInfos: userInfos ?? data.userInfos,
      ),
    );
  }

  void setUserInfo(String userId, {bool? noDisturb, bool? isTop}) {
    final newList = state.value?.userInfos?.map((e) {
      if (e.userId == userId) {
        return e.copyWith(noDisturb: noDisturb, isTop: isTop);
      }
      return e;
    }).toList();
    // provider本质是对比引用地址来判断是否变化触发监听 因此必须要更新整个state
    setValue(userInfos: newList);
  }
}

final UserConfigProvider =
    AsyncNotifierProvider<UserConfigNotifier, UserConfigState>(
      UserConfigNotifier.new,
    );

class AuthNotifier extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() {
    // 自动登录 读取本地持久化缓存（比如 SharedPreferences）
    // String? savedToken = await SharedPreferences.getInstance().then((sp) => sp.getString('token'));
    // if (savedToken != null) {
    //   updateToken(savedToken); // 同步给 dio 拦截器
    //   return savedToken;
    // }
    return null;
  }

  // 登录业务逻辑
  Future<bool> login(String username, String password) async {
    state = const AsyncValue.loading();
    // 使用一个变量来记录最终结果
    bool isSuccess = false;
    // guard自动把 try-catch 包装起来，并且把结果转换成 AsyncValue 类型
    state = await AsyncValue.guard(() async {
      // 调用接口获取 token
      final token = await UserApi.login(username: username, password: password);
      // 同步给你的全局 Dio 拦截器
      if (token != null) {
        updateToken(token);
        isSuccess = true;
      }
      // 此时 state 变为了 AsyncData(token)
      return token;
    });
    return isSuccess; // 返回布尔值结果给 UI 层
  }

  // 退出登录
  void logout() {
    updateToken(''); // 清空 dio 中的 token
    state = const AsyncValue.data(null); // 状态回归未登录
  }
}

// autoDispose是为了一次性使用销毁 而不用长期占据内存
final authProvider = AsyncNotifierProvider.autoDispose<AuthNotifier, String?>(
  AuthNotifier.new,
);
