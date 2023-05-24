import 'dart:async';
import 'dart:convert';

import 'package:cysecurity/background/other_functions.dart';
import 'package:cysecurity/const/api_urls.dart';
import 'package:cysecurity/database/user_auth/provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;


enum ReportUrlStatus {SUBMITTED, ERROR, LOADING,NOT_STARTED,NOT_LINK}

@immutable
class ReportUrl {
  const ReportUrl({required this.status});

  // All properties should be `final` on our class.
  final ReportUrlStatus status;

  // Since Todo is immutable, we implement a method that allows cloning the
  // Todo with slightly different content.
  ReportUrl copyWith({ReportUrlStatus? status}) {
    return ReportUrl(
      status: status ?? this.status,
    );
  }
}

// The StateNotifier class that will be passed to our StateNotifierProvider.
// This class should not expose state outside of its "state" property, which means
// no public getters/properties!
// The public methods on this class will be what allow the UI to modify the state.
class ReportNotifier extends StateNotifier<ReportUrl> {
  // We initialize the list of todos to an empty list
  ReportNotifier(): super(const ReportUrl(status: ReportUrlStatus.NOT_STARTED));


  RegExp linkRegExp = new RegExp(r'([a-z0-9_\-]{1,5}:\/\/)?(([a-z0-9_\-]{1,}):([a-z0-9_\-]{1,})\@)?((www\.)|([a-z0-9_\-]{1,}\.)+)?([a-z0-9_\-]{3,})(\.[a-z]{2,4})(\/([a-z0-9_\-]{1,}\/)+)?([a-z0-9_\-]{1,})?(\.[a-z]{2,})?(\?)?(((\&)?[a-z0-9_\-]{1,}(\=[a-z0-9_\-]{1,})?)+)?');

  TextEditingController linkTextController = TextEditingController();


  bool? validateLink() {
    if(linkTextController.text.isNotEmpty) {
      final check = linkRegExp.hasMatch(linkTextController.text);
      if (check) {
        return true;
      }
      return false;
    }
    return null;
  }

  // Let's allow the UI to add todos.
  Future processSubmit() async{
    try{
      UserAuthProvider provider = UserAuthProvider();
      await provider.initializationDone;
      if(validateLink() == null || validateLink() == false){
        state = const ReportUrl(status: ReportUrlStatus.NOT_LINK);
      }else {
        state = const ReportUrl(status: ReportUrlStatus.LOADING);
        final response = await http.post(Api.reportUrl,
            body: jsonEncode({"url": linkTextController.text}),
            headers: headers(provider.dataBox.values.first.access_token)
        );
        ReportUrlStatus responseUrlStatus = await responseStatus(response);
        state = ReportUrl(status: responseUrlStatus);
        if(responseUrlStatus == ReportUrlStatus.SUBMITTED) {
          Timer(const Duration(seconds: 1), () =>
          {
            state = const ReportUrl(status: ReportUrlStatus.NOT_STARTED),
            linkTextController.text = ""
          });
        }
      }
    }catch(error){
      state = const ReportUrl(status: ReportUrlStatus.ERROR);
    }
  }
}


Future responseStatus(http.Response response) async {
  switch(ResponseStatus.fromStatus(response.statusCode)) {
    case ResponseStatus.success:
      return ReportUrlStatus.SUBMITTED;
    case ResponseStatus.unAuthorized:
      return ReportUrlStatus.ERROR;
    case ResponseStatus.invalidInput:
      return ReportUrlStatus.NOT_LINK;
    case ResponseStatus.rateLimit:
      return ReportUrlStatus.ERROR;
    case ResponseStatus.internalError:
      return ReportUrlStatus.ERROR;
  }
}

// Finally, we are using StateNotifierProvider to allow the UI to interact with
final reportProvider = StateNotifierProvider<ReportNotifier, ReportUrl>((ref) {
  return ReportNotifier();
});

