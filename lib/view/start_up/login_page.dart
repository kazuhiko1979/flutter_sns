import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/utils/authentication.dart';
import 'package:flutter_course/utils/firestore/users.dart';
import 'package:flutter_course/view/screen.dart';
import 'package:flutter_course/view/start_up/create_account_page.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        width: double.infinity,
        child: Column(children: [
          const SizedBox(
            height: 50,
          ),
          const Text('レシピサイトサンプル',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Container(
              width: 300,
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'メールアドレス',
                ),
              ),
            ),
          ),
          Container(
            width: 300,
            child: TextField(
              controller: passController,
              decoration: const InputDecoration(
                hintText: 'パスワード',
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          RichText(
            text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(text: 'アカウントを作成していない方は'),
                  TextSpan(
                      text: 'こちら',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateAccountPage()));
                        })
                ]),
          ),
          const SizedBox(
            height: 70,
          ),
          // ログインページを破棄した状態（前のページの状態を保持しない:pushReplacement)でScreen pageに画面遷移
          ElevatedButton(
              onPressed: () async {
                var result = await Authentication.emailSignIn(
                    email: emailController.text, pass: passController.text);
                // user credential: ユーザーデータが取得できた場合
                if (result is UserCredential) {
                  // メール認証完了済みユーザーのみログイン可能
                  if (result.user!.emailVerified == true) {
                    var _result = await UserFirestore.getUser(result.user!.uid);
                    if (_result == true) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Screen()));
                    }
                  } else {
                    print('メール認証できていません.');
                  }
                }
              },
              child: Text('emailでログイン')),

          SignInButton(Buttons.Google, onPressed: () async {
            var result = await Authentication.signInWithGoogle();
            if (result is UserCredential) {
              var result = await UserFirestore.getUser(
                  Authentication.currentFirebaseUser!.uid);
              // すでにgoogle認証、新規登録しているユーザーであれば
              if (result == true) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Screen()));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateAccountPage()));
              }
            }
          })
        ]),
      ),
    ));
  }
}
