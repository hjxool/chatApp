import 'package:flutter_riverpod/flutter_riverpod.dart';

// 未读消息
class UnreadMessage extends Notifier<int> {
  @override
  int build() => 13;

  void increment() => state++;
}
