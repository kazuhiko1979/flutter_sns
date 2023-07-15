import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_course/model/account.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static User? currentFirebaseUser;
  static Account? myAccount;

  static Future<dynamic> signUp(
      {required String email, required String pass}) async {
    try {
      // User IDをnewAccountに格納し、アイコン画像をCloud Storageに保存時のユニークIDとして利用
      UserCredential newAccount = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: pass);
      print('auth登録完了');
      return newAccount;
    } on FirebaseAuthException catch (e) {
      print('auth登録エラー');
      return '登録エラーが発生しました';
    }
  }

  static Future<dynamic> emailSignIn(
      {required String email, required String pass}) async {
    try {
      final UserCredential _result = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: pass);
      currentFirebaseUser = _result.user;
      print('authサインイン完了');
      // user credential: ユーザーデータを返す
      return _result;
    } on FirebaseAuthException catch (e) {
      print('authサインインエラー $e');
      return false;
    }
  }

  // Google サインイン
  static Future<dynamic> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
        final UserCredential _result =
            await _firebaseAuth.signInWithCredential(credential);
        currentFirebaseUser = _result.user;
        print('Googleログイン完了');
        return _result;
      }
    } on FirebaseAuthException catch (e) {
      print('Googleログインエラー： $e');
      return false;
    }
  }

  // ログアウト
  static Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // アカウント削除
  static Future<void> deleteAuth() async {
    await currentFirebaseUser!.delete();
  }
}
