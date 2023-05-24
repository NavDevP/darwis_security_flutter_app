
import 'dart:convert';

import 'package:cysecurity/background/other_functions.dart';
import 'package:cysecurity/const/api_urls.dart';
import 'package:cysecurity/database/apk_hash/provider.dart';
import 'package:cysecurity/database/user_auth/provider.dart';
import 'package:http/http.dart' as http;

Future reportUrl({String? url}) async {

  UserAuthProvider provider = UserAuthProvider();
  await provider.initializationDone;

  if(url != null && url.isNotEmpty) {
    final response = await http.post(Api.reportUrl,
        body: jsonEncode({"url": url}),
        headers: headers(provider.dataBox.values.first.access_token)
    );
    print(response.body);
    return responseStatus(response);
  }
}


Future responseStatus(http.Response response) async {
  switch(ResponseStatus.fromStatus(response.statusCode)) {
    case ResponseStatus.success:
      return STATUS.COMPLETE;
    case ResponseStatus.unAuthorized:
      return STATUS.ERROR;
    case ResponseStatus.invalidInput:
      return STATUS.ERROR;
    case ResponseStatus.rateLimit:
      return STATUS.LIMIT_EXCEEDED;
    case ResponseStatus.internalError:
      return STATUS.ERROR;
  }
}