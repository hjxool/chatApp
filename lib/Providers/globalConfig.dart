import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/ViewModels/UnreadNotifier.dart';

final UnreadMessageProvider = NotifierProvider<UnreadMessage, int>(
  UnreadMessage.new,
);
