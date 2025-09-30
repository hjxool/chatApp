import 'package:flutter/material.dart';
import '../../Utils/CusList.dart';
import '../../Utils/SwiperItem.dart';
import '../widgets/ChatCard.dart';
import '../../Utils/rpx.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 测试数据
    List<ItemType> listData = List.generate(3, (index) {
      return ItemType(
        content: SwiperItem(
          content: ChatCard(title: 'Item $index'),
          rightButtons: [
            SwiperButton(color: Colors.red, label: '删除', tapFn: () {}),
            SwiperButton(color: Colors.blue, label: '置顶', tapFn: () {}),
            SwiperButton(color: Colors.orange, label: '免打扰', tapFn: () {}),
          ],
          rightWidth: 360.rpx,
        ),
        key: ValueKey('Item $index'),
      );
    });
    late void Function(ItemType value) addItemFn;

    return Scaffold(
      body: CusList(
        listData: listData,
        onReady: ({required void Function(ItemType value) addFn}) {
          addItemFn = addFn;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 调用添加函数
          addItemFn(
            ItemType(
              content: SwiperItem(
                content: ChatCard(title: 'Item ${listData.length}'),
              ),
              key: ValueKey('Item ${listData.length}'),
            ),
          );
          listData.add(
            ItemType(
              content: SwiperItem(
                content: ChatCard(title: 'Item ${listData.length}'),
              ),
              key: ValueKey('Item ${listData.length}'),
            ),
          ); // 保证内外数据同步 避免重新build时丢失数据
        },
        backgroundColor: Color(0xFF07B75B),
        child: Icon(Icons.add),
      ),
    );
  }
}
