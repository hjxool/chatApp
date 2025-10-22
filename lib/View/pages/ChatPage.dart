import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utils/CusList.dart';
import '../../Utils/SwiperItem.dart';
import '../widgets/ChatCard.dart';
import '../../Utils/rpx.dart';
import '../../ViewModels/SwiperNotifier.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 当前页管理Swiper组件的数据源
    final swiperProvider = NotifierProvider<SwiperNotifier, SwiperState>(
      SwiperNotifier.new,
    );
    // 测试数据
    List<ItemType> listData = List.generate(5, (index) {
      return ItemType(
        content: SwiperItem(
          content: ChatCard(title: 'Item $index'),
          rightButtons: [
            SwiperButton(
              color: Colors.red,
              label: '删除',
              tapFn: () => print('触发删除'),
              remark: '删除并清空记录',
            ),
            SwiperButton(
              color: Colors.blue,
              label: '置顶',
              tapFn: () => print('触发置顶'),
            ),
            SwiperButton(
              color: Colors.orange,
              label: '免打扰',
              tapFn: () => print('触发免打扰'),
              remark: '消息免打扰',
            ),
          ],
          rightWidth: 360.rpx,
          provider: swiperProvider,
          itemIndex: index,
        ),
        key: ValueKey('Item $index'),
      );
    });
    late void Function(ItemType value) addItemFn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatWithMe'),
        actions: [
          IconButton(
            onPressed: null,
            icon: Icon(Icons.add, color: Colors.black),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.rpx),
          child: Divider(
            height: 2.rpx,
            thickness: 2.rpx,
            color: Color(0xFFE5E5E5), // 微信风格发丝线,
          ),
        ),
        backgroundColor: Colors.grey[200],
      ),
      body: CusList(
        listData: listData,
        onReady: ({required void Function(ItemType value) addFn}) {
          addItemFn = addFn;
        },
      ),
    );
  }
}
