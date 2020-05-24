import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../bloc/bloc.dart';
import '../services/repos.dart';
import 'dart:convert';

class HomeForm extends StatefulWidget {
  final Repos repos;

  HomeForm({Key key, @required this.repos}) : assert(repos != null);

  @override
  _HomeState createState() => _HomeState(repos);
}

class _HomeState extends State<HomeForm> {
  final Repos repos;
  String selectedCategoryId;

  _HomeState(this.repos);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    selectedCategoryId;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(repos: repos),
      child: BlocBuilder<HomeBloc, FormBlocState>(
        condition: (previous, current) =>
            previous.runtimeType != current.runtimeType ||
            previous is FormBlocLoading && current is FormBlocLoading,
        builder: (context, state) {
          final homeBloc = context.bloc<HomeBloc>();
          if (state is FormBlocLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is FormBlocLoadFailed) {
            return Center(
              child: RaisedButton(
                onPressed: homeBloc.reload,
                child: Text('Connection error,Retry?'),
              ),
            );
          } else {
            selectedCategoryId ??= homeBloc.categories[0].productCategoryId;
            return Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              child: Scaffold(
                  appBar: AppBar(title: Text(homeBloc?.company?.name)),
                  body: FormBlocListener<HomeBloc, String, String>(
                      onSubmitting: (context, state) {
                        LoadingDialog.show(context);
                      },
                      onSuccess: (context, state) {
                        LoadingDialog.hide(context);

                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => SuccessScreen()));
                      },
                      onFailure: (context, state) {
                        LoadingDialog.hide(context);

                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text(state.failureResponse)));
                      },
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 16, top: 4),
                                  child: Text(
                                    'Categories',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 16, top: 4),
                                  child: FlatButton(
                                    onPressed: () {},
                                    child: Text(
                                      'View All',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _categoryList(homeBloc.categories),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 16, top: 4),
                                  child: Text(
                                    'Products: ' +
                                        homeBloc.categories
                                            .firstWhere((i) =>
                                                i.productCategoryId ==
                                                selectedCategoryId)
                                            .categoryName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 16, top: 4),
                                  child: FlatButton(
                                    onPressed: () {},
                                    child: Text(
                                      'View All',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _productList(homeBloc.products)
                          ],
                        ),
                      ))),
            );
          }
        },
      ),
    );
  }

  Widget _categoryList(items) {
    return Container(
      height: 150,
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          var data = items[index];
          return Column(children: <Widget>[
            GestureDetector(
              onTap: () =>
                  setState(() => selectedCategoryId = data.productCategoryId),
              child: Container(
                margin: EdgeInsets.all(10),
                width: 95,
                height: 95,
                alignment: Alignment.center,
                child: Image(
                  image: MemoryImage(base64.decode(data.image.substring(22))),
                  height: 40,
                  width: 40,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 5),
                      blurRadius: 30,
                    )
                  ],
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Text(data.categoryName),
                Icon(
                  Icons.keyboard_arrow_right,
                  size: 14,
                )
              ],
            )
          ]);
        },
      ),
    );
  }

  Widget _productList(List items) {
    items =
        items.where((i) => i.productCategoryId == selectedCategoryId).toList();
    return Container(
      height: 200,
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          var data = items[index];
          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  width: 130,
                  height: 140,
                  alignment: Alignment.center,
                  child: Image(
                    image: MemoryImage(base64.decode(data.image.substring(22))),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 5),
                        blurRadius: 15,
                      )
                    ],
                  ),
                ),
                Container(
                  width: 130,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4, left: 4),
                  width: 130,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.price.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ]);
        },
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key key}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(key: key),
      ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  LoadingDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  SuccessScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.tag_faces, size: 100),
            SizedBox(height: 10),
            Text(
              'Success',
              style: TextStyle(fontSize: 54, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            RaisedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => HomeForm())),
              icon: Icon(Icons.replay),
              label: Text('AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
