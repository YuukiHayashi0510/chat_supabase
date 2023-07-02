import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Initializer {
  static Future<void> init() async {
    await Future.wait([
      (() async {
        await dotenv.load(fileName: '.env');
      })(),
      (() async {
        await Supabase.initialize(
          url: dotenv.get('SUPABASE_URL'),
          anonKey: dotenv.get('SUPABASE_ANON_KEY'),
        );
      })(),
    ]);
  }
}

/// Supabase にアクセスするためのクライアントインスタンス
final supabase = Supabase.instance.client;

/// シンプルなプリローダー
const preloader =
    Center(child: CircularProgressIndicator(color: Colors.orange));

/// ちょっとした隙間を作るのに便利なウィジェット
const formSpacer = SizedBox(width: 16, height: 16);

/// フォームのパディング
const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

/// 予期せぬエラーが起きた際のエラーメッセージ
const unexpectedErrorMessage = '予期せぬエラーが起きました';

/// Snackbarを楽に表示させるための拡張メソッド
extension ShowSnackBar on BuildContext {
  /// 標準的なSnackbarを表示
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  /// エラーが起きた際のSnackbarを表示
  void showErrorSnackBar({required String message}) {
    showSnackBar(
      message: message,
      backgroundColor: Theme.of(this).colorScheme.error,
    );
  }
}
