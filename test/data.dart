import 'package:growerp/models/@models.dart';

final Authenticate authenticateNoKey = authenticateFromJson('''
           {  "company": {"name": "Dummy Company Name",
                          "currency": "dummyCurrency"},
              "user": {"firstName": "dummyFirstName",
                       "lastName": "dummyLastName",
                       "email": "dummy@example.com",
                       "name": "dummyUsername"},
              "apiKey": null}
      ''');
final Authenticate authenticate = authenticateFromJson('''
           {  "company": {"name": "Dummy Company Name",
                          "currency": "dummyCurrency"},
              "user": {"firstName": "dummyFirstName",
                       "lastName": "dummyLastName",
                       "email": "dummy@example.com",
                       "name": "dummyUsername"},
              "apiKey": "dummyKey"}
      ''');

final String errorMessage = 'Dummy error message';
final String companyName = 'Dummy Company Name';
final String firstName = 'dummyFirstName';
final String lastName = 'dummylastName';
final String username = 'dummyUsername';
final String password = 'dummyPassword';
final String email = 'dummy@example.com';

final Catalog catalog = catalogFromJson('''
    { "categories": [ 
      {"productCategoryId": "dummyFirstCategory", "categoryName": "This is the first category",
      "description": "this is the long description of category first"},
      {"productCategoryId": "secondCategory", "categoryName": "This is the second category",
      "description": "this is the long description of category second"}
      ],
      "products": [
      {"productId": "dummyFirstProduct", "name": "This is the first product",
      "currencyId": "USD",
      "price": "23.99", "productCategoryId": "dummyFirstCategory"},
      {"productId": "secondProduct", "name": "This is the second product",
      "currencyId": "USD",
      "price": "17.13", "productCategoryId": "dummyFirstCategory"},
      {"productId": "thirdProduct", "name": "This is the third product",
      "currencyId": "USD",
      "price": "12.33", "productCategoryId": "secondCategory"}
      ]
    }
    ''');
final Product product = productFromJson('''
      {"productId": "secondProduct", "name": "This is the second product",
      "currencyId": "USD",
      "price": "17.13", "productCategoryId": "dummyFirstCategory"}
''');
final CurrencyList currencyList = currencyListFromJson('''
  { "currencyList" : currencies } ''');
final String currencyId = 'United States Dollar [USD]';
final currencies = ["Thailand baht [THB]", currencyId, "Euro [EUR]"];

final Order order = orderFromJson('''
  { "orderId": null, "orderStatusId": "OrderOpen", "currencyUomId": "THB",
    "placedDate": null, "placedTime": null, "partyId": null,
    "firstName": "dummyFirstName", "lastName": "dummylastName", "statusId": "Open", 
    "grandTotal": "44.53", "table": null, "accommodationAreaId": null,
    "accommodationSpotId": null,
  "orderItems": [
  { "orderItemSeqId": "01", "productId": null, "description": "Cola",
    "quantity": "5", "price": "1.5"},
  { "orderItemSeqId": "01", "productId": null, "description": "Macaroni",
    "quantity": "3", "price": "4.5"}
   ]}
''');
final Order emptyOrder = Order(currencyId: 'THB', orderItems: []);
final OrderItem orderItem1 = OrderItem(
    productId: "dummyFirstProduct",
    description: "This is the first product",
    quantity: 5,
    price: 3.3);
final OrderItem orderItem2 = OrderItem(
    productId: "dummySecondProduct",
    description: "This is the second product",
    quantity: 3,
    price: 2.2);
final Order totalOrder =
    Order(currencyId: 'THB', orderItems: [orderItem1, orderItem2]);
