import 'package:chat_app/components/cus_app_bar.dart';
import 'package:chat_app/components/cus_show_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/components/cus_list.dart';
import 'package:chat_app/components/swiper_item.dart';
import 'package:chat_app/components/chat_card.dart';
import 'package:chat_app/components/common_api.dart';
import 'package:chat_app/providers/swiper_notifier.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // void Function(ItemType value)? addItemFn;
  void Function(Key key)? removeFn;

  @override
  Widget build(BuildContext context) {
    // 当前页管理Swiper组件的数据源
    final swiperProvider = NotifierProvider<SwiperNotifier, SwiperState>(
      SwiperNotifier.new,
    );

    // 测试数据
    List<ItemType> listData = List.generate(
      5,
      (index) => ItemType(
        content: SwiperItem(
          content: ChatCard(title: 'Item $index', userId: '222'),
          rightButtons: [
            SwiperButton(
              color: Colors.red,
              label: '删除',
              tapFn: () {
                // 必须将removeFn设为类成员变量 保存它的引用 在onReady中根据引用更新值 而tapFn闭包中也是根据引用调用
                // 如果不设置成员变量 则闭包会捕获当时build的removeFn值 而onready有可能是在下一次build时才调用 从而导致闭包中removeFn为空指针
                // 注：成员变量是以内存引用的形式存在 不会随build而重建
                removeFn?.call(ValueKey('Item $index'));
              },
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
      ),
    );

    final GlobalKey btnKey = GlobalKey(); // 用于获取导航栏按钮尺寸定位

    return Scaffold(
      appBar: CusAppBar(
        title: 'ChatWithMe',
        actions: [
          IconButton(
            key: btnKey,
            onPressed: () {
              CusShowMenu.popMenu(
                buttonKey: btnKey,
                context: context,
                items: [
                  PopupMenuItem(
                    value: 'add',
                    child: Row(
                      children: [
                        Icon(Icons.person_add, color: Colors.white),
                        SizedBox(width: 10.rpx),
                        Text('添加朋友', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'scan',
                    child: Row(
                      children: [
                        Icon(Icons.qr_code_scanner, color: Colors.white),
                        SizedBox(width: 10.rpx),
                        Text('扫一扫', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              );
            },
            icon: Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),
      body: CusList(
        listData: listData,
        onReady: (OnReadyCallback callbacks) {
          // addItemFn = callbacks.addFn;
          removeFn = callbacks.removeFn;
        },
      ),
    );
  }
}
