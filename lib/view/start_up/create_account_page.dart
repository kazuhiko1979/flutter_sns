import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/model/account.dart';
import 'package:flutter_course/utils/authentication.dart';
import 'package:flutter_course/utils/firestore/users.dart';
import 'package:flutter_course/utils/function_utils.dart';
import 'package:flutter_course/utils/widget_utils.dart';
import 'package:flutter_course/view/screen.dart';
import 'package:flutter_course/view/start_up/check_email_page.dart';

class CreateAccountPage extends StatefulWidget {
  // Google認証かどうかの判断
  final bool isSignInWithGoogle;
  // 初期値はfalse
  CreateAccountPage({this.isSignInWithGoogle = false});

  // const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // 新規登録内容
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  // for image picker アイコン画像選択時
  File? image;
  // ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // widget_utilsを利用し、新規登録画面と、編集画面を共有
        appBar: WidgetUtils.createAppBar('新規登録'),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () async {
                    var result = await FunctionUtils.getImageFromGallery();
                    if (result != null) {
                      setState(() {
                        image = File(result.path);
                      });
                    }
                  },
                  child: CircleAvatar(
                    // 画像がない場合の処理
                    foregroundImage: image == null ? null : FileImage(image!),
                    radius: 40,
                    child: Icon(Icons.add),
                  ),
                ),
                Container(
                  width: 300,
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: '名前'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Container(
                    width: 300,
                    child: TextField(
                      controller: userIdController,
                      decoration: const InputDecoration(hintText: 'ユーザーID'),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  child: TextField(
                    controller: selfIntroductionController,
                    decoration: const InputDecoration(hintText: '自己紹介'),
                  ),
                ),
                // google認証が初めてのユーザはメールアドレス、パスワード登録非表示
                widget.isSignInWithGoogle
                    ? Container()
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Container(
                              width: 300,
                              child: TextField(
                                controller: emailController,
                                decoration:
                                    const InputDecoration(hintText: 'メールアドレス'),
                              ),
                            ),
                          ),
                          Container(
                            width: 300,
                            child: TextField(
                              controller: passController,
                              decoration: InputDecoration(hintText: 'パスワード'),
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: 50),
                ElevatedButton(
                    onPressed: () async {
                      // 登録情報がすべて入力されている場合は、loginPage（元のページ）に推移
                      if (nameController.text.isNotEmpty &&
                          userIdController.text.isNotEmpty &&
                          selfIntroductionController.text.isNotEmpty) {
                        // Google認証とメール認証の分岐
                        if (widget.isSignInWithGoogle) {
                          var _result = await createAccount(
                              Authentication.currentFirebaseUser!.uid);
                          if (_result == true) {
                            await UserFirestore.getUser(
                                Authentication.currentFirebaseUser!.uid);
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Screen()));
                          }
                        }
                        var result = await Authentication.signUp(
                            email: emailController.text,
                            pass: passController.text);

                        // Authentication: UserCredentialでresultの分岐
                        if (result is UserCredential) {
                          // userのuidを画像のIDとしてcloud storageに保存される

                          var _result = await createAccount(result.user!.uid);
                          if (_result == true) {
                            // メール認証機能
                            result.user!.sendEmailVerification();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CheckEmailPage(
                                        email: emailController.text,
                                        pass: passController.text)));
                          }
                        }
                      }
                    },
                    child: const Text('アカウントを作成')),
              ],
            ),
          ),
        ));
  }

  Future<dynamic> createAccount(String uid) async {
    // 登録情報をFirestoreDBに保存
    String imagePath = await FunctionUtils.uploadImage(uid, image!);
    Account newAccount = Account(
      id: uid,
      name: nameController.text,
      userId: userIdController.text,
      selfIntroduction: selfIntroductionController.text,
      imagePath: imagePath,
    );
    var _result = await UserFirestore.setUser(newAccount);
    return _result;
  }
}
