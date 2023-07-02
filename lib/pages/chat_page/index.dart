import 'dart:async';

import 'package:flutter/material.dart';

import 'package:my_chat_app/models/message.dart';
import 'package:my_chat_app/constants.dart';
import 'package:my_chat_app/models/profile.dart';
import 'package:my_chat_app/pages/chat_page/chat_bubble.dart';
import 'package:my_chat_app/pages/register_page.dart';

import 'message_bar.dart';

/// 他のユーザーとチャットができるページ
///
/// `ListView`内にチャットが表示され、下の`TextField`から他のユーザーへチャットを送信できる。
class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ChatPage(),
    );
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  /// メッセージをロードするためのストリーム
  late final Stream<List<Message>> _messagesStream;

  /// プロフィール情報をメモリー内にキャッシュしておくための変数
  final Map<String, Profile> _profileCache = {};

  /// メッセージのサブスクリプション
  late final StreamSubscription<List<Message>> _messagesSubscription;

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;
    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at') // 送信日時が新しいものが先に来るようにソート
        .map((maps) => maps
            .map((map) => Message.fromMap(map: map, myUserId: myUserId))
            .toList());
    _messagesSubscription = _messagesStream.listen((messages) {
      for (final message in messages) {
        _loadProfileCache(message.profileId);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // きちんとcancelしてメモリーリークを防ぐ
    _messagesSubscription.cancel();
    super.dispose();
  }

  /// 特定のユーザーのプロフィール情報をロードしてキャッシュする
  Future<void> _loadProfileCache(String profileId) async {
    if (_profileCache[profileId] != null) return;

    final data =
        await supabase.from('profiles').select().eq('id', profileId).single();
    final profile = Profile.fromMap(data);
    setState(() {
      _profileCache[profileId] = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャット'),
        actions: [
          TextButton(
            onPressed: () {
              supabase.auth.signOut();
              Navigator.of(context)
                  .pushAndRemoveUntil(RegisterPage.route(), (route) => false);
            },
            child: Text(
              'ログアウト',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          )
        ],
      ),
      body: StreamBuilder<List<Message>>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: Text('早速メッセージを送ってみよう！'),
                        )
                      : ListView.builder(
                          reverse: true, // 新しいメッセージが下に来るように表示順を上下逆にする
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return ChatBubble(
                              message: message,
                              profile: _profileCache[
                                  message.profileId], // キャッシュしたプロフィール情報を渡す
                            );
                          },
                        ),
                ),
                // ここに後でメッセージ送信ウィジェットを追加
                const MessageBar(), //ここに追加！
              ],
            );
          } else {
            // ローディング中はローダーを表示
            return preloader;
          }
        },
      ),
    );
  }
}
