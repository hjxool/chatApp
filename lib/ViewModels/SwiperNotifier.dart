import 'package:flutter_riverpod/flutter_riverpod.dart';

// 定义数据结构
class SwiperState {
  final int? openIndex;

  const SwiperState({this.openIndex});
  // 只定义最基本的构造方法
  SwiperState copyWith({int? openIndex}) {
    // 有传入值则接收传入值 没有则使用之前的值 构造新的实例对象
    return SwiperState(openIndex: openIndex ?? this.openIndex);
  }
}

// 定义修改state的方法
class SwiperNotifier extends Notifier<SwiperState> {
  @override
  SwiperState build() => const SwiperState();

  // 点击某行卡片
  void open(int index) {
    // 因为state是一个对象 为了触发重建需要整个替换对象引用
    state = state.copyWith(openIndex: index);
  }
}
