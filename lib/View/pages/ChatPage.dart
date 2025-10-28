import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/Utils/CusList.dart';
import 'package:chat_app/Utils/SwiperItem.dart';
import 'package:chat_app/View/widgets/ChatCard.dart';
import 'package:chat_app/Utils/rpx.dart';
import 'package:chat_app/ViewModels/SwiperNotifier.dart';
import 'package:chat_app/View/widgets/ShowMenuShape.dart';

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
    List<ItemType> listData = List.generate(5, (index) {
      return ItemType(
        content: SwiperItem(
          content: ChatCard(title: 'Item $index'),
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
      );
    });

    final GlobalKey btnKey = GlobalKey(); // 用于获取导航栏按钮尺寸定位

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatWithMe'),
        actions: [
          IconButton(
            key: btnKey,
            onPressed: () {
              // 获取按钮节点对象
              final RenderBox btnObj =
                  btnKey.currentContext!.findRenderObject() as RenderBox;
              // 获得相对于屏幕左上角的坐标
              // 注：不传ancestor参数 默认相对于整个屏幕左上角 ancestor表示参考节点
              final Offset offset = btnObj.localToGlobal(Offset.zero);
              // 弹出菜单
              showMenu(
                context: context,
                // Menu相对于屏幕的边距
                position: RelativeRect.fromLTRB(
                  // offset是按钮左上角坐标 但是showMenu会自动计算 避免超出屏幕 所以实际效果是贴着屏幕边缘
                  (offset.dx * 2).rpx, // left 距离屏幕左边缘位置
                  // top 位置在按钮下方 所以要加上按钮高度
                  ((offset.dy + btnObj.size.height) * 2).rpx,
                  0, // right 距离屏幕右边缘位置 只要确定了前两个值后两个可以忽略
                  0, // bottom 一旦top确定 bottom会被忽略
                ),
                color: Color(0xFF545454),
                menuPadding: EdgeInsets.all(0), // 去除默认内边距
                shape: ShowMenuShape(triangleOffset: 20.rpx),
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
        onReady: (OnReadyCallback callbacks) {
          // addItemFn = callbacks.addFn;
          removeFn = callbacks.removeFn;
        },
      ),
    );
  }
}
