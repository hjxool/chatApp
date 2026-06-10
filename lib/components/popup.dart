import 'package:flutter/material.dart';
import 'common_api.dart';

Widget _rowStyle(
  String label, {
  Color? color,
  bool bottomLine = true,
  VoidCallback? onTap,
}) {
  // InkWell 必须依附于 Material 才能显示水波纹
  return Material(
    color: Colors.white,
    child: InkWell(
      onTap: onTap,
      child: Container(
        height: 120.rpx,
        padding: EdgeInsets.symmetric(horizontal: 20.rpx),
        decoration: BoxDecoration(
          // 使用InkWell时 自组件的背景色必须移到Ink组件或外部 否则子组件背景色会盖住水波纹
          // color: Colors.white,
          border: bottomLine
              ? BoxBorder.fromLTRB(
                  bottom: BorderSide(color: Colors.grey[100]!, width: 12.rpx),
                )
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color ?? Colors.black87,
              fontSize: 32.rpx,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

class PopItem {
  final String label;
  final Color? color;
  final void Function(PopItem) onTap;
  final JsonMap? extra;

  PopItem({required this.label, this.color, required this.onTap, this.extra});
  JsonMap toJson() => {'label': label, ...?extra};
}

// 底部弹窗
void popBottom({required BuildContext context, required List<PopItem> items}) {
  showModalBottomSheet(
    context: context,
    // 支持圆角裁切 如果不加 自定义的圆角背景会被顶层的直角阴影覆盖
    clipBehavior: Clip.antiAlias,
    // 设置弹窗的外观形状
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...items.map(
            (e) => _rowStyle(
              e.label,
              color: e.color,
              onTap: () {
                e.onTap(e);
                Navigator.pop(context);
              },
            ),
          ),
          // SizedBox(
          //   // 相当于width：100% 只能用于父组件尺寸有限制的情况
          //   // 如当前在Column下 其横向宽度受限 所以横向可以用double.infinity
          //   width: double.infinity,
          // ),
          SafeArea(
            top: false,
            child: _rowStyle(
              '取消',
              bottomLine: false,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      );
    },
  );
}
