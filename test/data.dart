import 'package:growerp/models/@models.dart';

final Authenticate authenticateNoKey = authenticateFromJson('''
           {  "company": {"name": "dummyCompany",
                          "currency": "dummyCurrency"},
              "user": {"firstName": "dummyFirstName",
                       "lastName": "dummyLastName",
                       "email": "dummyEmail",
                       "name": "dummyEmail"},
              "apiKey": null}
      ''');
final Authenticate authenticate = authenticateFromJson('''
           {  "company": {"name": "dummyCompany",
                          "currency": "dummyCurrency"},
              "user": {"firstName": "dummyFirstName",
                       "lastName": "dummyLastName",
                       "email": "dummyEmail",
                       "name": "dummyEmail"},
              "apiKey": "dummyKey"}
      ''');

final String errorMessage = 'Dummy error message';
final String companyName = 'Dummy Company Name';
final String firstName = 'First name';
final String lastName = 'Last name';
final String username = 'dummyUsername';
final String password = 'dummyPassword';
final String email = 'dummy@example.com';

final Catalog catalog = catalogFromJson('''
    { "categories": [ 
      {"productCategoryId": "firstCategory", "categoryName": "This is the first category",
      "description": "this is the long description of category first"},
      {"productCategoryId": "secondCategory", "categoryName": "This is the second category",
      "description": "this is the long description of category second"}
      ],
      "products": [
      {"productId": "firstProduct", "name": "This is the first product",
      "currencyId": "USD",
      "price": "23.99", "productCategoryId": "firstCategory"},
      {"productId": "secondProduct", "name": "This is the second product",
      "currencyId": "USD",
      "price": "17.13", "productCategoryId": "firstCategory"},
      {"productId": "thirdProduct", "name": "This is the third product",
      "currencyId": "USD",
      "price": "12.33", "productCategoryId": "secondCategory"}
      ]
    }
    ''');

final CurrencyList currencyList = currencyListFromJson('''
  { "currencyList" : currencies } ''');
final String currencyId = 'United States Dollar [USD]';
final currencies = [ 
    "Thailand baht [THB]", 
    currencyId,
    "Euro [EUR]"];
  