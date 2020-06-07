import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:devicelocale/devicelocale.dart';
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
              "Internet or server problem?";
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
    if (e.response?.data != null && e.response?.data['errorCode'] == 400) {
      print('''Moqui data... errorCode: ${e.response.data['errorCode']}
            errors: ${e.response.data['errors']}''');
      errorDescription = e.response.data['errors'];
    }
    print("====returning error message: $errorDescription");
    return errorDescription;
  }
// -----------------------------general ------------------------
  Future<dynamic> connected() async {
    try {
      Response response = await _client.get('moquiSessionToken');
      sessionToken = response.data;
      return sessionToken != null;
    } catch (e) {
      return responseMessage(e);
    }
  }
  Future<dynamic> getCurrencies() async {
    try {
      Response response = await _client.get('s1/growerp/100/CurrencyList');
      CurrencyIdList currencyList = currencyIdListFromJson(response.toString());
      return currencyList.currencyIdList;
    } catch(e) {
      return responseMessage(e);
    }
  }

  Future<dynamic> login(
      {@required String username, @required String password}) async {
    try {
      Response response = await _client.post('s1/growerp/100/Login', data: {
        'username': username,
        'password': password,
        'moquiSessionToken': sessionToken
      });
      dynamic result = jsonDecode(response.toString());
      if (result["passwordChange"] == "true")
        return "passwordChange";
      else
        this.apiKey = result["apiKey"];
        return authenticateFromJson(response.toString());
    } catch(e) {
      return(responseMessage(e));
    }
  }

  Future<dynamic> resetPassword({@required String username}) async {
    try {
      Response result = await _client.post('s1/growerp/100/ResetPassword',
        data: {'username': username, 'moquiSessionToken': sessionToken});
      return json.decode(result.toString());
    } catch(e) {
      return responseMessage(e);
    }
  }

  Future<dynamic> updatePassword(
      {@required String username,
      @required String oldPassword,
      @required String newPassword}) async {
    try {  
      Response response = await _client.put('s1/growerp/100/Password', data: {
        'username': username,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'moquiSessionToken': sessionToken
      });
      // print("==update password=service ==== ${response}");
      return json.decode(response.toString());
    } catch(e) {
      return responseMessage(e);
    }
  }

  Future<dynamic> logout() async {
    this.apiKey = null;
    _client.options.headers['api_key'] = apiKey;
    try {
      await _client.post('logout');
      Authenticate authenticate = await getAuthenticate();
      authenticate.apiKey = null;
      persistAuthenticate(authenticate);
      return authenticate;
    } catch(e) {
      return responseMessage(e);
    }
  }

  Future<void> persistAuthenticate(Authenticate authenticate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authenticate', authenticateToJson(authenticate));    
  }

  Future<Authenticate> getAuthenticate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String result = prefs.getString('authenticate');
    if (result != null) return authenticateFromJson(result);
    return null;
  }

  Future<dynamic> register(
      {@required String companyName,
      String companyPartyId, // if empty will create new company too!
      @required String firstName,
      @required String lastName,
      @required String currency,
      @required String email,
      List data}) async {
    try {
      // create some category and product when company empty
      var locale;
      if (!kIsWeb) locale = await Devicelocale.currentLocale;
      Response response =
          await _client.post('s1/growerp/100/UserAndCompany', data: {
        'username': email, 'emailAddress': email,
        'newPassword': 'qqqqqq9!', 'firstName': firstName,
        'lastName': lastName, 'locale': locale,
        'companyPartyId': companyPartyId, // for existing companies
        'companyName': companyName, 'currencyUomId': currency,
        'companyEmail': email,
        'partyClassificationId': 'AppHotel',
        'environment': kReleaseMode,
        'transData': ['', '', '', '', 'Standard', 'Luxury', '', '', ''],
        'moquiSessionToken': sessionToken
      });
      return authenticateFromJson(response.toString());
    } catch(e) {
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
      return responseMessage(e);
    }
  }

  Future<dynamic> getOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String orderJson = prefs.getString('orderAndItems');
      if (orderJson != null) return orderFromJson(orderJson);
      return null;
    } catch (e) {
      return responseMessage(e);
    }
  }

  Future<void> saveOrder({Order order}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('orderAndItems', orderToJson(order));    
    } catch (e) {
      return responseMessage(e);
    }
  }

  Future<dynamic> getOrders() async {
    String basicAuth =
      'Basic ' + base64Encode(utf8.encode('admin@growerp.com:qqqqqq9!'));
    try {
      _client.options.headers['authorization'] = basicAuth;
      Response response = await _client.get(
        's1/growerp/100/Order');
      return ordersFromJson(response.toString());
    } catch (e) {
      return responseMessage(e);
    }
  }

  Future<dynamic> createOrder({Order order}) async {
    try {
      Response response = await _client.get(
        's1/growerp/100/Paypal',
          queryParameters: {"order": order});
//      return paymentFromJson(response.toString());
      return null;
    } catch (e) {
      return responseMessage(e);
    }
  }
}
