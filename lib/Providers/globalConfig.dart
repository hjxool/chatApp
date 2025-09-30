import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ViewModels/UnreadNotifier.dart';

final UnreadMessageProvider = NotifierProvider<UnreadMessage, int>(
  UnreadMessage.new,
);
