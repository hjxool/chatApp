import 'package:flutter/material.dart';
import 'dart:math' as math;

// 流光背景组件
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    // 背景循环动画
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withValues(
                  alpha:
                      (0.5 +
                              0.5 *
                                  math.sin(
                                    _backgroundController.value * 2 * math.pi,
                                  ))
                          .clamp(0.0, 1.0),
                ),
                Colors.purple.withValues(
                  alpha:
                      (0.05 +
                              0.05 *
                                  math.cos(
                                    _backgroundController.value * 2 * math.pi,
                                  ))
                          .clamp(0.0, 1.0),
                ),
                Colors.white,
              ],
            ),
          ),
        );
      },
    );
  }
}
