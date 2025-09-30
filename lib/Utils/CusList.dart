import 'package:flutter/material.dart';

class ItemType {
  final Widget content;
  final Key key;

  const ItemType({required this.content, required this.key});
}

typedef OnReadyCallback =
    void Function({required void Function(ItemType value) addFn});

class CusList extends StatefulWidget {
  final List<ItemType> listData;
  final OnReadyCallback? onReady; // 列表初始化完成回调

  const CusList({super.key, required this.listData, this.onReady});

  @override
  State<CusList> createState() => _CusListState();
}

class _CusListState extends State<CusList> {
  // 获取 AnimatedList 的状态对象 一个widget的state相当于控制器
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<ItemType> _items = []; // 用于展示动画的拷贝列表

  @override
  void initState() {
    super.initState();
    _initList();
    widget.onReady?.call(
      addFn: _addItems,
    ); // dart中调用函数本质上都是.call() 为了了防止空指针 加了?
  }

  // 初始化列表
  void _initList() async {
    for (int i = 0; i < widget.listData.length; i++) {
      // 添加暂停 使得每一项错落插入
      await Future.delayed(const Duration(milliseconds: 100));
      _addItems(widget.listData[i]);
    }
  }

  // 依次添加项目及动画
  void _addItems(ItemType value) {
    final index = _items.length;
    // 操作数据 插入数组元素 使用insert而非add 是因为要控制动画对应的元素
    _items.insert(index, value);
    // AnimatedList 的 itemBuilder 必须配合 insertItem 才会传入 animation 参数
    _listKey.currentState?.insertItem(index);
  }

  // 移除列表项及动画
  void _removeItem(int index) {
    final removeItem = _items.removeAt(index);
    // 删除时不会调用 itemBuilder 必须自己提供
    // removeItem 最好放到删除后 因为 builder 需要一个“被删除的 item”来渲染动画 因此要保存下删除项
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildItem(animation: animation, item: removeItem, isAdd: false),
      duration: const Duration(milliseconds: 500),
    );
  }

  // 构建列表每一项的内容和动画
  Widget _buildItem({
    bool isAdd = true,
    required Animation<double> animation,
    required ItemType item,
  }) {
    final offsetTween = isAdd
        ? Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero) // 添加 从右侧滑入
        // 这里有个大坑 删除时 Animation 进度是从1到0！因此begin和end要反过来 才是向左滑出
        : Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero); // 删除 向左侧滑出
    return SlideTransition(
      key: item.key, // 用于区分不同的item
      // 平移动画 Animation用来控制进度
      position: animation.drive(
        // Tween相当于计算进度公式
        offsetTween,
      ),
      child: FadeTransition(
        opacity: animation,
        // child: ChatCard(title: item.exter['title']),
        child: item.content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey, // 由该key访问AnimatedListState来控制动画
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        return _buildItem(animation: animation, item: _items[index]);
      },
    );
  }
}
