import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'rpx.dart';
import '../ViewModels/SwiperNotifier.dart';

class SwiperItem extends ConsumerStatefulWidget {
  final Widget content;
  final List<SwiperButton>? rightButtons;
  final double? rightWidth;
  // 里面的泛型要写全 否则ref.watch会报类型错误
  final NotifierProvider<SwiperNotifier, SwiperState>? provider;
  final int? itemIndex;

  const SwiperItem({
    super.key,
    required this.content,
    this.rightButtons,
    this.rightWidth,
    this.provider,
    this.itemIndex,
  });

  @override
  ConsumerState<SwiperItem> createState() => _SwiperItemState();
}

// SingleTickerProviderStateMixin 提供 vsync（垂直同步）信号源
class _SwiperItemState extends ConsumerState<SwiperItem>
    with SingleTickerProviderStateMixin {
  // 水平位移 往左滑是负值
  double _dx = 0.0;

  late final double triggerWidth; // 触发关闭/展开宽度
  late AnimationController _controller; // 动画控制器
  late Animation<double> _animation; // 动画进度 映射的真实位移值
  int? topButtonIndex; // 展示在最上层的按钮索引

  @override
  void initState() {
    super.initState();

    triggerWidth = (widget.rightWidth ?? 0) / 2;

    if (triggerWidth > 0) {
      // 传入右侧宽度才可以滑动
      _controller = AnimationController(
        vsync: this, // 在 initState 后才有效的 TickerProvider 因此要用late
        duration: const Duration(milliseconds: 300), // 300ms的动画
      );
      // 此时有了_controller才能创建 Animation<double> 对象
      // 空的占位动画 并添加监听器 避免监听事件触发时空指针异常
      // animate 是 Tween 的方法 将传入 animate 的0～1进度映射到begin～end实际值
      _animation = Tween<double>(begin: 0, end: 0).animate(_controller)
        ..addListener(() {
          setState(() {
            _dx = _animation.value;
          });
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放动画资源å
    super.dispose();
  }

  // 水平拖拽更新 _dx 距离
  void _dragUpdate(DragUpdateDetails d) {
    setState(() {
      _dx = (_dx + d.delta.dx).clamp(
        -(widget.rightWidth ?? 0),
        0,
      ); // 用 clamp 限制
    });
  }

  // 拖拽结束 根据阈值决定是展开还是收起 并展示对应动画
  void _dragEnd(DragEndDetails d) {
    if ((widget.rightWidth ?? 0) > 0) {
      late bool shouldOpen;
      if (d.primaryVelocity != null) {
        // primaryVelocity 表示 手指松开时的水平速度 以此实现甩动折叠/展开的手感
        // 负值表示向左 正值表示向右 数值越大说明速度越快
        if (d.primaryVelocity! < -500) {
          shouldOpen = true;
        } else if (d.primaryVelocity! > 500) {
          shouldOpen = false;
        } else {
          shouldOpen = _dx < -triggerWidth;
        }
      } else {
        // 如果没有 甩动 而是停在某个位置 则根据阈值判断
        shouldOpen = _dx < -triggerWidth; // 注意 转换成坐标轴负值进行比较
      }
      final double end = shouldOpen ? -(widget.rightWidth ?? 0) : 0;
      foldAnimation(end);
    }
  }

  // 展开/收起动画
  void foldAnimation(double end) {
    // 拖拽结束时 才获取真正要执行的动画对象 从而在监听事件中更新 _dx
    _animation = Tween<double>(begin: _dx, end: end).animate(
      // CurvedAnimation 是个装饰器 接收父控制器的线性进度 再通过曲线函数 curve 映射成非线性值
      // CurvedAnimation(
      //   parent: _controller,
      //   curve: shouldOpen
      //       ? Curves.elasticInOut
      //       : Curves.easeOut, // 展开用弹性曲线 收起用平滑曲线
      // ),
      _controller,
    );
    // 调用 forward/reverse/repeat 方法 让动画动起来
    _controller.forward(from: 0).then((_) {
      setState(() {
        // 动画结束锁定 _dx 值
        _dx = end;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SwiperState? state;
    if (widget.provider != null) {
      state = ref.watch(widget.provider!);
      // 点了其他swiper组件 只判断折叠
      if (state!.openIndex != widget.itemIndex) {
        foldAnimation(0);
      }
    }

    return GestureDetector(
      onHorizontalDragUpdate: _dragUpdate,
      onHorizontalDragEnd: _dragEnd,
      child: Stack(
        // 使用层叠在一起 滑动露出的方式
        children: [
          // Stack根据排列顺序决定遮盖层级
          // 最底下的按钮区域 在右侧占据传入宽度
          if ((widget.rightWidth ?? 0) > 0 &&
              (widget.rightButtons ?? []).isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: widget.rightWidth,
              child: _buttonsLayer(),
            ),
          // 内容主体 _dx 控制的就是这块的滑动
          (state != null && widget.itemIndex != null)
              // 如果当前组件是在列表中使用 则添加点击事件监听
              ? GestureDetector(
                  onTapDown: (_) => ref
                      .read(widget.provider!.notifier)
                      .open(widget.itemIndex!),
                  child: Transform.translate(
                    offset: Offset(_dx, 0),
                    child: widget.content,
                  ),
                )
              : Transform.translate(
                  offset: Offset(_dx, 0),
                  child: widget.content,
                ),
        ],
      ),
    );
  }

  // 按钮布局
  Widget _buttonsLayer() {
    final double buttonWidth = widget.rightWidth! / widget.rightButtons!.length;

    // 按钮从层叠逐步错开 设置展开进度
    final double progress = (_dx.abs() / (widget.rightWidth ?? 1)).clamp(0, 1);

    return Container(
      alignment: Alignment.centerRight,
      width: widget.rightWidth, // 父容器设置了top:0, bottom:0 因此不需要再设置高度 自组件会继承父容器高度
      child: Stack(
        children: [
          // for 后没有{} 相当于简写return
          for (int i = 0; i < widget.rightButtons!.length; i++)
            topButtonIndex == null
                ? Positioned(
                    right: i * buttonWidth * progress,
                    top: 0,
                    bottom: 0,
                    width: buttonWidth,
                    child: widget.rightButtons![i],
                  )
                : AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    // 根据进度手动控制边距 从右往左排列
                    right: topButtonIndex == null
                        ? i * buttonWidth * progress
                        : (topButtonIndex == i ? 0 : widget.rightWidth),
                    // flutter 中父容器高度会继承给子容器 但不会隔代继承
                    // Container 继承了外层 Positioned top: 0 bottom: 0的约束(高度)
                    // Stack 因为其父容器 Container 具有宽高 所以等同于父容器大小
                    // 而子 Positioned 就没有继承了 需要手动设置 top: 0 bottom: 0才能撑满 Stack
                    top: 0,
                    bottom: 0,
                    width: topButtonIndex == null
                        ? buttonWidth
                        : (topButtonIndex == i ? widget.rightWidth : 0),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: topButtonIndex == null
                          ? 0.85 + 0.15 * progress
                          : 1.0,
                      child: Opacity(
                        opacity: topButtonIndex == null || topButtonIndex == i
                            ? 1.0
                            : 0.0,
                        child: widget.rightButtons![i],
                      ),
                    ),
                  ),
        ],
      ),
    );
  }
}

class SwiperButton extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback tapFn;

  const SwiperButton({
    super.key,
    required this.color,
    required this.label,
    required this.tapFn,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // 继承了父容器的宽高
      color: color,
      child: InkWell(
        onTap: tapFn,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 24.rpx),
            ),
          ],
        ),
      ),
    );
  }
}
