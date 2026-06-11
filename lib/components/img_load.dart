import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
          // 加载圆圈
          // Container(
          //   color: Colors.grey[200],
          //   alignment: Alignment.center,
          //   child: FractionallySizedBox(
          //     widthFactor: 0.2,
          //     heightFactor: 0.2,
          //     child: CircularProgressIndicator(strokeWidth: 4.rpx),
          //   ),
          // ),
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
            // 加载时的骨架屏
            loadingBuilder: (context, child, loadingProgress) {
              // null表示加载完了 返回图片
              if (loadingProgress == null) return child;
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!, // 骨架屏底色（较深的灰色）
                highlightColor: Colors.grey[100]!, // 闪烁过去的高亮色（较浅的灰色）
                // period 默认呼吸一次的周期时间为1500ms
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white, // 必须要有一层不透明的底色 Shimmer 才能附着上去
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
