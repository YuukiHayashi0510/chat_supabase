import 'package:flutter/material.dart';
import 'package:my_chat_app/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// チャット入力用のテキストフィールドと送信ボタンを持つウィジェット
class MessageBar extends StatefulWidget {
  const MessageBar({
    Key? key,
  }) : super(key: key);

  @override
  State<MessageBar> createState() => MessageBarState();
}

class MessageBarState extends State<MessageBar> {
  late final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null, // 複数行入力可能にする
                  autofocus: true, // ページを開いた際に自動的にフォーカスする
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'メッセージを入力',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _submitMessage(),
                child: const Text('送信'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// メッセージを送信する
  void _submitMessage() async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      // 入力された文字がなければ何もしない
      return;
    }
    _textController.clear();
    try {
      await supabase.from('messages').insert({
        'profile_id': myUserId,
        'content': text,
      });
    } on PostgrestException catch (error) {
      // エラーが発生した場合はエラーメッセージを表示
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      // 予期せぬエラーが起きた際は予期せぬエラー用のメッセージを表示
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}
