import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../bloc/@bloc.dart';
import '../models/@models.dart';
import '../forms/@forms.dart';
import '../routing_constants.dart';

class HomeForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeBody(),
    );
  }
}

class HomeBody extends StatefulWidget {
  @override
  State<HomeBody> createState() => _HomeState();
}

class _HomeState extends State<HomeBody> {
  Authenticate authenticate;
  List<Product> products;
  List<Category> categories;
  String selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<CatalogBloc, CatalogState>(listener: (context, state) {
            if (state is CatalogError)
              _showMessage(context, state.errorMessage, Colors.red);
          }),
          BlocListener<AuthBloc, AuthState>(
              bloc: context.bloc<AuthBloc>(),
              listener: (context, state) {
                if (state is AuthAuthenticated)
                  authenticate = state.authenticate;
                if (state is AuthConnectionProblem)
                  _showMessage(context, 'Connection problem', Colors.red);
              })
        ],
        child:
            BlocBuilder<CatalogBloc, CatalogState>(builder: (context, state) {
          if (state is CatalogLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is CatalogError) {
            return Center(
                child: Column(children: [
              SizedBox(height: 100),
              RaisedButton(
                  child: Text(state.errorMessage + '\nRetry?'),
                  onPressed: () {
                    BlocProvider.of<CatalogBloc>(context).add(LoadCatalog());
                  }),
              SizedBox(height: 100),
              RaisedButton(
                  child: Text(state.errorMessage + '\nRegister?'),
                  onPressed: () => Navigator.pushNamed(context, RegisterRoute)),
            ]));
          } else if (state is CatalogLoaded) {
            if (state.catalog.categories.length == 0) {
              return Center(
                  child: RaisedButton(
                child: Text('No categories found to display' + '\nRegister?'),
                onPressed: () => Navigator.pushNamed(context, RegisterRoute),
              ));
            } else {
              // finally the main form!
              selectedCategoryId ??=
                  state.catalog.categories[0].productCategoryId;
              categories = state.catalog.categories;
              products = state.catalog.products;
              return Scaffold(
                appBar: AppBar(
                    title: Text(
                        authenticate?.company?.name ?? 'GrowERP E-commerce'),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.shopping_cart),
                        tooltip: 'Cart',
                        onPressed: () =>
                            Navigator.pushNamed(context, CartRoute),
                      ),
                      if (BlocProvider.of<AuthBloc>(context).state
                          is AuthUnauthenticated)
                        IconButton(
                            icon: Icon(Icons.exit_to_app),
                            tooltip: 'Login',
                            onPressed: () async {
                              if (await _loginDialog(context))
                                _showMessage(
                                    context, 'Login Successful', Colors.green);
                              else
                                _showMessage(
                                    context, 'Login failed', Colors.red);
                            }),
                      if (BlocProvider.of<AuthBloc>(context).state
                          is AuthAuthenticated)
                        IconButton(
                            icon: Icon(Icons.do_not_disturb),
                            tooltip: 'Logout',
                            onPressed: () => {
                                  BlocProvider.of<AuthBloc>(context)
                                      .add(Logout()),
                                  _showMessage(context, 'Logout Successful',
                                      Colors.green),
                                })
                    ]),
                body: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      _categoryList(),
                      _productsGrid(),
                    ],
                  ),
                ),
              );
            }
          }
          return Container();
        }));
  }

  Widget _categoryList() {
    return Container(
      height: 110,
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          var data = categories[index];
          return Column(children: <Widget>[
            GestureDetector(
              onTap: () =>
                  setState(() => selectedCategoryId = data.productCategoryId),
              child: Container(
                margin: EdgeInsets.all(10),
                width: 70,
                height: 70,
                alignment: Alignment.center,
                child: Image(
                  image: data.image,
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

  Widget _productsGrid() {
    List<Product> products = this
        .products
        .where((i) => i.productCategoryId == selectedCategoryId)
        .toList();
    Size size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;
    if (products.length == 0) {
      return Center(
        child: Text("No products found to display",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        child: Container(
          height: screenHeight - 100,
          width: screenWidth,
          decoration: BoxDecoration(
            color: Color(0xffECE9DE),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 50, bottom: 5),
                width: screenWidth,
                child: StaggeredGridView.countBuilder(
                  crossAxisCount: 4,
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) =>
                      new Container(
                          margin: EdgeInsets.only(
                            left: index % 2 == 0 ? 10 : 0,
                            right: index % 2 == 0 ? 0 : 10,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                            child: _gridItem(products[index]),
                          )),
                  staggeredTileBuilder: (int index) =>
                      new StaggeredTile.count(2, index == 0 ? 2 : 3),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
              ),
              _customTitle(categories
                  .firstWhere((i) => i.productCategoryId == selectedCategoryId)
                  .categoryName)
            ],
          ),
        ),
      );
    }
  }

  Widget _gridItem(product) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, ProductRoute, arguments: product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
              child: Hero(
                  tag: '${product.productId}',
                  child: Image(
                    image: product.image,
                    height: 125,
                    fit: BoxFit.contain,
                  ))),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(product.price.toString(),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
/*          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text('${product.weight}g'),
          )
*/
        ],
      ),
    );
  }

  Widget _customTitle(title) {
    Size size = MediaQuery.of(context).size;
    double screenWidth = size.width;

    return Container(
      width: screenWidth,
      height: 60,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Center(
        child: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: <Color>[
          Color(0xffECE9DE),
          Color(0xffefebe9),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )),
    );
  }
}

void _showMessage(context, message, colors) {
  Scaffold.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$message', textAlign: TextAlign.center),
          ],
        ),
        backgroundColor: colors,
      ),
    );
}

_loginDialog(BuildContext context) async {
  return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoginForm();
      });
}
