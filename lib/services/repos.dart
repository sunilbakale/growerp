import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'dart:async';
import '../models/models.dart';
import 'dart:convert';

class Repos {
  Dio _client;
  String sessionToken;

  Repos() {
    _client = new Dio();
    if (kReleaseMode == true) {
      // is Release Mode ??
      _client.options.baseUrl = 'https://mobile.growerp.com/rest/';
    } else if (Platform.isAndroid == true) {
      _client.options.baseUrl = 'http://10.0.2.2:8080/rest/';
    } else if (Platform.isIOS == true) {
      _client.options.baseUrl = 'http://localhost:8080/rest/';
    }
    _client.options.connectTimeout = 5000; //5s
    _client.options.receiveTimeout = 3000;
    _client.options.headers = {"Content-Type": "application/json"};
  }

  String responseCode(error) {
    String errorDescription = "";
    if (error is DioError) {
      DioError dioError = error;
      switch (dioError.type) {
        case DioErrorType.CANCEL:
          errorDescription = "Request to API server was cancelled";
          break;
        case DioErrorType.CONNECT_TIMEOUT:
          errorDescription = "Connection timeout with API server";
          break;
        case DioErrorType.DEFAULT:
          errorDescription =
              "Connection to API server failed due to internet connection";
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          errorDescription = "Receive timeout in connection with API server";
          break;
        case DioErrorType.RESPONSE:
          errorDescription =
              "Received invalid status code: ${dioError.response.statusCode}";
          break;
        case DioErrorType.SEND_TIMEOUT:
          errorDescription = "Send timeout in connection with API server";
          break;
      }
    } else {
      errorDescription = "Unexpected error occured";
    }
    return errorDescription;
  }

  Future<bool> connected() async {
    try {
      Response response = await _client.get('moquiSessionToken');
      sessionToken = response.data;
    } catch (e) {
      sessionToken = null;
      print("Exception occured: $e ");
    }
    return sessionToken != null;
  }

  Future<dynamic> getCurrencies() async {
    Response response = await _client.get('s1/growerp/CurrencyList');
    CurrencyList currencyList = currencyListFromJson(response.toString());
    return currencyList.currencyList;
  }

  Future<dynamic> login(
      {@required String username, @required String password}) async {
    print("==logging in password: $password user: $username");
    Response response = await _client.post('s1/growerp/LoginUser', data: {
      'username': username,
      'password': password,
      'moquiSessionToken': sessionToken
    });
    dynamic result = jsonDecode(response.toString());
    if (result["passwordChange"] == "true")
      return "passwordChange";
    else
      return authenticateFromJson(response.toString());
  }

  Future<dynamic> resetPassword({@required String username}) async {
    print("===request password for: $username");
    Response response = await _client.post('s1/growerp/ResetPassword',
        data: {'username': username, 'moquiSessionToken': sessionToken});
    print("==reset password=service ==== ${response}");
    return json.decode(response.toString());
  }

  Future<dynamic> updatePassword(
      {@required String username,
      @required String oldPassword,
      @required String newPassword}) async {
    Response response = await _client.post('s1/growerp/UpdatePassword', data: {
      'username': username,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'moquiSessionToken': sessionToken
    });
    print("==update password=service ==== ${response}");
    return json.decode(response.toString());
  }

  Future<void> logout() async {
    await _client.post('s1/growerp/LogoutUser');
  }

  Future<void> persistAuthenticate(Authenticate authenticate) async {
    await FlutterKeychain.put(
        key: "authenticate", value: authenticateToJson(authenticate));
    return;
  }

  Future<Authenticate> getAuthenticate() async {
    String jsonString = await FlutterKeychain.get(key: "authenticate");
    return authenticateFromJson(jsonString.toString());
  }

  Future<Authenticate> register(
      {@required String companyName,
      String companyPartyId, // if empty will create new company too!
      @required String firstName,
      @required String lastName,
      @required String currency,
      @required String email,
      List data}) async {
    // create some category and product when company empty
    Response response =
        await _client.post('s1/growerp/RegisterUserAndCompany', data: {
      'username': email, 'emailAddress': email,
      'newPassword': 'qqqqqq9!', 'firstName': firstName,
      'lastName': lastName, 'locale': await Devicelocale.currentLocale,
      'companyPartyId': companyPartyId, // for existing companies
      'companyName': companyName, 'currencyUomId': currency,
      'companyEmail': email,
      'partyClassificationId': 'AppHotel',
      'environment': kReleaseMode,
      'transData': ['', '', '', '', 'Standard', 'Luxury', '', '', ''],
      'moquiSessionToken': sessionToken
    });
    return authenticateFromJson(response.toString());
  }
}
