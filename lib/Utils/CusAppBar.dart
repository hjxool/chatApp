import 'package:chat_app/Utils/CommonApi.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// appBar配置项要的是PreferredSizeWidget类型的组件 因此要实现抽象类PreferredSizeWidget
class CusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CusAppBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // 使用默认的bar高度

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Navigator.canPop(context)
          ? IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Symbols.arrow_back_ios_new),
            )
          : null,
      title: Text(title),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(2.rpx),
        child: Divider(
          height: 2.rpx,
          thickness: 2.rpx,
          color: Color(0xFFE5E5E5), // 微信风格发丝线,
        ),
      ),
    );
  }
}
