import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'dart:convert';
import '../models/models.dart';

class UserRepository {
  Dio _client;
  Response response;
  String sessionToken;

  UserRepository() {
    _client = new Dio();
    if (kReleaseMode) { // is Release Mode ??
      _client.options.baseUrl = 'https://mobile.growerp.com/rest/';
    } else if (Platform.isAndroid) {
      _client.options.baseUrl = 'http://10.0.2.2:8080/rest/';
    } else if (Platform.isIOS) {
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

  Future <bool> getSessionToken() async {
    try {
      Response response = await _client.get('moquiSessionToken');
      sessionToken = response.data;
    } catch(e) {
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

  Future<dynamic> authenticate(
      {@required String username, @required String password}) async {
    response = await _client.post('s1/growerp/LoginUser', data: {
      'username': username,
      'password': password,
      'moquiSessionToken': sessionToken
    });
    print("======login response: $response");
    return authenticateFromJson(response.toString());
  }

  Future<void> deleteToken() async {
    print("repository delete token");
    await FlutterKeychain.remove(key: "authenticate");
    return;
  }

  Future<void> persistToken(Authenticate authenticate) async {
    print("repository persist token: $authenticate");
    await FlutterKeychain.put(
      key: "authenticate", value: authenticateToJson(authenticate));
    return;
  }

  Future<Authenticate> hasAuthenticate() async {
    String jsonString = await FlutterKeychain.get(key: "authenticate");
    print("repository has token: ${jsonString!=null} session: $sessionToken");
    if (jsonString != null) {
      return authenticateFromJson(jsonString);
    } else return null;
  }

  Future<void> signUp(
      {@required String companyName,
      String companyPartyId, // if empty will create new company too!
      @required String firstName,
      @required String lastName,
      @required String currency,
      @required String email,
      List data}) async { // create some category and product when company empty
    response = await _client.post('s1/growerp/RegisterUserAndCompany', data: {
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
  }
}
