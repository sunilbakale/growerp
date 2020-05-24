import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import '../services/repos.dart';
import '../models/models.dart';

class HomeBloc extends FormBloc<String, String> {
  final Repos repos;
  List <Product> products;
  List <Category> categories;
  Company company;
  User user;

  HomeBloc({
    @required this.repos,
  }) : super(isLoading: true) {
  }

  @override
  void onLoading() async {
    dynamic userComp =
        await repos.getUserAndCompany(companyPartyId: "100001");
    if (userComp is String) {
      emitFailure(failureResponse: userComp);
    }
    dynamic catProd =
        await repos.getCategoriesAndProducts(companyPartyId: "100001");
    if (catProd is String) {
      emitFailure(failureResponse: catProd);
    }
    company = userComp.company;
    user = userComp.user;
    products = catProd.products;
    categories = catProd.categories;
    print("===??===${company?.name}");
    print("===??===${user?.name}");
    emitLoaded();
  }

  @override
  void onSubmitting() async {
/*    print(text.value);
    print(select.value);

    try {
      await Future<void>.delayed(Duration(milliseconds: 500));

      emitSuccess();
    } catch (e) {
      emitFailure();
    }
*/  }
}
