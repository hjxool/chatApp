import 'dart:async';
import 'package:chat_app/api/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/components/common_api.dart';

// 未读消息
class UnreadMessage extends Notifier<int> {
  @override
  int build() => 13;

  void increment() => state++;
}

final UnreadMessageProvider = NotifierProvider<UnreadMessage, int>(
  UnreadMessage.new,
);

// 账号级配置同步
class UserConfigState {
  final String? userId;
  final List<User>? userInfos;

  const UserConfigState({this.userId, this.userInfos});
}

// 使用AsyncNotifier 返回值就不再是单纯的UserConfigState 而是AsyncValue<T>
class UserConfigNotifier extends AsyncNotifier<UserConfigState> {
  @override
  // FutureOr 表示支持同步异步两种方式
  Future<UserConfigState> build() async {
    final List<User> users = await UserApi.fetchUser();
    consoleLog('users:$users', tag: '用户');
    return UserConfigState(userId: '1', userInfos: users);
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

  void setUserInfo(String userId, {bool? noDisturb}) {
    final newList = state.value?.userInfos?.map((e) {
      if (e.userId == userId) {
        return e.copyWith(noDisturb: noDisturb);
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
