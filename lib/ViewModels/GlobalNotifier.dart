import 'package:flutter_riverpod/flutter_riverpod.dart';

// 未读消息
class UnreadMessage extends Notifier<int> {
  @override
  int build() => 13;

  void increment() => state++;
}

// 用户信息
class UserInfoState {
  final String? userId;

  const UserInfoState({this.userId});
}

class UserInfoNotifier extends Notifier<UserInfoState> {
  @override
  UserInfoState build() => const UserInfoState(userId: '1');

  void setValue({String? userId}) {
    state = UserInfoState(userId: userId ?? state.userId);
  }
}
