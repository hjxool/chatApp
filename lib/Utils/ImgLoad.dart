import 'package:chat_app/Utils/rpx.dart';
import 'package:flutter/material.dart';

class ImgLoad extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ImgLoad(this.url, {super.key, this.fit = BoxFit.cover});

  bool get _isNetworkImg =>
      url.startsWith('http://') || url.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (_isNetworkImg) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 0.2,
              heightFactor: 0.2,
              child: CircularProgressIndicator(strokeWidth: 4.rpx),
            ),
          ),
          Image.network(
            url,
            fit: fit,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              // 如果是内存缓存里直接拿到的就直接显示
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1, // frame==null 表示还没渲染出来
                duration: const Duration(milliseconds: 300),
                child: child,
              );
            },
          ),
        ],
      );
    } else {
      return TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ), // 注意要指定Tween类型 否则dynamic value会出问题
        builder: (BuildContext context, dynamic value, Widget? child) {
          return Opacity(opacity: value, child: child);
        },
        child: Image.asset(url, fit: fit),
      );
    }
  }
}
