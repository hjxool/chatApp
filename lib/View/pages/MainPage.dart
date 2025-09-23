import 'package:flutter/cupertino.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('主页')),
      child: Center(child: Text('Main Page', style: TextStyle(fontSize: 24))),
    );
  }
}
