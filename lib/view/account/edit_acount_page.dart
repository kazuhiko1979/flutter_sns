import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_course/model/account.dart';
import 'package:flutter_course/utils/authentication.dart';
import 'package:flutter_course/utils/firestore/users.dart';
import 'package:flutter_course/utils/function_utils.dart';
import 'package:flutter_course/utils/widget_utils.dart';
import 'package:flutter_course/view/start_up/login_page.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  // 編集時に既存のプロフィールデータを取得
  Account myAccount = Authentication.myAccount!;

  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();

  File? image;

  // image 更新時の分岐メソッド
  ImageProvider getImage() {
    if (image == null) {
      return NetworkImage(myAccount.imagePath);
    } else {
      return FileImage(image!);
    }
  }

  //プロフィールデータ初期値を設定
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: myAccount.name);
    userIdController = TextEditingController(text: myAccount.userId);
    selfIntroductionController =
        TextEditingController(text: myAccount.selfIntroduction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: WidgetUtils.createAppBar('プロフィール編集'),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(children: [
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
                  foregroundImage: getImage(),
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
              SizedBox(height: 50),
              ElevatedButton(
                  onPressed: () async {
                    // 登録情報がすべて入力されている場合は、loginPage（元のページ）に推移
                    if (nameController.text.isNotEmpty &&
                        userIdController.text.isNotEmpty &&
                        selfIntroductionController.text.isNotEmpty) {
                      String imagePath = '';
                      if (image == null) {
                        imagePath = myAccount.imagePath;
                      } else {
                        var result = await FunctionUtils.uploadImage(
                            myAccount.id, image!);
                        imagePath = result;
                      }
                      Account updateAccount = Account(
                          id: myAccount.id,
                          name: nameController.text,
                          userId: userIdController.text,
                          selfIntroduction: selfIntroductionController.text,
                          imagePath: imagePath);

                      Authentication.myAccount = updateAccount;

                      var result = UserFirestore.updateUser(updateAccount);
                      if (result == true) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  child: const Text('更新')),
              SizedBox(height: 50),
              // ログアウト
              ElevatedButton(
                  onPressed: () {
                    Authentication.signOut();
                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text('ログアウト')),
              // アカウント削除
              SizedBox(height: 50),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () {
                    // ユーザー削除
                    UserFirestore.deleteUser(myAccount.id);
                    //　Auth削除
                    Authentication.deleteAuth();
                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text('アカウント削除'))
            ]),
          ),
        ));
  }
}
