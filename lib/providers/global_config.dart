import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/view_models/global_notifier.dart';

final UnreadMessageProvider = NotifierProvider<UnreadMessage, int>(
  UnreadMessage.new,
);

final UserConfigProvider =
    AsyncNotifierProvider<UserConfigNotifier, UserConfigState>(
      UserConfigNotifier.new,
    );
