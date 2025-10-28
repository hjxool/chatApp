import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/Utils/rpx.dart';
import 'package:chat_app/ViewModels/SwiperNotifier.dart';

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
  // 保存监听引用 在应用热重启时清理残余订阅 防止riverpod订阅出现异常
  ProviderSubscription<SwiperState>? _providerSubscribe;
  bool topButtonIndexToNull = false; // 是否从放大按钮还原回普通按钮

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    triggerWidth = (widget.rightWidth ?? 0) / 4;

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

    // 在这设置监听更安全 能保证 context 已经稳定
    _providerSubscribe?.close(); // 如果存在订阅先清除 防止重复订阅
    if (widget.provider != null) {
      // 添加openIndex监听
      _providerSubscribe = ref.listenManual<SwiperState>(widget.provider!, (
        pre,
        now,
      ) {
        if (now.openIndex != widget.itemIndex) {
          // 不是自身 则折叠
          _foldAnimation(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放动画资源
    _providerSubscribe?.close(); // 取消监听
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
        if (d.primaryVelocity! < -200) {
          shouldOpen = true;
        } else if (d.primaryVelocity! > 200) {
          shouldOpen = false;
        } else {
          shouldOpen = _dx < -triggerWidth;
        }
      } else {
        // 如果没有 甩动 而是停在某个位置 则根据阈值判断
        shouldOpen = _dx < -triggerWidth; // 注意 转换成坐标轴负值进行比较
      }
      final double end = shouldOpen ? -(widget.rightWidth ?? 0) : 0;
      _foldAnimation(end);
    }
  }

  // 展开/收起动画
  void _foldAnimation(double end) {
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
    // 注意！不要在build里 直 接 调用会触发重建的逻辑 不然会无限循环
    // 这里因为调用了_foldAnimation 而内部调用了setState导致无限循环 一进到build就触发setState 然后再次build
    // SwiperState? state;
    // if (widget.provider != null) {
    //   state = ref.watch(widget.provider!);
    //   if (state!.openIndex != widget.itemIndex) {
    //     _foldAnimation(0);
    //   }
    // }

    return GestureDetector(
      onHorizontalDragUpdate: _dragUpdate,
      onHorizontalDragEnd: _dragEnd,
      onHorizontalDragStart: (_) {
        // 同一行 手动折叠 触发按钮还原动画
        // 如果只判断topButtonIndex != null 会因为当前行因为其他行打开而折叠 但是topButtonIndex不为null 导致无法还原按钮展开动画
        final curIndex = ref.watch(widget.provider!).openIndex;
        topButtonIndexToNull =
            (widget.itemIndex == curIndex) && (topButtonIndex != null);

        if (widget.provider != null && widget.itemIndex != null) {
          // 打开对应行
          ref.read(widget.provider!.notifier).open(widget.itemIndex!);
        }
        // 拖拽时重置 topButtonIndex 清除动画延迟时间 并手动计算展开过程
        setState(() {
          topButtonIndex = null;
        });
      },
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
          Transform.translate(offset: Offset(_dx, 0), child: widget.content),
        ],
      ),
    );
  }

  // 按钮布局
  Widget _buttonsLayer() {
    return Container(
      alignment: Alignment.centerRight,
      width: widget.rightWidth, // 父容器设置了top:0, bottom:0 因此不需要再设置高度 自组件会继承父容器高度
      child: Stack(children: _buttonScale()),
    );
  }

  // 按钮点击放大效果
  List<Widget> _buttonScale() {
    final double buttonWidth = widget.rightWidth! / widget.rightButtons!.length;
    // 按钮从层叠逐步错开 设置展开进度
    final double progress = (_dx.abs() / (widget.rightWidth ?? 1)).clamp(0, 1);

    List<Widget> buttons = [];
    if (topButtonIndex == null) {
      if (topButtonIndexToNull) {
        // 从放大还原回普通状态
        for (int i = 0; i < widget.rightButtons!.length; i++) {
          buttons.add(
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              right: i * buttonWidth,
              top: 0,
              bottom: 0,
              width: buttonWidth,
              // 如果想一个动画结束衔接另一个动画组件可以用 onEnd 回调
              onEnd: i < widget.rightButtons!.length - 1
                  ? null
                  : () {
                      // 重置标志位 触发build使折叠由progress控制
                      setState(() {
                        topButtonIndexToNull = false;
                      });
                    },
              child: _buttonClick(widget.rightButtons![i], index: i),
            ),
          );
        }
      } else {
        // 本身没选按钮放大 则过渡显示按钮
        for (int i = 0; i < widget.rightButtons!.length; i++) {
          buttons.add(
            AnimatedPositioned(
              // duration 和 progress 冲突
              duration: const Duration(milliseconds: 0),
              right: i * buttonWidth * progress,
              // flutter 中父容器高度会继承给子容器 但不会隔代继承
              // Container 继承了外层 Positioned top: 0 bottom: 0的约束(高度)
              // Stack 因为其父容器 Container 具有宽高 所以等同于父容器大小
              // 而子 Positioned 就没有继承了 需要手动设置 top: 0 bottom: 0才能撑满 Stack
              top: 0,
              bottom: 0,
              width: buttonWidth,
              child: _buttonClick(widget.rightButtons![i], index: i),
            ),
          );
        }
      }
    } else {
      // 点击按钮后 根据按钮所在位置判断哪些属性改变
      // 因为按钮从右往左排列 因此最右侧的是数组第一个
      if (topButtonIndex == 0) {
        // 最右侧按钮 只需要拉伸宽度 其他按钮移动出左侧边界
        for (int i = 0; i < widget.rightButtons!.length; i++) {
          buttons.add(
            _buildBtnByIndex(
              _buttonClick(widget.rightButtons![i], index: i),
              right: topButtonIndex == i ? 0 : widget.rightWidth!,
              width: topButtonIndex == i ? widget.rightWidth! : buttonWidth,
            ),
          );
        }
      } else if (topButtonIndex == (widget.rightButtons?.length ?? 1) - 1) {
        // 最左侧按钮 移动位置和拉伸宽度 它以前的按钮移动出右侧边界
        for (int i = 0; i < widget.rightButtons!.length; i++) {
          buttons.add(
            _buildBtnByIndex(
              _buttonClick(widget.rightButtons![i], index: i),
              right: topButtonIndex == i ? 0 : -buttonWidth,
              width: topButtonIndex == i ? widget.rightWidth! : buttonWidth,
            ),
          );
        }
      } else {
        // 中间按钮 移动位置 拉伸宽度 它以前的按钮移动出右侧边界 它后面的按钮移动出左侧边界
        for (int i = 0; i < widget.rightButtons!.length; i++) {
          buttons.add(
            _buildBtnByIndex(
              _buttonClick(widget.rightButtons![i], index: i),
              right: i < topButtonIndex!
                  ? -buttonWidth
                  : (topButtonIndex == i ? 0 : widget.rightWidth!),
              width: topButtonIndex == i ? widget.rightWidth! : buttonWidth,
            ),
          );
        }
      }
    }
    return buttons;
  }

  Widget _buildBtnByIndex(
    Widget content, {
    required double right,
    required double width,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: right,
      top: 0,
      bottom: 0,
      // 不能把容器宽度设置为0 因为里面child还占大小 会导致child被挤出来 而容器移动到边界消失后 child还在屏幕上
      width: width,
      child: content,
    );
  }

  // 点击按钮 区分是放大的默认事件 还是放大后触发传入事件
  Widget _buttonClick(SwiperButton btn, {required int index}) {
    return Material(
      // 继承了父容器的宽高
      color: btn.color,
      child: InkWell(
        onTap: () {
          if (topButtonIndex == null && btn.remark != null) {
            // 初选按钮 且 有需要展开显示的备注 点击放大
            setState(() {
              topButtonIndex = index;
            });
          } else {
            // 再次点击触发传入事件
            btn.tapFn();
          }
        },
        child: Center(
          child: Text(
            topButtonIndex == index && btn.remark != null
                ? btn.remark!
                : btn.label,
            style: TextStyle(color: Colors.white, fontSize: 24.rpx),
            softWrap: false, // 防止文字换行
          ),
        ),
      ),
    );
  }
}

// 滑块按钮数据格式
class SwiperButton {
  final Color color;
  final String label;
  final VoidCallback tapFn;
  final String? remark;

  const SwiperButton({
    required this.color,
    required this.label,
    required this.tapFn,
    this.remark,
  });
}
