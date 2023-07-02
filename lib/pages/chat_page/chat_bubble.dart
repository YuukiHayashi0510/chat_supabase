import 'package:flutter/material.dart';
import 'package:my_chat_app/constants.dart';
import 'package:my_chat_app/models/message.dart';
import 'package:my_chat_app/models/profile.dart';

/// チャットのメッセージを表示するためのウィジェット
class ChatBubble extends StatelessWidget {
  const ChatBubble({Key? key, required this.message, required this.profile})
      : super(key: key);

  /// メッセージの本文
  final Message message;

  /// 投稿者のプロフィール情報
  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMine) // 自分のメッセージでない時のみプロフィールアイコンを表示
            CircleAvatar(
              child: profile == null
                  ? preloader
                  : Text(profile!.username.substring(0, 2)),
            ),
          const SizedBox(width: 12),
          Text(message.content),
        ],
      ),
    );
  }
}
