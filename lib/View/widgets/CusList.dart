import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Providers/globalConfig.dart';

class CusList extends ConsumerWidget {
  const CusList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadNum = ref.read(unreadMessageNum.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => unreadNum.state++,
            child: Text('增加未读消息数'),
          ),
          ElevatedButton(
            onPressed: () => unreadNum.state--,
            child: Text('减少未读消息数'),
          ),
        ],
      ),
    );
  }
}
