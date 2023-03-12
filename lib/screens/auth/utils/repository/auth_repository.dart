import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
      // accessToken: googleAuth?.accessToken,
      // idToken: googleAuth?.idToken,
      print(googleAuth?.accessToken);

      //login send credential here
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      //logout here
    } catch (e) {
      throw Exception(e);
    }
  }
}