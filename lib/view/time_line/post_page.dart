import 'package:flutter/material.dart';
import 'package:flutter_course/model/post.dart';
import 'package:flutter_course/utils/authentication.dart';
import 'package:flutter_course/utils/firestore/posts.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  //投稿データ
  TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '新規投稿',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 2,
          // 元に戻る矢印の色は黒に（初期値は白）
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                //投稿データ
                controller: contentController,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    // 新規投稿
                    if (contentController.text.isNotEmpty) {
                      Post newPost = Post(
                        content: contentController.text,
                        postAccountId: Authentication.myAccount!.id,
                      );
                      var result = await PostFirestore.addPost(newPost);
                      if (result == true) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text('投稿'))
            ],
          ),
        ));
  }
}
