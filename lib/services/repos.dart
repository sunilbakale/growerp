import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'dart:async';
import '../models/models.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Repos {
  Dio _client;
  String sessionToken;
  String apiKey;

  Repos() {
    _client = new Dio();
    if (kReleaseMode) {
      //platform not supported on the web
      // is Release Mode ??
      _client.options.baseUrl = 'https://mobile.growerp.com/rest/';
    } else if (kIsWeb || Platform.isIOS) {
      _client.options.baseUrl = 'http://localhost:8080/rest/';
    } else if (Platform.isAndroid) {
      _client.options.baseUrl = 'http://10.0.2.2:8080/rest/';
    }
    _client.options.connectTimeout = 5000; //5s
    _client.options.receiveTimeout = 8000;
    _client.options.headers = {"Content-Type": "application/json"};
/*
    _client.interceptors.add(InterceptorsWrapper(
      onRequest:(RequestOptions options) async {
        print("===Outgoing dio request options: ${options.toString()}");
      // Do something before request is sent
      return options; //continue
      // If you want to resolve the request with some custom data，
      // you can return a `Response` object or return `dio.resolve(data)`.
      // If you want to reject the request with a error message,
      // you can return a `DioError` object or return `dio.reject(errMsg)`
      },
      onResponse:(Response response) async {
      // Do something with response data
      return response; // continue
      },
      onError: (DioError e) async {
      // Do something with response error
      return  e;//continue
      }
    ));
*/
  }

  String responseMessage(e) {
    String errorDescription = "Unexpected DioError";
    if (e is DioError) {
      DioError dioError = e;
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
              "Received invalid status code: ${dioError?.response?.statusCode}";
          break;
        case DioErrorType.SEND_TIMEOUT:
          errorDescription = "Send timeout in connection with API server";
          break;
      }
    }
//    if (e.response != null) {
      // print("dio error data: ${e.response.data}");
      // print("dio error headers: ${e.response.headers}");
      // print("dio error request: ${e.response.request}");
//    } else {
      // Something happened in setting up or sending the request that triggered an Error
      // print("dio no response, request: ${e.request}");
      // print("dio no response, message: ${e.message}");
//    }
//    if (e.response?.data != null && e.response?.data['errorCode'] == 400) {
//      print('''Moqui data... errorCode: ${e.response.data['errorCode']}
//            errors: ${e.response.data['errors']}''');
//      errorDescription = e.response.data['errors'];
//    }
    print("====returning error message: $errorDescription");
    return errorDescription;
  }

  Future<dynamic> connected() async {
    try {
      Response response = await _client.get('moquiSessionToken');
      sessionToken = response.data;
      return sessionToken != null;
    } catch (e) {
      return responseMessage(e);
    }
  }

  Future<dynamic> getUserAndCompany({String companyPartyId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userCompJson = prefs.getString('userAndCompany');
      if (userCompJson != null) return userAndCompanyFromJson(userCompJson);
      Response response = await _client.get('s1/growerp/100/UserAndCompany',
          queryParameters: {"companyPartyId": companyPartyId});
      await prefs.setString('userAndCompany', response.toString());    
      return userAndCompanyFromJson(response.toString());
    } catch (e) {
      debugPrint("=1=repos: $e");
      return responseMessage(e);
    }
  }

  Future<dynamic> getCatalog({String companyPartyId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String catProdJson = prefs.getString('categoriesAndProducts');
      if (catProdJson != null) return catalogFromJson(catProdJson);
      Response response = await _client.get(
          's1/growerp/100/CategoriesAndProducts',
          queryParameters: {"companyPartyId": companyPartyId});
      await prefs.setString('categoriesAndProducts', response.toString());    
      return catalogFromJson(response.toString());
    } catch (e) {
      debugPrint("=2=repos: $e");
      return responseMessage(e);
    }
  }
}
