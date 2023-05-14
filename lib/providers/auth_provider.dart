// The state of our StateNotifier should be immutable.
// We could also use packages like Freezed to help with the implementation.
import 'dart:convert';

import 'package:cysecurity/const/api_urls.dart';
import 'package:cysecurity/database/user_auth/model/model.dart';
import 'package:cysecurity/database/user_auth/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

enum AUTH_STATUS  {AUTHENTICATED, UNAUTHENTICATED, ERROR, LOADING}

@immutable
class UserLogin {
  const UserLogin({required this.status});

  // All properties should be `final` on our class.
  final AUTH_STATUS status;

  // Since Todo is immutable, we implement a method that allows cloning the
  // Todo with slightly different content.
  UserLogin copyWith({AUTH_STATUS? status}) {
    return UserLogin(
      status: status ?? this.status,
    );
  }
}

// The StateNotifier class that will be passed to our StateNotifierProvider.
// This class should not expose state outside of its "state" property, which means
// no public getters/properties!
// The public methods on this class will be what allow the UI to modify the state.
class LoginNotifier extends StateNotifier<UserLogin> {
  // We initialize the list of todos to an empty list
  LoginNotifier(): super(const UserLogin(status: AUTH_STATUS.UNAUTHENTICATED));

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
    scopes: <String>[
      'email',
      'profile'
    ],
  );


  // Let's allow the UI to add todos.
  Future processLogin(String token, GoogleSignInAccount profile) async{
    try{
      final response = await http.post(Api.googleLogin,body: {
        "access_token": token
      });
      if(response.statusCode == 200){
        var json = jsonDecode(response.body);
        loginUser(true, json, profile);
      }else{
        loginUser(false,{},{});
      }
    }catch(error){
      state = const UserLogin(status: AUTH_STATUS.ERROR);
    }
  }

  Future loginUser(bool loggedIn, data, profile) async{
    if(loggedIn) {
      UserAuthProvider provider = UserAuthProvider();
      await provider.initializationDone;
      await provider.insertToken(UserAuthModel(access_token: data['access_token'], refresh_token: data['refresh_token'], signedOn: DateTime.now(), access_token_expiry_minutes: data['access_token_expiry_minutes'],refresh_token_expiry_days: data['refresh_token_expiry_days'], name: profile.displayName,email: profile.email));
      state = const UserLogin(status: AUTH_STATUS.AUTHENTICATED);
    }else{
      state = const UserLogin(status: AUTH_STATUS.ERROR);
    }
  }

  Future<void> handleSignIn() async {
    try {
      var google = await _googleSignIn.signIn();
      final GoogleSignInAccount googleSignInData = google!;
      final GoogleSignInAuthentication googleSignInAuthentication = await google.authentication;
      await processLogin(googleSignInAuthentication.accessToken!,googleSignInData);
    } catch (error) {
      print(error);
      state = const UserLogin(status: AUTH_STATUS.ERROR);
    }
  }
}

// Finally, we are using StateNotifierProvider to allow the UI to interact with
// our TodosNotifier class.
final loginProvider = StateNotifierProvider<LoginNotifier, UserLogin>((ref) {
  return LoginNotifier();
});

