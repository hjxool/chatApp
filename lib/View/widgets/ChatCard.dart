import 'package:flutter/material.dart';
import 'package:chat_app/Utils/CommonApi.dart';
import 'package:material_symbols_icons/symbols.dart'; // 第三方图标非内置
import 'package:chat_app/Utils/ImgLoad.dart';

class ChatCard extends StatelessWidget {
  final String title;
  const ChatCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/chat_log', arguments: {'title': title});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFEFEFEF), width: 2.rpx),
          ),
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(16.rpx),
            child: SizedBox(
              width: 120.rpx,
              height: 120.rpx,
              child: ImgLoad(
                'https://ts1.tc.mm.bing.net/th/id/OIP-C.Q5v9A7pG3XIaTHTrRCUbSQHaEo?w=291&h=204&c=8&rs=1&qlt=90&o=6&cb=12&dpr=2&pid=3.1&rm=2',
              ),
            ),
          ),
          title: Text(title, style: TextStyle(fontSize: 32.rpx)),
          subtitle: Text(
            '最近消息预览……asdasdasdasdasd沙发上地方i嫂你哦阿森纳都i阿萨德弄i阿森纳',
            style: TextStyle(fontSize: 24.rpx, color: Colors.grey[500]),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('10:41'),
              Icon(Symbols.notifications_off, size: 32.rpx),
            ],
          ),
        ),
      ),
    );
  }
}
