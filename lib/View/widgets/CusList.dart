import 'package:flutter/material.dart';
import '../../Utils/rpx.dart';

class CusList extends StatefulWidget {
  final List<String> listData;

  const CusList({super.key, required this.listData});

  @override
  State<CusList> createState() => _CusListState();
}

class _CusListState extends State<CusList> {
  // 获取 AnimatedList 的状态对象 一个widget的state相当于控制器
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _addItems();
  }

  // 依次添加项目及动画
  void _addItems() async {
    for (int i = 0; i < widget.listData.length; i++) {
      // 添加暂停 使得每一项错落插入
      await Future.delayed(const Duration(milliseconds: 300));
      // 操作数据 插入数组元素 使用insert而非add 是因为要控制动画对应的元素
      _items.insert(i, widget.listData[i]);
      // AnimatedList 的 itemBuilder 必须配合 insertItem 才会传入 animation 参数
      _listKey.currentState?.insertItem(i);
    }
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
      duration: const Duration(milliseconds: 6000),
    );
  }

  // 构建列表每一项的内容和动画
  Widget _buildItem({
    bool isAdd = true,
    required Animation<double> animation,
    required String item,
  }) {
    final offsetTween = isAdd
        ? Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero) // 添加 从右侧滑入
        // 这里有个大坑 删除时 Animation 进度是从1到0！因此begin和end要反过来 才是向左滑出
        : Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero); // 删除 向左侧滑出
    return SlideTransition(
      key: ValueKey(item), // 用于区分不同的item
      // 平移动画 Animation用来控制进度
      position: animation.drive(
        // Tween相当于计算进度公式
        offsetTween,
      ),
      child: FadeTransition(
        opacity: animation,
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 8.rpx, horizontal: 12.rpx),
          child: ListTile(
            title: Text(item),
            trailing: IconButton(
              onPressed: () {
                final index = _items.indexOf(item);
                if (index >= 0) _removeItem(index);
              },
              icon: Icon(Icons.delete),
            ),
          ),
        ),
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
